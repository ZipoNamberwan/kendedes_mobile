// lib/helpers/telegram_logger.dart
import 'package:dio/dio.dart';

class TelegramLogger {
  static const String _token = '7701155934:AAF0KR0wxFGlwkOjZ8zOV8tk0gQcDagLFug';
  static const String _chatId = '-4976940750'; // group ID

  static final Dio _dio = Dio();

  static Future<void> send(String message) async {
    try {
      await _dio.post(
        'https://api.telegram.org/bot$_token/sendMessage',
        data: {'chat_id': _chatId, 'text': message},
      );
    } catch (e) {
      // silent failure, do not throw
    }
  }
}
