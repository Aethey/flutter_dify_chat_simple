import 'package:chat_bot_sdk/l10n/app_localizations.dart';
import 'package:chat_bot_sdk/src/presentation/config/chat_input_bar_config.dart';
import 'package:chat_bot_sdk/src/presentation/widgets/message_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders microphone button when slot3 is voice', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates:
              ChatBotLocalizationsSetup.localizationsDelegates,
          supportedLocales: ChatBotLocalizationsSetup.supportedLocales,
          home: Scaffold(
            body: MessageInput(
              onSendMessage: (_, _, [__]) {},
              userId: '123',
              inputBarConfig: const ChatInputBarConfig(
                slot1: ChatInputSlot(action: ChatInputAction.history),
                slot2: ChatInputSlot(action: ChatInputAction.image),
                slot3: ChatInputSlot(action: ChatInputAction.voice),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('chat_input_voice')), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);
    expect(find.byKey(const Key('chat_input_expand')), findsNothing);
  });

  testWidgets('focus grows one line without stacking the toolbar', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates:
              ChatBotLocalizationsSetup.localizationsDelegates,
          supportedLocales: ChatBotLocalizationsSetup.supportedLocales,
          home: Scaffold(
            body: MessageInput(
              onSendMessage: (_, _, [__]) {},
              userId: '123',
              inputBarConfig: const ChatInputBarConfig(
                slot1: ChatInputSlot(action: ChatInputAction.history),
                slot2: ChatInputSlot(action: ChatInputAction.image),
                slot3: ChatInputSlot(action: ChatInputAction.voice),
              ),
            ),
          ),
        ),
      ),
    );

    final collapsed = tester.getRect(find.byType(TextField));
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    final focused = tester.getRect(find.byType(TextField));
    final send = tester.getRect(find.byIcon(Icons.arrow_upward));
    expect(focused.left, lessThan(collapsed.left - 20));
    expect(focused.width, greaterThan(collapsed.width + 40));
    expect(focused.height, closeTo(22, 8));
    expect(send.top, greaterThanOrEqualTo(focused.bottom - 2));
    expect(find.byKey(const Key('chat_input_expand')), findsNothing);
  });

  testWidgets('expand control appears on tier 2 and toggles fullscreen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates:
              ChatBotLocalizationsSetup.localizationsDelegates,
          supportedLocales: ChatBotLocalizationsSetup.supportedLocales,
          home: Scaffold(
            body: MessageInput(
              onSendMessage: (_, _, [__]) {},
              userId: '123',
              inputBarConfig: const ChatInputBarConfig(
                slot1: ChatInputSlot(action: ChatInputAction.history),
                slot2: ChatInputSlot(action: ChatInputAction.image),
                slot3: ChatInputSlot(action: ChatInputAction.voice),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'a\nb\nc\nd');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('chat_input_expand')), findsOneWidget);
    expect(find.byIcon(Icons.open_in_full), findsOneWidget);

    await tester.tap(find.byKey(const Key('chat_input_expand')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close_fullscreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('chat_input_expand')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.open_in_full), findsOneWidget);
  });

  test('default input bar config includes voice on slot3', () {
    const config = ChatInputBarConfig();
    expect(config.slot3.action, ChatInputAction.voice);
  });
}
