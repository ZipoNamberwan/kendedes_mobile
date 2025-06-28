import 'package:dio/dio.dart';
import 'package:kendedes_mobile/classes/services/dio_service.dart';
import 'package:kendedes_mobile/classes/telegram_logger.dart';

typedef HandlerFunction<T> = void Function(T exception);

class ApiServerHandler {
  final HandlerFunction<LoginExpiredException> onLoginExpired;
  final HandlerFunction<DataProviderException> onDataProviderError;
  final HandlerFunction<Exception> onOtherError;

  ApiServerHandler({
    required this.onLoginExpired,
    required this.onDataProviderError,
    required this.onOtherError,
  });

  Future<void> handle(Future<void> Function() action) async {
    try {
      await action();
    } on DioException catch (dioError) {
      final err = dioError.error;
      if (err is LoginExpiredException) {
        onLoginExpired(err);
      } else if (err is DataProviderException) {
        onDataProviderError(err);
      }
    } catch (e, stackTrace) {
      try {
        final fullTrace = stackTrace.toString();
        final truncatedTrace =
            fullTrace.length > 500 ? fullTrace.substring(0, 500) : fullTrace;

        final logMessage = '''
        🚨 *Unhandled Error*

        *Error:* `${e.toString()}`
        *Stack Trace:*
        $truncatedTrace
        ''';

        TelegramLogger.send(logMessage);
      } catch (_) {
        // Fail silently so it never blocks real error flow
      }
      if (e is Exception) {
        onOtherError(e);
      } else {
        onOtherError(Exception('Unknow Error, mengirim log ke server...'));
      }
    }
  }

  static Future<void> run({
    required Future<void> Function() action,
    required HandlerFunction<LoginExpiredException> onLoginExpired,
    required HandlerFunction<DataProviderException> onDataProviderError,
    required HandlerFunction<Exception> onOtherError,
  }) async {
    return ApiServerHandler(
      onLoginExpired: onLoginExpired,
      onDataProviderError: onDataProviderError,
      onOtherError: onOtherError,
    ).handle(action);
  }
}
