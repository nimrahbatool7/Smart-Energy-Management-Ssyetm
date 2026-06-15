import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/glass_card.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hello! I am Viora, your AI energy assistant. How can I help you reduce your bill today?', 'isUser': false},
    {'text': 'How can I reduce my bill?', 'isUser': true},
    {'text': 'Based on your data, your AC is your highest energy consumer. Reduce usage by 30 minutes daily to save approximately Rs 800 this month.', 'isUser': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF030D16), VioraColors.primaryBackground],
              ),
            ),
          ),
          
          Column(
            children: [
              // Holographic Avatar placeholder
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      VioraColors.energyGlow.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: VioraColors.energyGlow.withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 5),
                      ],
                    ),
                    child: const Icon(Icons.smart_toy_rounded, size: 60, color: Colors.white),
                  ),
                ),
              ),
              
              // Chat Messages
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildChatBubble(msg['text'], msg['isUser']);
                  },
                ),
              ),
              
              // Quick Suggestions
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildSuggestionChip('Save Energy'),
                    const SizedBox(width: 8),
                    _buildSuggestionChip('Optimize Usage'),
                    const SizedBox(width: 8),
                    _buildSuggestionChip('Reduce Bill'),
                  ],
                ),
              ),
              
              // Input Field
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Ask Viora...',
                            hintStyle: TextStyle(color: VioraColors.textSecondary),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: VioraColors.energyGlow),
                        onPressed: () {
                          if (_controller.text.isNotEmpty) {
                            setState(() {
                              _messages.add({'text': _controller.text, 'isUser': true});
                              _controller.clear();
                              // Simulate AI response
                              Future.delayed(const Duration(seconds: 1), () {
                                setState(() {
                                  _messages.add({'text': 'I am analyzing your request. Here is an optimized plan...', 'isUser': false});
                                });
                              });
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? VioraColors.energyGlow.withValues(alpha: 0.2) : VioraColors.glassBackground,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          border: Border.all(
            color: isUser ? VioraColors.energyGlow.withValues(alpha: 0.5) : VioraColors.glassBorder,
          ),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, height: 1.4)),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text, style: const TextStyle(color: VioraColors.energyGlow)),
      backgroundColor: VioraColors.energyGlow.withValues(alpha: 0.1),
      side: BorderSide(color: VioraColors.energyGlow.withValues(alpha: 0.5)),
      onPressed: () {
        _controller.text = text;
      },
    );
  }
}
