import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class OpenAIService {
  Future<String> _loadApiKey() async {
    final String response = await rootBundle.loadString('assets/config/api-keys.json');
    final data = json.decode(response);
    return data['openai_api_key'];
  }
Future<String> getResponse(String prompt, String model) async {
    try {
      String apiKey = await _loadApiKey();
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model, // Use the model parameter
          'messages': [{"role": "user", "content": prompt}],
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to load post ${response.statusCode}');
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
