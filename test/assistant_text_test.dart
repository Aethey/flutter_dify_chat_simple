import 'package:chat_bot_sdk/src/presentation/widgets/assistant_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hides unclosed think block while streaming', () {
    const raw = '<think>\n<!--dify-deepseek-reasoning-->我们只需要简单回应。';
    expect(visibleAssistantContent(raw, streaming: true), isEmpty);
  });

  test('shows text after closed think block', () {
    const raw =
        '<think>\n<!--dify-deepseek-reasoning-->我们只需要简单回应。\n</think>Hello! How can I assist you today?';
    expect(
      visibleAssistantContent(raw, streaming: false),
      'Hello! How can I assist you today?',
    );
  });
}
