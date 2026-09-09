import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../domain/entities/chat_message.dart';
import 'assistant_text.dart';

/// A widget to display a chat message bubble
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Widget? thinkingWidget;
  final Widget? loadingWidget;

  const MessageBubble({
    super.key,
    required this.message,
    this.thinkingWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: isUser
            ? BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: _buildContentWithStatus(context),
      ),
    );
  }

  Widget _buildContentWithStatus(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    if (isUser) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._buildAttachments(),
          if (message.content.isNotEmpty)
            Text(
              message.content,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
        ],
      );
    }

    final isStreaming =
        message.status == MessageStatus.streaming ||
        message.status == MessageStatus.sending;
    final visible = visibleAssistantContent(
      message.content,
      streaming: isStreaming,
    );

    if (isStreaming && visible.isEmpty && thinkingWidget != null) {
      return thinkingWidget!;
    }

    if (isStreaming) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          MarkdownBody(
            data: visible.isEmpty ? '_Thinking..._' : visible,
            styleSheet: _styleSheet(context, Colors.black),
            onTapLink: (text, href, title) {
              if (href != null) {
                _launchUrl(href);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: loadingWidget ?? const Text('Loading...'),
          ),
        ],
      );
    }

    final sentText = visible.isNotEmpty ? visible : '';
    if (sentText.isEmpty) {
      return Text(
        context.l10n.emptyAssistantReply,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 16,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MarkdownBody(
          data: sentText,
          styleSheet: _styleSheet(
            context,
            Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onTapLink: (text, href, title) {
            if (href != null) {
              _launchUrl(href);
            }
          },
        ),
      ],
    );
  }

  List<Widget> _buildAttachments() {
    final widgets = <Widget>[];
    for (final attachment in message.attachments) {
      if (attachment.type == 'image') {
        final path = attachment.localPath;
        if (path == null || path.isEmpty || !File(path).existsSync()) continue;
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(path), height: 160, fit: BoxFit.cover),
            ),
          ),
        );
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.insert_drive_file, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  attachment.name ?? attachment.type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  MarkdownStyleSheet _styleSheet(BuildContext context, Color textColor) {
    return MarkdownStyleSheet(
      p: TextStyle(color: textColor, fontSize: 16),
      code: TextStyle(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 14,
      ),
      codeblockDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
