import 'package:flutter/material.dart';
import 'package:ai_assistant/services/auth_service.dart';
import 'package:ai_assistant/services/openai_service.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:highlight/highlight.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiAssistantScreen extends StatefulWidget {
  @override
  _AiAssistantScreenState createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final OpenAIService _openAIService = OpenAIService();
  final AuthService _authService = AuthService();
  User? _user;
  Map<String, List<Map<String, String>>> chatHistory = {};
  String selectedCategory = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _loadChatHistory();
    }
  }

  Future<void> _loadChatHistory() async {
    if (_user != null) {
      chatHistory = await _authService.loadCategoriesAndChatHistory(_user!.uid);
      if (chatHistory.isEmpty) {
        chatHistory['General'] = [];
        selectedCategory = 'General';
      } else {
        selectedCategory = chatHistory.keys.last;
      }
      setState(() {});
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _askQuestion() async {
    if (_questionController.text.isNotEmpty) {
      final question = _questionController.text;
      setState(() {
        chatHistory[selectedCategory]!.add({'user': question});
        _questionController.clear();
      });
      try {
        String response = await _openAIService.getResponse(chatHistory[selectedCategory].toString());
        setState(() {
          chatHistory[selectedCategory]!.add({'ai': response});
        });
        if (_user != null) {
          await _authService.saveCategoriesAndChatHistory(_user!.uid, chatHistory);
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to get response from OpenAI';
        });
      }
      _scrollToBottom();
    }
  }

  void _addCategory() {
    setState(() {
      final newCategory = 'Category ${chatHistory.keys.length + 1}';
      chatHistory[newCategory] = [];
      selectedCategory = newCategory;
    });
    if (_user != null) {
      _authService.saveCategoriesAndChatHistory(_user!.uid, chatHistory);
    }
  }

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      Navigator.pop(context); // Close the drawer when a category is selected
    });
    _scrollToBottom();
  }

  void _editCategory(String oldCategory, String newCategory) {
    setState(() {
      final messages = chatHistory.remove(oldCategory);
      chatHistory[newCategory] = messages!;
      if (selectedCategory == oldCategory) {
        selectedCategory = newCategory;
      }
    });
    if (_user != null) {
      _authService.saveCategoriesAndChatHistory(_user!.uid, chatHistory);
    }
  }

  void _deleteCategory(String category) async {
    setState(() {
      chatHistory.remove(category);
      if (selectedCategory == category) {
        selectedCategory = chatHistory.keys.isEmpty ? '' : chatHistory.keys.last;
      }
    });
    if (_user != null) {
      await _authService.saveCategoriesAndChatHistory(_user!.uid, chatHistory);
    }
  }

  void _logout() async {
    await _authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Widget _buildChatHistory() {
    final messages = chatHistory[selectedCategory] ?? [];
    return ListView.builder(
      controller: _scrollController,
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
        parts.add(Text(response.substring(currentIndex, match.start), style: TextStyle(fontSize: 16)));
      }

      final codeBlockContent = match.group(1) ?? '';
      final lines = codeBlockContent.split('\n');
      final language = lines.first.trim();
      final code = lines.skip(1).join('\n');
      final highlightedCode = highlight.parse(code, language: language);

      parts.add(
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
          ),
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.grey[850], // Title bar color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.0),
                    topRight: Radius.circular(4.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      language,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Code copied to clipboard')),
                        );
                      },
                      icon: Icon(Icons.copy, color: Colors.white, size: 16),
                      label: Text('Copy code', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4.0),
                    bottomRight: Radius.circular(4.0),
                  ),
                ),
                child: HighlightView(
                  code,
                  language: highlightedCode.language ?? 'plaintext',
                  theme: atomOneDarkTheme, // Use a dark theme
                  padding: EdgeInsets.all(8),
                  textStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      currentIndex = match.end;
    }

    if (currentIndex < response.length) {
      parts.add(Text(response.substring(currentIndex), style: TextStyle(fontSize: 16)));
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
        actions: [
          Text(_user?.email ?? ''),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
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
          ],
        ),
      ),
    );
  }
}
