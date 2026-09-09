/// Strips Dify/DeepSeek reasoning wrappers so Markdown can show the reply.
String visibleAssistantContent(String content, {required bool streaming}) {
  var text = content.replaceAll(
    RegExp(r'<think\b[^>]*>[\s\S]*?</think>', caseSensitive: false),
    '',
  );
  if (streaming) {
    text = text.replaceAll(
      RegExp(r'<think\b[^>]*>[\s\S]*', caseSensitive: false),
      '',
    );
  }
  return text.trim();
}
