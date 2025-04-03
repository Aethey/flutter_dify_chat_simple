import 'package:chat_bot_sdk/custom/color.dart';
import 'package:chat_bot_sdk/src/widgets/conversation_history_dialog.dart';
import 'package:chat_bot_sdk/src/widgets/conversation_history_modal.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../services/conversation_service.dart';

/// A widget for message input with a send button
class MessageInput extends StatefulWidget {
  /// Callback for when a message is sent
  final void Function(String message, String? conversationId) onSendMessage;

  /// Whether a message is currently being sent/processed
  final bool isLoading;

  /// Whether history is being loaded
  final bool isLoadingHistory;

  /// Hint text to display in the input field
  final String? hintText;

  /// User ID for storing conversation history
  final String userId;

  /// Current conversation ID
  final String? conversationId;

  /// Constructor
  const MessageInput({
    super.key,
    required this.onSendMessage,
    required this.userId,
    this.conversationId,
    this.isLoading = false,
    this.isLoadingHistory = false,
    this.hintText,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSendButton = false;
  bool _isDialogLoading = false;

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
    if (message.isNotEmpty && !widget.isLoading && !widget.isLoadingHistory) {
      widget.onSendMessage(message, widget.conversationId);
      _textController.clear();
      _focusNode.requestFocus();
    }
  }

  void _showHistoryDialog() async {
    setState(() {
      _isDialogLoading = true;
    });

    final conversations =
        await ConversationService.getConversations(widget.userId);

    setState(() {
      _isDialogLoading = false;
    });

    if (!mounted) return;

    // Get l10n from the current context before showing dialog
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (context) => ConversationHistoryDialog(
        conversations: conversations,
        userId: widget.userId,
        l10n: l10n,
        // Pass l10n from parent context
        onConversationSelected: (String conversationId) {
          Navigator.pop(context);
          widget.onSendMessage('', conversationId);
        },
        onNewConversation: () {
          Navigator.pop(context);
          widget.onSendMessage('new_conversation_with_animation', null);
        },
      ),
    );
  }

  void _showHistoryModal() async {
    setState(() {
      _isDialogLoading = true;
    });

    final conversations =
        await ConversationService.getConversations(widget.userId);

    setState(() {
      _isDialogLoading = false;
    });

    if (!mounted) return;

    // Get l10n from the current context before showing modal
    final l10n = context.l10n;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConversationHistoryModal(
        conversations: conversations,
        userId: widget.userId,
        l10n: l10n,
        onConversationSelected: (String conversationId) {
          Navigator.pop(context);
          widget.onSendMessage('', conversationId);
        },
        onNewConversation: () {
          Navigator.pop(context);
          widget.onSendMessage('new_conversation_with_animation', null);
        },
      ),
    );
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
    // Check if any loading is happening
    final bool isDisabled = widget.isLoading || widget.isLoadingHistory;

    return Container(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: MediaQuery.of(context).padding.bottom + 16.0,
        top: 16.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 5,
          ),
        ],
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text input field (at the top, occupying the full width)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.isLoadingHistory
                    ? 'Loading conversation...'
                    : (widget.hintText ?? context.l10n.typeMessage),
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.7),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
              ),
              cursorColor: customColor1,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              minLines: 1,
              enabled: !isDisabled,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),

          const SizedBox(height: 8),

          // Button row (at the bottom, history and send buttons side by side)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // History button (left side)
              AnimatedOpacity(
                opacity: !isDisabled ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: isDisabled || _isDialogLoading
                      ? null
                      : _showHistoryModal,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: customColor0,
                    foregroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    elevation: 5,
                    padding: const EdgeInsets.all(12),
                  ),
                  child: _isDialogLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 24.0,
                        ),
                ),
              ),

              // Send button (right side)
              AnimatedOpacity(
                opacity: _showSendButton && !isDisabled ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: isDisabled ? null : _handleSendMessage,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: customColor0,
                    foregroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    elevation: 5,
                    padding: const EdgeInsets.all(12),
                  ),
                  child: Icon(
                    widget.isLoading || widget.isLoadingHistory
                        ? Icons.hourglass_empty
                        : Icons.arrow_upward,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
