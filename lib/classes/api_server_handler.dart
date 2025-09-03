import 'package:dio/dio.dart';
import 'package:kendedes_mobile/classes/app_config.dart';
import 'package:kendedes_mobile/classes/repositories/auth_repository.dart';
import 'package:kendedes_mobile/classes/services/dio_service.dart';
import 'package:kendedes_mobile/classes/telegram_logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
        PackageInfo packageInfo = await PackageInfo.fromPlatform();

        // Emit the current version name
        final currentVersionName = packageInfo.version;

        final fullTrace = stackTrace.toString();
        final truncatedTrace =
            fullTrace.length > AppConfig.stackTraceLimitCharacter
                ? fullTrace.substring(0, AppConfig.stackTraceLimitCharacter)
                : fullTrace;

        final user = AuthRepository().getUser();
        final userInfo =
            user.id != ''
                ? 'ID: ${user.id}, Name: ${user.firstname}, Email: ${user.email}, Organization: ${user.organization?.name ?? 'N/A'}'
                : 'User is null';

        final logMessage = '''
        🚨 *Unhandled Error*

        *Error:* `${e.toString()}`
        *App Version:* `$currentVersionName`
        *User Info: $userInfo*
        $userInfo
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
