import 'package:chat_bot_sdk/l10n/app_localizations.dart';
import 'package:chat_bot_sdk/src/domain/entities/chat_message.dart';
import 'package:chat_bot_sdk/src/presentation/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: ChatBotLocalizationsSetup.localizationsDelegates,
    supportedLocales: ChatBotLocalizationsSetup.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('shows DeepSeek reply after think tags, not a blank bubble', (
    tester,
  ) async {
    const content =
        '<think>\n<!--dify-deepseek-reasoning-->我们只需要简单回应。\n</think>Hello! How can I assist you today?';

    await tester.pumpWidget(
      _app(
        MessageBubble(
          message: ChatMessage.assistant(
            content: content,
            status: MessageStatus.sent,
          ),
        ),
      ),
    );

    expect(find.textContaining('Hello'), findsWidgets);
    expect(find.text('AI is thinking...'), findsNothing);
  });

  testWidgets('shows thinking widget while think block is still open', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        MessageBubble(
          message: ChatMessage.assistant(
            content: '<think>reasoning',
            status: MessageStatus.streaming,
          ),
          thinkingWidget: const Text('AI is thinking...'),
        ),
      ),
    );

    expect(find.text('AI is thinking...'), findsOneWidget);
  });

  testWidgets('shows empty-reply text instead of a blank bubble', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        MessageBubble(
          message: ChatMessage.assistant(
            content: '',
            status: MessageStatus.error,
          ),
        ),
      ),
    );

    expect(
      find.textContaining('No reply was returned'),
      findsOneWidget,
    );
  });
}
