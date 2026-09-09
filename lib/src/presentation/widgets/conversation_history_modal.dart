import 'package:chat_bot_sdk/localization/chat_bot_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/conversation.dart';

/// Conversation history sheet: list + swipe-to-delete, styled like ChatPage.
///
/// Stateless: the list is owned by the caller as a [ValueListenable], so a
/// deletion rebuilds only the list body, not the sheet chrome.
class ConversationHistoryModal extends StatelessWidget {
  final ValueListenable<List<Conversation>> conversations;
  final Function(String) onConversationSelected;
  final VoidCallback? onNewConversation;

  /// Performs the actual delete (API/local). Thrown errors cancel the swipe.
  final Future<void> Function(String conversationId) onDeleteConversation;

  /// Notifies the owner to drop the row from [conversations].
  final void Function(String conversationId) onConversationRemoved;
  final AppLocalizations l10n;

  const ConversationHistoryModal({
    super.key,
    required this.conversations,
    required this.onConversationSelected,
    this.onNewConversation,
    required this.onDeleteConversation,
    required this.onConversationRemoved,
    required this.l10n,
  });

  Future<bool> _confirmAndDelete(
    BuildContext context,
    Conversation conversation,
  ) async {
    final accent = Theme.of(context).colorScheme.primary;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(l10n.delete),
          content: Text(l10n.deleteChatConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel, style: TextStyle(color: accent)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                l10n.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return false;
    try {
      await onDeleteConversation(conversation.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final day = DateTime(date.year, date.month, date.day);
    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    if (day == today) {
      return '${l10n.logToday}  $time';
    }
    if (day == yesterday) {
      return '${l10n.logYesterday}  $time';
    }
    return '${date.month}/${date.day}  $time';
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: accent),
                ),
                Expanded(
                  child: Text(
                    l10n.conversationHistory,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ),
                if (onNewConversation != null)
                  IconButton(
                    tooltip: l10n.startConversation,
                    onPressed: onNewConversation,
                    icon: Icon(Icons.add, color: accent),
                  )
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            // Only this body rebuilds when a conversation is removed.
            child: ValueListenableBuilder<List<Conversation>>(
              valueListenable: conversations,
              builder: (context, items, _) {
                if (items.isEmpty) {
                  return _buildEmptyState(context, accent);
                }
                return _buildList(context, items, accent);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color accent) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: accent),
          const SizedBox(height: 16),
          Text(
            l10n.noConversationHistory,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: accent),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<Conversation> items,
    Color accent,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final conversation = items[index];
        final date = DateTime.fromMillisecondsSinceEpoch(
          conversation.updatedAt * 1000,
        );
        return Dismissible(
          key: ValueKey(conversation.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmAndDelete(context, conversation),
          onDismissed: (_) => onConversationRemoved(conversation.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onConversationSelected(conversation.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: accent.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation.name.isEmpty
                                ? l10n.chatTitle
                                : conversation.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(date),
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
