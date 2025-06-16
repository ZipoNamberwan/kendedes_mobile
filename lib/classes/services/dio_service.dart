import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kendedes_mobile/classes/services/shared_preference_service.dart';

class DioService {
  static final DioService _instance = DioService._internal();
  factory DioService() => _instance;

  DioService._internal();

  // static const String _baseUrl = 'https://kendedes.cathajatim.id/api';
  static const String _baseUrl = 'http://192.168.1.7:8000/api';

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
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw DataProviderException('Koneksi timeout');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          // Token expired, logout user
          clearAuthHeader();
          _sharedPreferenceService.clearToken();
          throw LoginExpiredException(
            'Sesi telah berakhir, silakan login kembali',
          );
        } else if (statusCode == 403) {
          throw DataProviderException('Akses ditolak');
        } else if (statusCode == 404) {
          throw DataProviderException('Data tidak ditemukan');
        } else if (statusCode == 422) {
          final data = error.response?.data;
          if (data['message'] != null) {
            throw DataProviderException(data['message']);
          }
          throw DataProviderException('Data tidak valid');
        }
        throw DataProviderException('Server error ($statusCode), mengirim log ke server...');
      case DioExceptionType.cancel:
        throw DataProviderException('Request dibatalkan');
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          throw DataProviderException('Tidak ada koneksi internet');
        }
        final message =
            error.message != null
                ? 'Terjadi kesalahan: ${error.message}, mengirim log ke server...'
                : 'Terjadi kesalahan jaringan, mengirim log ke server...';
        throw DataProviderException(message);
      default:
        throw DataProviderException('Terjadi kesalahan jaringan, mengirim log ke server...');
    }
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
