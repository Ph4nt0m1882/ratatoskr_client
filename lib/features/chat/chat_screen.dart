import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../settings/settings_provider.dart';
import 'chat_provider.dart';
import 'models/chat_message.dart';

// ConsumerStatefulWidget allows us to keep a ScrollController state
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes to trigger auto-scroll
    ref.listen(chatProvider, (previous, next) {
      if (previous?.length != next.length || (next.isNotEmpty && next.last.isStreaming)) {
        _scrollToBottom();
      }
    });

    // 1. Listen to the message list in real-time!
    final messages = ref.watch(chatProvider);

    return Scaffold(
      // A premium gradient background to make the glass effect visible
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ], // The "Ratatoskr" dark theme
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // The Header
              _buildHeader(context, ref),

              // 2. The message list (Flexible takes all remaining vertical space)
              Flexible(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(context, messages[index]);
                  },
                ),
              ),

              // 3. The magic input bar (Glassmorphism)
              _buildInputArea(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  // --- Small UI chunks extracted to keep build() clean ---

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Ratatoskr",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 1.2,
            ),
          ),
          // Model Selection Button
          PopupMenuButton<String>(
            icon: const Icon(Icons.memory, color: Colors.deepPurpleAccent),
            tooltip: "Change Model",
            onSelected: (String modelName) {
              ref.read(settingsProvider.notifier).changeModel(modelName);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'gemini-3.5-flash',
                child: Text('Gemini 3.5 Flash (Fast)'),
              ),
              const PopupMenuItem<String>(
                value: 'gemini-2.0-flash',
                child: Text('Gemini 2.0 Flash (Stable)'),
              ),
              const PopupMenuItem<String>(
                value: 'gemma-4-26b-a4b-it',
                child: Text('Gemma (Open Source)'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    // If it's a system message (RAG, logs), center it small and discreet
    if (message.role == MessageRole.system) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            message.text,
            style: const TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    final isUser = message.role == MessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ), // The bubble adapts to 75% of the screen size
        decoration: BoxDecoration(
          // User is purple, AI is a transparent glass rectangle
          color: isUser
              ? Colors.deepPurple.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUser
                ? const Radius.circular(0)
                : const Radius.circular(20),
            bottomLeft: !isUser
                ? const Radius.circular(0)
                : const Radius.circular(20),
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        child: MarkdownBody(
          data: message.text + (message.isStreaming ? " ✍️" : ""),
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(color: Colors.white, fontSize: 16),
            h1: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            h2: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            listBullet: const TextStyle(color: Colors.white),
            code: const TextStyle(color: Colors.lightGreenAccent, backgroundColor: Colors.transparent),
            codeblockPadding: const EdgeInsets.all(8),
            codeblockDecoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();

    return ClipRRect(
      // Mandatory so the blur doesn't overflow
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ), // The Glassmorphism effect!
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2), // Semi-transparent background
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Envoyez une commande ou un message...",
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    // When pressing Enter on the keyboard
                    if (value.isNotEmpty) {
                      ref.read(chatProvider.notifier).sendMessage(value);
                      textController.clear();
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.deepPurpleAccent),
                onPressed: () {
                  // When clicking the send arrow button
                  if (textController.text.isNotEmpty) {
                    ref
                        .read(chatProvider.notifier)
                        .sendMessage(textController.text);
                    textController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
