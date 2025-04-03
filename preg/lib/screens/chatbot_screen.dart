

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  static const String GEMINI_API_KEY =
      'AIzaSyCifVOv1JJ5kG_3FW9_I280lFdAhhI5QsM';
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
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: GEMINI_API_KEY,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
      );

      _chatSession = model.startChat(history: []);

      // Add initial message
      setState(() {
        _messages.add({
          'sender': 'bot',
          'message':
              'Hello! I\'m your pregnancy care assistant. I can help you with pregnancy-related questions and concerns. How may I assist you today?',
        });
      });
    } catch (e) {
      print('Error initializing chat: $e');
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
      final prompt = '''You are a knowledgeable pregnancy care assistant. 
      Provide accurate, helpful, and compassionate responses to pregnancy-related questions.
      Current question: $text''';

      final response = await _chatSession.sendMessage(Content.text(prompt));
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/chatbot_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0), // Added top padding
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return Align(
                        alignment: msg['sender'] == 'user'
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: msg['isError'] == true
                                ? const Color.fromARGB(255, 151, 82, 89)
                                : msg['sender'] == 'user'
                                    ? Colors.pink[100]
                                    : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg['message'],
                            style: TextStyle(
                              color: msg['isError'] == true ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_isLoading)
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                    ),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.pink[200],
                        child: IconButton(
                          icon: Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}