import 'package:flutter/material.dart';
import 'package:ai_assistant/services/openai_service.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:highlight/highlight.dart'; // Correct import
import 'package:flutter/services.dart'; // For Clipboard
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AiAssistantScreen extends StatefulWidget {
  @override
  _AiAssistantScreenState createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _questionController = TextEditingController();
  final OpenAIService _openAIService = OpenAIService();
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceInput = '';

  Map<String, List<Map<String, String>>> chatHistory = {};
  String selectedCategory = 'General';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    chatHistory[selectedCategory] = [];
    _speech = stt.SpeechToText();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          _startListening();
        }
      },
      onError: (error) {
        print("Speech recognition error: $error");
        _startListening();
      },
    );

    if (available) {
      _startListening();
    } else {
      setState(() {
        _errorMessage = 'Speech recognition is not available';
      });
    }
  }

  void _startListening() {
    if (!_isListening) {
      _speech.listen(
        onResult: (result) {
          setState(() {
            _voiceInput = result.recognizedWords;
          });

          if (result.finalResult) {
            _questionController.text = _voiceInput;
            _askQuestion();
            _voiceInput = '';
          }
        },
      );
      setState(() {
        _isListening = true;
      });
    }
  }

  void _askQuestion() async {
    if (_questionController.text.isNotEmpty) {
      final question = _questionController.text;
      setState(() {
        chatHistory[selectedCategory]!.add({'user': question});
        _questionController.clear();
      });
      try {
        String response = await _openAIService.getResponse(question);
        setState(() {
          chatHistory[selectedCategory]!.add({'ai': response});
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to get response from OpenAI';
        });
      }
    }
  }

  void _addCategory() {
    setState(() {
      final newCategory = 'Category ${chatHistory.keys.length + 1}';
      chatHistory[newCategory] = [];
      selectedCategory = newCategory;
    });
  }

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      Navigator.pop(context); // Close the drawer when a category is selected
    });
  }

  void _editCategory(String oldCategory, String newCategory) {
    setState(() {
      final messages = chatHistory.remove(oldCategory);
      chatHistory[newCategory] = messages!;
      if (selectedCategory == oldCategory) {
        selectedCategory = newCategory;
      }
    });
  }

  void _deleteCategory(String category) {
    setState(() {
      chatHistory.remove(category);
      if (selectedCategory == category) {
        selectedCategory = chatHistory.keys.first;
      }
    });
  }

  Widget _buildChatHistory() {
    final messages = chatHistory[selectedCategory] ?? [];
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        if (message.containsKey('user')) {
          return ListTile(
            title: Text(message['user']!, style: TextStyle(fontWeight: FontWeight.bold)),
          );
        } else {
          return _buildAiResponse(message['ai']!);
        }
      },
    );
  }

  Widget _buildAiResponse(String response) {
    final parts = _parseResponse(response);
    return ListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: parts,
      ),
    );
  }

  List<Widget> _parseResponse(String response) {
    final List<Widget> parts = [];
    final RegExp codeBlockPattern = RegExp(r'```(.*?)```', dotAll: true);
    final matches = codeBlockPattern.allMatches(response);
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        parts.add(Text(response.substring(currentIndex, match.start)));
      }

      final codeBlockContent = match.group(1) ?? '';
      final lines = codeBlockContent.split('\n');
      final language = lines.first.trim();
      final code = lines.skip(1).join('\n');
      final highlightedCode = highlight.parse(code, language: language);

      parts.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                language,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Code copied to clipboard')),
                  );
                },
              ),
            ],
          ),
          HighlightView(
            code,
            language: highlightedCode.language ?? 'plaintext',
            theme: githubTheme,
            padding: EdgeInsets.all(8),
            textStyle: TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ],
      ));

      currentIndex = match.end;
    }

    if (currentIndex < response.length) {
      parts.add(Text(response.substring(currentIndex)));
    }

    return parts;
  }

  Widget _buildCategories() {
    return ListView(
      children: [
        ...chatHistory.keys.map((category) {
          return ListTile(
            title: Text(category),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async {
                    final newCategory = await _showEditCategoryDialog(category);
                    if (newCategory != null && newCategory.isNotEmpty) {
                      _editCategory(category, newCategory);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _showDeleteCategoryDialog(category),
                ),
              ],
            ),
            selected: selectedCategory == category,
            onTap: () => _selectCategory(category),
          );
        }).toList(),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Category'),
          onTap: _addCategory,
        ),
      ],
    );
  }

  Future<void> _showDeleteCategoryDialog(String category) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content: Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteCategory(category);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showEditCategoryDialog(String oldCategory) {
    final controller = TextEditingController(text: oldCategory);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(selectedCategory),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: _buildCategories(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _buildChatHistory(),
            ),
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: 'Ask a question',
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
              onSubmitted: (_) => _askQuestion(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _askQuestion,
              child: Text('Ask'),
            ),
          ],
        ),
      ),
    );
  }
}
