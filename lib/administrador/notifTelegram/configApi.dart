import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NotificacionesTelegram {
  final String botToken = dotenv.env['TELEGRAM_BOT_TOKEN'] ?? '';
  final String chatId = dotenv.env['TELEGRAM_CHAT_ID'] ?? '';

  Future<void> enviarNotificacion(String mensaje) async {
    final url = Uri.parse(
      'https://api.telegram.org/bot$botToken/sendMessage',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'chat_id': chatId,
          'text': mensaje,
          'parse_mode': 'HTML', // 🔥 ESTA ES LA CLAVE
          'disable_web_page_preview': true,
        }),
      );

      if (response.statusCode == 200) {
        print('Notificación enviada correctamente.');
      } else {
        print(
            'Error al enviar la notificación. Código: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('Excepción al enviar la notificación: $e');
    }
  }
}
