// ai_assistant/lib/screens/ai_assistant_screen.dart
import 'package:flutter/material.dart';
import 'package:ai_assistant/services/openai_service.dart';

class AiAssistantScreen extends StatefulWidget {
  @override
  _AiAssistantScreenState createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _questionController = TextEditingController();
  final OpenAIService _openAIService = OpenAIService();
  String _answer = '';

  void _askQuestion() async {
    if (_questionController.text.isNotEmpty) {
      try {
        String response = await _openAIService.getResponse(_questionController.text);
        setState(() {
          _answer = response;
        });
      } catch (e) {
        setState(() {
          _answer = 'Failed to get response from OpenAI: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Assistant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _questionController,
              decoration: InputDecoration(labelText: 'Ask a question'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _askQuestion,
              child: Text('Ask'),
            ),
            SizedBox(height: 20),
            Text(
              _answer,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
