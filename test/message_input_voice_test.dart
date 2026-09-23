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
              onSendMessage: (_, _, [_]) {},
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

  testWidgets('focus moves text above the toolbar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates:
              ChatBotLocalizationsSetup.localizationsDelegates,
          supportedLocales: ChatBotLocalizationsSetup.supportedLocales,
          home: Scaffold(
            body: MessageInput(
              onSendMessage: (_, _, [_]) {},
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
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      isTrue,
    );
    expect(focused.left, lessThan(collapsed.left - 20));
    expect(focused.width, greaterThan(collapsed.width + 40));
    expect(focused.height, closeTo(44, 2));
    expect(send.top, greaterThanOrEqualTo(focused.bottom - 2));
    expect(find.byKey(const Key('chat_input_expand')), findsNothing);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final unfocused = tester.getRect(find.byType(TextField));
    expect(unfocused.width, closeTo(collapsed.width, 2));
    expect(unfocused.height, closeTo(collapsed.height, 2));
  });

  testWidgets('text and composer shell grow together on a new line', (
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
              onSendMessage: (_, _, [_]) {},
              userId: '123',
              inputBarConfig: const ChatInputBarConfig(),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    final fieldBefore = tester.getSize(find.byType(TextField));
    final shellBefore = tester.getSize(
      find.byKey(const Key('chat_input_shell')),
    );

    await tester.enterText(find.byType(TextField), 'first\nsecond');
    await tester.pump();
    final fieldAfter = tester.getSize(find.byType(TextField));
    final shellAfter = tester.getSize(
      find.byKey(const Key('chat_input_shell')),
    );
    expect(fieldAfter.height - fieldBefore.height, closeTo(24, 1));
    expect(
      shellAfter.height - shellBefore.height,
      closeTo(fieldAfter.height - fieldBefore.height, 1),
    );

    await tester.pump(const Duration(milliseconds: 90));
    expect(
      tester.getSize(find.byKey(const Key('chat_input_shell'))).height,
      closeTo(shellAfter.height, 1),
    );
  });

  testWidgets('first line remains visible when typing during focus change', (
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
              onSendMessage: (_, _, [_]) {},
              userId: '123',
              inputBarConfig: const ChatInputBarConfig(),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.enterText(find.byType(TextField), 'FIRST\nsecond');
    await tester.pump();

    final field = tester.getRect(find.byType(TextField));
    expect(field.height, greaterThanOrEqualTo(68));
    final editable = tester.state<EditableTextState>(find.byType(EditableText));
    final firstLine = editable.renderEditable.localToGlobal(
      editable.renderEditable
          .getLocalRectForCaret(const TextPosition(offset: 0))
          .center,
    );
    expect(firstLine.dy, greaterThanOrEqualTo(field.top));
    expect(firstLine.dy, lessThan(field.bottom));
  });

  testWidgets('composer keeps growing after five lines and offers fullscreen', (
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
              onSendMessage: (_, _, [_]) {},
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
    final oneLine = tester.getRect(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'a\nb\nc\nd\ne');
    await tester.pumpAndSettle();
    final fiveLines = tester.getRect(find.byType(TextField));

    expect(fiveLines.height, greaterThan(oneLine.height + 80));
    expect(find.byKey(const Key('chat_input_expand')), findsNothing);

    await tester.enterText(find.byType(TextField), 'a\nb\nc\nd\ne\nf');
    await tester.pumpAndSettle();
    final sixLines = tester.getRect(find.byType(TextField));
    expect(sixLines.height, greaterThan(fiveLines.height + 20));
    expect(tester.widget<TextField>(find.byType(TextField)).maxLines, isNull);

    expect(find.byKey(const Key('chat_input_expand')), findsOneWidget);
    expect(find.byIcon(Icons.open_in_full), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'a\nb\nc\nd\ne\nf\ng');
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(TextField)).height,
      greaterThan(sixLines.height + 20),
    );

    final longText = List.generate(30, (index) => 'line $index').join('\n');
    await tester.enterText(find.byType(TextField), longText);
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(TextField)).height,
      lessThan(tester.view.physicalSize.height),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      longText,
    );
    expect(tester.takeException(), isNull);

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
