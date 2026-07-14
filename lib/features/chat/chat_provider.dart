import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../settings/settings_provider.dart';
import 'models/chat_message.dart';

class ChatNotifier extends Notifier<List<ChatMessage>> {
  String _streamBuffer = "";
  Timer? _typewriterTimer;
  bool _isStreamDone = false;

  @override
  List<ChatMessage> build() {
    return []; // The list off all messages in the conversation
  }

  void _startTypewriter() {
    if (_typewriterTimer != null && _typewriterTimer!.isActive) return;

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (_streamBuffer.isEmpty) {
        if (_isStreamDone) {
          timer.cancel();
          final lastMessage = state.last;
          state = [
            ...state.sublist(0, state.length - 1),
            lastMessage.copyWith(isStreaming: false),
          ];
        }
        return;
      }

      int charsToTake = _streamBuffer.length > 20 ? 4 : 1;
      final chunkToAdd = _streamBuffer.substring(0, charsToTake);
      _streamBuffer = _streamBuffer.substring(charsToTake);

      final lastMessage = state.last;
      state = [
        ...state.sublist(0, state.length - 1),
        lastMessage.copyWith(text: lastMessage.text + chunkToAdd),
      ];
    });
  }

  Future<void> sendMessage(String prompt) async {
    // Reset typewriter state for new message
    _streamBuffer = "";
    _isStreamDone = false;
    _typewriterTimer?.cancel();

    // add the user's message
    state = [...state, ChatMessage(text: prompt, role: MessageRole.user)];

    // Create the empty message of the AI to show the streaming state
    state = [
      ...state,
      ChatMessage(text: "", role: MessageRole.ai, isStreaming: true),
    ];

    try {
      // Read the currently selected model and provider
      final currentSettings = ref.read(settingsProvider);

      final request = http.Request(
        'POST',
        Uri.parse('http://127.0.0.1:8000/chat/stream'),
      );
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        "provider": currentSettings.provider,
        "model": currentSettings.model,
        "prompt": prompt,
      });

      // sent the request and listenthe stream
      final response = await http.Client().send(request);

      response.stream
          .transform(utf8.decoder)
          .listen(
            (chunk) {
              _streamBuffer += chunk;
              _startTypewriter();
            },
            onDone: () {
              _isStreamDone = true;
              _startTypewriter(); // Ensure timer flushes buffer and stops
            },
          );
    } catch (e) {
      state = [
        ...state.sublist(0, state.length - 1),
        ChatMessage(text: "Connection error.", role: MessageRole.ai),
      ];
    }
  }
}

final chatProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(() {
  return ChatNotifier();
});
