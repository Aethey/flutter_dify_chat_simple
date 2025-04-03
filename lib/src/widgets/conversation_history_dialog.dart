
import 'package:chat_bot_sdk/custom/color.dart';
import 'package:chat_bot_sdk/localization/chat_bot_localizations.dart';
import 'package:chat_bot_sdk/src/services/conversation_service.dart';
import 'package:flutter/material.dart';

/// Dialog to display conversation history
class ConversationHistoryDialog extends StatelessWidget {
  final List<Map<String, dynamic>> conversations;
  final String userId;
  final Function(String) onConversationSelected;
  final VoidCallback onNewConversation;
  final AppLocalizations l10n; // Add l10n as a required field

  const ConversationHistoryDialog({
    super.key,
    required this.conversations,
    required this.userId,
    required this.onConversationSelected,
    required this.onNewConversation,
    required this.l10n, // Make l10n required
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
                    l10n.conversationHistory, // Use l10n for localized title
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
                            l10n.noConversationHistory,
                            // Use l10n for empty state message
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
                label: Text(l10n.startConversation), // Use l10n for button text
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
      return l10n.logToday;
    } else if (conversationDate == yesterday) {
      return l10n.logYesterday;
    } else {
      // Format as "Jun 15, 2023"
      return '${date.month}/${date.day}, ${date.year}';
    }
  }
}
