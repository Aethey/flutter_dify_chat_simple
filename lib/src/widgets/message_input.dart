import 'package:flutter/material.dart';

/// A widget for message input with a send button
class MessageInput extends StatefulWidget {
  /// Callback for when a message is sent
  final void Function(String message) onSendMessage;
  
  /// Whether a message is currently being sent/processed
  final bool isLoading;
  
  /// Hint text to display in the input field
  final String? hintText;
  
  /// Constructor
  const MessageInput({
    super.key,
    required this.onSendMessage,
    this.isLoading = false,
    this.hintText,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSendButton = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _showSendButton = _textController.text.trim().isNotEmpty;
    });
  }

  void _handleSendMessage() {
    final message = _textController.text.trim();
    if (message.isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(message);
      _textController.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: MediaQuery.of(context).padding.bottom + 16.0,
        top: 16.0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          // Text input field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Type a message...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                minLines: 1,
                enabled: !widget.isLoading,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSendMessage(),
              ),
            ),
          ),
          
          // Send button
          AnimatedOpacity(
            opacity: _showSendButton && !widget.isLoading ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : _handleSendMessage,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12.0),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 0,
                ),
                child: Icon(
                  widget.isLoading ? Icons.hourglass_empty : Icons.send,
                  size: 20.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 