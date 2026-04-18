// lib/helpers/telegram_logger.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TelegramLogger {
  static final String _token = dotenv.env['TELEGRAM_TOKEN'] ?? '';
  static final String _chatId = dotenv.env['TELEGRAM_CHAT_ID'] ?? ''; // group ID

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
