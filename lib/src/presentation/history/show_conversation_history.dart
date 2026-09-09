import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../domain/entities/conversation.dart';
import '../widgets/conversation_history_modal.dart';

/// Opens the conversation history sheet from chat or any host screen.
Future<void> showConversationHistory({
  required BuildContext context,
  required Future<List<Conversation>> Function() loadConversations,
  required Future<void> Function(String conversationId) deleteConversation,
  void Function(String conversationId)? onConversationSelected,
  VoidCallback? onNewConversation,
  ThemeData? themeData,
  Locale? locale,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Localizations(
        locale:
            locale ??
            Localizations.maybeLocaleOf(context) ??
            const Locale('en'),
        delegates: ChatBotLocalizationsSetup.localizationsDelegates,
        child: Theme(
          data: themeData ?? Theme.of(context),
          child: _HistorySheetLoader(
            loadConversations: loadConversations,
            deleteConversation: deleteConversation,
            onConversationSelected: onConversationSelected,
            onNewConversation: onNewConversation,
          ),
        ),
      );
    },
  );
}

class _HistorySheetLoader extends StatefulWidget {
  final Future<List<Conversation>> Function() loadConversations;
  final Future<void> Function(String conversationId) deleteConversation;
  final void Function(String conversationId)? onConversationSelected;
  final VoidCallback? onNewConversation;

  const _HistorySheetLoader({
    required this.loadConversations,
    required this.deleteConversation,
    this.onConversationSelected,
    this.onNewConversation,
  });

  @override
  State<_HistorySheetLoader> createState() => _HistorySheetLoaderState();
}

class _HistorySheetLoaderState extends State<_HistorySheetLoader> {
  /// Single owner of the list; deletions update it via [_removeConversation],
  /// so only the list body listening to it rebuilds.
  ValueNotifier<List<Conversation>>? _conversations;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _conversations?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final conversations = await widget.loadConversations();
    if (!mounted) return;
    // The only setState: swaps the loading box for the sheet content once.
    setState(() {
      _conversations = ValueNotifier(conversations);
    });
  }

  void _removeConversation(String conversationId) {
    final notifier = _conversations;
    if (notifier == null) return;
    notifier.value = notifier.value
        .where((item) => item.id != conversationId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _conversations;
    if (conversations == null) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return ConversationHistoryModal(
      conversations: conversations,
      l10n: context.l10n,
      onConversationSelected: (conversationId) {
        Navigator.pop(context);
        widget.onConversationSelected?.call(conversationId);
      },
      onNewConversation: widget.onNewConversation == null
          ? null
          : () {
              Navigator.pop(context);
              widget.onNewConversation!();
            },
      onDeleteConversation: widget.deleteConversation,
      onConversationRemoved: _removeConversation,
    );
  }
}
