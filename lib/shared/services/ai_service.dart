import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const _baseUrl = String.fromEnvironment('AI_PROXY_URL');

  Future<String> chat({
    required String message,
    String? subjectContext,
    List<Map<String, String>>? history,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': message,
              'context': subjectContext,
              'history': history ?? [],
            }),
          )
          .timeout(const Duration(seconds: 45));
      if (res.statusCode != 200) {
        throw Exception('فشل الاتصال بالمساعد');
      }
      return jsonDecode(res.body)['reply'] as String;
    } catch (e) {
      throw Exception('تعذر الوصول إلى المساعد.');
    }
  }
}
