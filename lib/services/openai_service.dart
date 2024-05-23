import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String _apiKey = '';

  Future<String> getResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o', // Specify the model here
          'messages': [{"role": "user", "content": prompt}],
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // return jsonEncode(data);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to load post ${response.statusCode}');
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
