import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/chat_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String _currentStreamedText = '';

  final List<String> _quickQuestions = [
    "What are the best spots in Giza?",
    "Safety tips for solo female travelers?",
    "Top workshops near Cairo?",
    "Best local food to try?",
    "Plan a day trip for me!",
  ];

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    await _chatService.initializeContext();
    if (mounted) {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                "Hi! 👋 I'm Trippy, your travel assistant for Giza & Cairo! 🇪🇬\n\nHow can I help you today?",
            isUser: false,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isTyping) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
      _currentStreamedText = '';
    });
    _messageController.clear();

    // Slight delay to allow UI to update and scroll
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    try {
      final stream = _chatService.sendMessageStream(text);

      await for (final chunk in stream) {
        setState(() {
          _currentStreamedText += chunk;
        });
        _scrollToBottom();
      }

      // Once streaming is done, add the final message to the list
      setState(() {
        _messages.add(ChatMessage(text: _currentStreamedText, isUser: false));
        _isTyping = false;
        _currentStreamedText = '';
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Oops, something went wrong. Please try again.",
            isUser: false,
          ),
        );
        _isTyping = false;
        _currentStreamedText = '';
      });
      _scrollToBottom();
    }
  }

  Future<void> _resetChat() async {
    setState(() {
      _messages.clear();
      _messages.add(
        ChatMessage(
          text: "Resetting chat and reading latest trips... 🔄",
          isUser: false,
        ),
      );
    });

    await _chatService.resetChat();

    if (mounted) {
      setState(() {
        _messages.clear();
        _messages.add(
          ChatMessage(
            text: "Chat reset! How can I help you explore Egypt?",
            isUser: false,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🤖"),
            const SizedBox(width: 8),
            Text(
              'Trippy Chat',
              style: GoogleFonts.poppins(
                color: const Color(0xFF1A1A2E),
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFB8A9D0)),
            tooltip: 'Restart Chat',
            onPressed: _resetChat,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_chatService.isReady)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF8E7AB5)),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _messages.length) {
                      return _buildMessageBubble(_messages[index]);
                    } else {
                      return _buildMessageBubble(
                        ChatMessage(
                          text: _currentStreamedText.isEmpty
                              ? "..."
                              : _currentStreamedText,
                          isUser: false,
                        ),
                        isStreaming: true,
                      );
                    }
                  },
                ),
              ),
            // Quick-question chips pinned above the input bar
            if (!_isTyping) _buildQuickQuestions(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, {bool isStreaming = false}) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF8E7AB5) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: isUser
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser && isStreaming && message.text == "...")
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFB8A9D0),
                  ),
                ),
              )
            else
              Flexible(
                child: Text(
                  message.text,
                  style: GoogleFonts.poppins(
                    color: isUser ? Colors.white : const Color(0xFF1A1A2E),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickQuestions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _quickQuestions
              .map(
                (q) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      q,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF8E7AB5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xFFE6E0F8)),
                    ),
                    onPressed: () => _sendMessage(q),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: GoogleFonts.poppins(color: const Color(0xFF9E9E9E)),
                filled: true,
                fillColor: const Color(0xFFF9F9F7),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) {
                if (!_isTyping) {
                  _sendMessage(_messageController.text);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (!_isTyping && _messageController.text.trim().isNotEmpty) {
                _sendMessage(_messageController.text);
              }
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF8E7AB5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
