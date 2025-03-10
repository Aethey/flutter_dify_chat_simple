import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message.dart';

/// A widget to display a chat message bubble
class MessageBubble extends StatelessWidget {
  /// The message to display
  final ChatMessage message;
  
  /// Optional custom widget to display when the bot is thinking
  final Widget? thinkingWidget;
  
  /// Optional custom widget to display when the message is loading/streaming
  final Widget? loadingWidget;
  
  /// Constructor
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
            : null, // No decoration for AI messages to blend with background
        child: _buildContentWithStatus(context),
      ),
    );
  }
  
  Widget _buildContentWithStatus(BuildContext context) {
    final isUser = message.role == MessageRole.user;   
    if (isUser) {
      // For user messages: text + timestamp
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.content,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ],
      );
    } else {
      // For AI messages
      if ((message.status == MessageStatus.streaming || message.status == MessageStatus.sending) && 
          message.content.isEmpty && thinkingWidget != null) {
        // Show custom thinking widget if in streaming/sending state and content is empty
        return thinkingWidget!;
      } else if (message.status == MessageStatus.streaming || message.status == MessageStatus.sending) {
        // For messages being streamed/sent
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Message content (or "Thinking..." placeholder)
            MarkdownBody(
              data: message.content.isEmpty 
                  ? '_Thinking..._' 
                  : message.content,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                code: TextStyle(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                codeblockDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onTapLink: (text, href, title) {
                if (href != null) {
                  _launchUrl(href);
                }
              },
            ),
            // Loading indicator - use custom if provided, otherwise use default
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: loadingWidget ?? const Text('Loaidng...'),
            ),
          ],
        );
      } else {
        // For completed AI messages
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MarkdownBody(
              data: message.content,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
                code: TextStyle(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                codeblockDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
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
    }
  }
  
  
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
} 