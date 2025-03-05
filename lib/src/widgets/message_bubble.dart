import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/message.dart';

/// A widget to display a chat message bubble
class MessageBubble extends StatelessWidget {
  /// The message to display
  final ChatMessage message;
  
  /// Constructor
  const MessageBubble({
    super.key,
    required this.message,
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
        decoration: BoxDecoration(
          color: isUser 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message content
            _buildMessageContent(context),
            
            // Loading indicator or timestamp
            if (message.status == MessageStatus.streaming || 
                message.status == MessageStatus.sending)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SpinKitThreeBounce(
                  color: isUser 
                      ? Colors.white70 
                      : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  size: 16,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  _formatTimestamp(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isUser 
                        ? Colors.white70 
                        : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMessageContent(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    
    if (isUser) {
      return Text(
        message.content,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      );
    } else {
      // Use Markdown for bot messages
      return MarkdownBody(
        data: message.content.isEmpty 
            ? '_Thinking..._' 
            : message.content,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
          code: TextStyle(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
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
      );
    }
  }
  
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
  
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
} 