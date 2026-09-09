// Smoke test for the example app.
//
// The example reads its configuration from a `.env` file in `main()`. Tests do
// not run `main()`, so this file loads equivalent values with `dotenv.testLoad`
// and initializes the SDK before pumping the widget tree.

import 'package:chat_bot_sdk/chat_bot_sdk.dart';
import 'package:chat_bot_sdk_example/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadEnvAndInitSdk() async {
  await dotenv.testLoad(
    fileInput: 'DIFY_API_KEY=test-key\n'
        'DIFY_API_ENDPOINT=https://api.dify.ai/v1\n',
  );
  ChatBotSdk.initialize(
    apiKey: 'test-key',
    apiEndpoint: 'https://api.dify.ai/v1',
  );
}

void main() {
  testWidgets('renders the demo home screen', (tester) async {
    await _loadEnvAndInitSdk();

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Current Configuration'), findsOneWidget);
    expect(find.text('Start a Conversation'), findsOneWidget);
    expect(find.text('Start Chat'), findsOneWidget);
    expect(find.text('Conversation History'), findsOneWidget);
  });

  testWidgets('opens the chat page from the home screen', (tester) async {
    await _loadEnvAndInitSdk();

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Chat'));
    await tester.pumpAndSettle();

    expect(find.text('AI Assistant'), findsOneWidget);

    // Fire the delayed welcome-message timer so no timers leak at teardown.
    await tester.pump(const Duration(seconds: 1));
  });
}
