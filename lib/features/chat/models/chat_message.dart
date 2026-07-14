enum MessageRole { user, ai, system }

class ChatMessage {
  final String text;
  final MessageRole role;
  final bool isStreaming; // True if the AI is currently typing

  ChatMessage({
    required this.text,
    required this.role,
    this.isStreaming = false,
  });

  // Handy method to create a modified copy (very useful with Riverpod)
  ChatMessage copyWith({String? text, bool? isStreaming}) {
    return ChatMessage(
      text: text ?? this.text,
      role: role,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}
