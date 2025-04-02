import 'package:chat_bot_sdk/custom/color.dart';
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

    showDialog(
      context: context,
      builder: (context) => ConversationHistoryDialog(
        conversations: conversations,
        userId: widget.userId,
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
                      : _showHistoryDialog,
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

/// Dialog to display conversation history
class ConversationHistoryDialog extends StatelessWidget {
  final List<Map<String, dynamic>> conversations;
  final String userId;
  final Function(String) onConversationSelected;
  final VoidCallback onNewConversation;

  const ConversationHistoryDialog({
    super.key,
    required this.conversations,
    required this.userId,
    required this.onConversationSelected,
    required this.onNewConversation,
  });

  Future<void> _deleteConversation(
      BuildContext context, String conversationId) async {
    await ConversationService.deleteConversation(userId, conversationId);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Conversation History',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: customColor0,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
                minHeight: 100,
              ),
              width: double.maxFinite,
              child: conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversation history',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(top: 8.0),
                      shrinkWrap: true,
                      itemCount: conversations.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        final DateTime date =
                            DateTime.fromMillisecondsSinceEpoch(
                          (conversation['created_at'] as int) * 1000,
                        );

                        // Format date as "Jun 15, 2023" or today/yesterday
                        final String formattedDate =
                            _getFormattedDate(date, context);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 8.0),
                          title: Text(
                            // conversation['name'] ?? 'Chat ${index + 1}',
                            formattedDate,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // subtitle: Text(
                          //   formattedDate,
                          //   style: TextStyle(
                          //     color: Colors.grey[600],
                          //     fontSize: 14,
                          //   ),
                          // ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            foregroundColor: customColor0 ?? Colors.blue,
                            child: const Icon(Icons.chat_outlined),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteConversation(
                                context, conversation['id']),
                          ),
                          onTap: () =>
                              onConversationSelected(conversation['id']),
                        );
                      },
                    ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: onNewConversation,
                icon: const Icon(Icons.add),
                label: const Text('Start New Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: customColor0,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final conversationDate = DateTime(date.year, date.month, date.day);

    if (conversationDate == today) {
      return 'Today';
    } else if (conversationDate == yesterday) {
      return 'Yesterday';
    } else {
      // Format as "Jun 15, 2023"
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
