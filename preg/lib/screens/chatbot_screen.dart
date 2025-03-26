import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late ChatSession _chatSession;
  bool _isLoading = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initChat() {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found in environment variables');
      }

      final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      _chatSession = model.startChat();
      _messages.add({
        'sender': 'bot',
        'message':
            'Hello! I\'m your pregnancy care assistant. How can I help you today?',
      });
    } catch (e) {
      _handleError('Failed to initialize chat: ${e.toString()}');
    }
  }

  void _handleError(String errorMessage) {
    setState(() {
      _messages.add({
        'sender': 'system',
        'message': errorMessage,
        'isError': true,
      });
      _isLoading = false;
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'message': text});
      _isLoading = true;
    });
    _messageController.clear();
    _focusNode.requestFocus();

    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response received');
      }
      setState(() {
        _messages.add({'sender': 'bot', 'message': response.text!});
      });
    } catch (e) {
      _handleError('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pregnancy Care Chatbot'),
        backgroundColor: Colors.pink[200],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment:
                      msg['sender'] == 'user'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          msg['isError'] == true
                              ? Colors.red[100]
                              : msg['sender'] == 'user'
                              ? Colors.pink[100]
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['message']),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Ask about pregnancy...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
