import 'package:chat_bot_sdk/custom/color.dart';
import 'package:chat_bot_sdk/localization/chat_bot_localizations.dart';
import 'package:chat_bot_sdk/src/services/conversation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// iOS-style modal view to display conversation history
class ConversationHistoryModal extends StatefulWidget {
  final List<Map<String, dynamic>> conversations;
  final String userId;
  final Function(String) onConversationSelected;
  final VoidCallback onNewConversation;
  final AppLocalizations l10n;

  const ConversationHistoryModal({
    super.key,
    required this.conversations,
    required this.userId,
    required this.onConversationSelected,
    required this.onNewConversation,
    required this.l10n,
  });

  @override
  State<ConversationHistoryModal> createState() => _ConversationHistoryModalState();
}

class _ConversationHistoryModalState extends State<ConversationHistoryModal> {
  List<Map<String, dynamic>> _conversations = [];
  
  @override
  void initState() {
    super.initState();
    _conversations = List.from(widget.conversations);
  }

  Future<void> _deleteConversation(String conversationId) async {
    // iOS-style confirmation dialog
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: Text(widget.l10n.reset),
          content: Text(widget.l10n.resetChatConfirmation),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(widget.l10n.cancel),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text(widget.l10n.reset),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ConversationService.deleteConversation(widget.userId, conversationId);
                // Update local state instead of closing modal
                setState(() {
                  _conversations.removeWhere((conv) => conv['id'] == conversationId);
                });
              },
            ),
          ],
        );
      },
    );
  }

  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final conversationDate = DateTime(date.year, date.month, date.day);

    if (conversationDate == today) {
      return widget.l10n.logToday;
    } else if (conversationDate == yesterday) {
      return widget.l10n.logYesterday;
    } else {
      // Format as "M/D"
      return '${date.month}/${date.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = customColor0 ?? Colors.blue;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // iOS-style handle for modal dragging
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey4,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          // Header with title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.l10n.conversationHistory,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          
          // Main content - GridView instead of ListView
          Expanded(
            child: _conversations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.blueGrey.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.l10n.noConversationHistory,
                          style: const TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: _conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = _conversations[index];
                        final DateTime date = DateTime.fromMillisecondsSinceEpoch(
                          (conversation['created_at'] as int) * 1000,
                        );

                        final String formattedDate = _getFormattedDate(date);

                        // Create a card-like container with shadow and rounded corners
                        return GestureDetector(
                          onTap: () => widget.onConversationSelected(conversation['id']),
                          child: Container(
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoColors.systemGrey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Main content of the card
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Date icon
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            Icons.calendar_month,
                                            size: 20,
                                            color: color,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // Date text
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: CupertinoColors.label,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Delete button (top-right corner)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child: const Icon(
                                        Icons.delete,
                                        color: Colors.blueGrey,
                                        size: 28,
                                      ),
                                    onPressed: () => _deleteConversation(conversation['id']),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          
          // Bottom buttons: New conversation and Close
          Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 20 + MediaQuery.of(context).padding.bottom,
              top: 16,
            ),
            child: Row(
              children: [
                // New conversation button
                Expanded(
                  flex: 1,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: widget.onNewConversation,
                    child: const Icon(
                      Icons.add,
                      color: CupertinoColors.white,
                      size: 20,
                    ),
                  ),
                ),
                
                const SizedBox(width: 48),
                
                // Close button
                Expanded(
                  flex: 1,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(12),
                    child: const Icon(
                      Icons.close_rounded,
                      color: CupertinoColors.systemGrey,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 