import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kendedes_mobile/classes/helpers.dart';
import 'package:kendedes_mobile/classes/services/shared_preference_service.dart';
import 'package:kendedes_mobile/classes/telegram_logger.dart';

class DioService {
  static final DioService _instance = DioService._internal();
  factory DioService() => _instance;

  DioService._internal();

  static const String _baseUrl = AppHelper.apiUrl;

  late Dio dio;
  late SharedPreferenceService _sharedPreferenceService;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _sharedPreferenceService = SharedPreferenceService();
    String? authToken = _sharedPreferenceService.getToken();

    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          String? currentToken = _sharedPreferenceService.getToken();
          if (currentToken != null) {
            options.headers['Authorization'] = 'Bearer $currentToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          _handleDioError(error);
        },
      ),
    );
  }

  void clearAuthHeader() {
    dio.options.headers.remove('Authorization');
  }

  void dispose() {
    dio.close();
  }

  void _handleDioError(DioException error) {
    // Default user-friendly message
    String userMessage =
        'Terjadi kesalahan jaringan, mengirim log ke server...';

    // Determine user message based on error type
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      userMessage = 'Koneksi timeout';
    } else if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        clearAuthHeader();
        _sharedPreferenceService.clearToken();
        userMessage = 'Sesi telah berakhir, silakan login kembali';
        _safeSendLog(error, userMessage);
        throw LoginExpiredException(userMessage);
      } else if (statusCode == 403) {
        userMessage = 'Akses ditolak';
      } else if (statusCode == 404) {
        userMessage = 'Data tidak ditemukan';
      } else if (statusCode == 422) {
        final data = error.response?.data;
        if (data is Map && data['message'] != null) {
          userMessage = data['message'].toString();
        } else {
          userMessage = 'Data tidak valid';
        }
      } else {
        userMessage = 'Server error ($statusCode), mengirim log ke server...';
      }
    } else if (error.type == DioExceptionType.cancel) {
      userMessage = 'Request dibatalkan';
    } else if (error.type == DioExceptionType.unknown &&
        error.error is SocketException) {
      userMessage = 'Tidak ada koneksi internet';
    } else if (error.type == DioExceptionType.unknown) {
      userMessage =
          error.message != null
              ? 'Terjadi kesalahan: ${error.message}, mengirim log ke server...'
              : userMessage;
    }

    // Send detailed log to Telegram
    _safeSendLog(error, userMessage);

    // Rethrow user-facing exception
    throw DataProviderException(userMessage);
  }
}

void _safeSendLog(DioException error, String userMessage) {
  try {
    final request = error.requestOptions;
    final statusCode = error.response?.statusCode ?? 'N/A';
    final responseBody = error.response?.data.toString() ?? 'null';
    final stackTrace = (error.stackTrace.toString()).trim();
    final trimmedStack =
        stackTrace.length > 1000
            ? '${stackTrace.substring(0, 1000)}...'
            : stackTrace;

    final logMessage = '''
        🚨 *Dio Error Report*

        *Type:* `${error.type}`
        *Message:* `${error.message}`
        *URL:* `${request.uri}`
        *Status Code:* `$statusCode`
        *User Message:* `$userMessage`

        *Response Body:*
        $responseBody

        *Stack Trace:*
        $trimmedStack

        ''';

    TelegramLogger.send(logMessage);
  } catch (_) {
    // Fail silently so it never blocks real error flow
  }
}

class DataProviderException implements Exception {
  final String message;

  const DataProviderException(this.message);

  @override
  String toString() => 'DataProviderException: $message';
}

class LoginExpiredException implements Exception {
  final String message;

  const LoginExpiredException(this.message);

  @override
  String toString() => 'LoginExpiredException: $message';
}
