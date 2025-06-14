import 'package:dio/dio.dart';
import 'package:kendedes_mobile/classes/services/dio_service.dart';

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
    } catch (e) {
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
