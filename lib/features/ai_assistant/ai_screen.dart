import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/glass_card.dart';
import '../auth/services/auth_service.dart';
import 'ai_engine.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController _controller = TextEditingController();
  final AiEngine _aiEngine = AiEngine();
  final List<Map<String, dynamic>> _chatHistory = [];
  bool _evaluating = false;

  @override
  void initState() {
    super.initState();
    _evaluateAndLoad();
    _chatHistory.add({
      'text': 'Hello! I am Viora, your AI energy assistant. Here are my latest optimization insights for your smart home:',
      'isUser': false,
    });
  }

  Future<void> _evaluateAndLoad() async {
    setState(() => _evaluating = true);
    await _aiEngine.evaluateRulesAndGenerateInsights();
    if (mounted) setState(() => _evaluating = false);
  }

  @override
  Widget build(BuildContext context) {
    final uid = Get.find<AuthService>().uid;

    if (uid == null || uid.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to access AI Assistant', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: VioraColors.energyGlow),
            onPressed: _evaluating ? null : _evaluateAndLoad,
          ),
        ],
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
              // Holographic Avatar
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      VioraColors.energyGlow.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: VioraColors.energyGlow.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 3),
                      ],
                    ),
                    child: const Icon(Icons.smart_toy_rounded, size: 48, color: Colors.white),
                  ),
                ),
              ),
              
              if (_evaluating)
                const LinearProgressIndicator(color: VioraColors.energyGlow, backgroundColor: Colors.transparent),

              // Dynamic Insights and Chat
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _aiEngine.watchInsights(uid),
                  builder: (context, snapshot) {
                    final List<Widget> listItems = [];

                    // 1. Initial greeting
                    listItems.add(_buildChatBubble(_chatHistory[0]['text'], false));

                    // 2. Dynamic Insights from Firestore
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      for (var doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>? ?? {};
                        final msg = data['message'] ?? '';
                        if (msg.isNotEmpty) {
                          listItems.add(
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: GlassCard(
                                glowColor: VioraColors.energyGlow,
                                child: Row(
                                  children: [
                                    const Icon(Icons.tips_and_updates, color: VioraColors.energyGlow),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        msg,
                                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    }

                    // 3. Rest of the Chat History
                    for (int i = 1; i < _chatHistory.length; i++) {
                      listItems.add(_buildChatBubble(_chatHistory[i]['text'], _chatHistory[i]['isUser']));
                    }

                    return ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: listItems,
                    );
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
                              _chatHistory.add({'text': _controller.text, 'isUser': true});
                              final query = _controller.text;
                              _controller.clear();
                              
                              // Simulate AI reply response
                              Future.delayed(const Duration(milliseconds: 800), () {
                                String reply = 'I am processing your query regarding "$query". Here are my suggestions:';
                                if (query.toLowerCase().contains('save')) {
                                  reply = 'To maximize savings, turn off your high-power appliances (AC, Heater) during peak tariff hours (usually 6 PM - 10 PM).';
                                } else if (query.toLowerCase().contains('optimize')) {
                                  reply = 'You can optimize usage by setting timers on your appliances and upgrading to inverter-based models.';
                                } else if (query.toLowerCase().contains('bill')) {
                                  reply = 'Based on current rates, lowering your consumption by just 10% could move you to a lower tariff slab and save up to 20% on your bill.';
                                }
                                setState(() {
                                  _chatHistory.add({'text': reply, 'isUser': false});
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
