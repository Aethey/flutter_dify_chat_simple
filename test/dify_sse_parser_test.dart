import 'dart:io';

import 'package:chat_bot_sdk/src/data/datasources/dify_sse_parser.dart';
import 'package:chat_bot_sdk/src/domain/entities/chat_message.dart';
import 'package:chat_bot_sdk/src/presentation/widgets/assistant_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final fixtureFile = File('test/fixtures/dify_chatflow_hello.sse');

  String parseToAnswer(String sse, {int chunkSize = 0}) {
    final parser = DifySseParser();
    if (chunkSize <= 0) {
      parser.addText(sse);
    } else {
      final units = sse.codeUnits;
      for (var i = 0; i < units.length; i += chunkSize) {
        final end = (i + chunkSize < units.length) ? i + chunkSize : units.length;
        parser.addUtf8(units.sublist(i, end));
      }
    }
    final chunks = parser.finish();
    expect(chunks, isNotEmpty);
    return chunks.last.message.content;
  }

  test('parses captured Chatflow SSE including message events', () {
    final sse = fixtureFile.readAsStringSync();
    final content = parseToAnswer(sse);
    expect(content, contains('Hello'));
    expect(content, contains('</think>'));
    final visible = visibleAssistantContent(content, streaming: false);
    expect(visible, contains('Hello'));
    expect(visible, isNot(contains('<think>')));
  });

  test('parses captured SSE in 16-byte chunks', () {
    final sse = fixtureFile.readAsStringSync();
    final content = parseToAnswer(sse, chunkSize: 16);
    expect(
      visibleAssistantContent(content, streaming: false),
      contains('Hello'),
    );
  });

  test('extracts answer from node_finished when message events are absent', () {
    const sse = '''
data: {"event":"workflow_started","conversation_id":"c1"}

data: {"event":"node_started","conversation_id":"c1","data":{"node_type":"llm"}}

data: {"event":"node_finished","conversation_id":"c1","data":{"node_type":"llm","status":"succeeded","outputs":{"text":"<think>hidden</think>Visible reply","reasoning_content":"","usage":{},"finish_reason":"stop"}}}

data: {"event":"node_finished","conversation_id":"c1","data":{"node_type":"answer","status":"succeeded","outputs":{"answer":"<think>hidden</think>Visible reply","files":[]}}}

data: {"event":"workflow_finished","conversation_id":"c1","data":{"status":"succeeded","outputs":{"answer":"<think>hidden</think>Visible reply","files":[]}}}

''';
    final content = parseToAnswer(sse);
    expect(content, '<think>hidden</think>Visible reply');
    expect(
      visibleAssistantContent(content, streaming: false),
      'Visible reply',
    );
  });

  test('skips ping SSE event line and still reads the next data frame', () {
    const sse = '''
event: ping

data: {"event":"message","conversation_id":"c1","answer":"Hi"}

data: {"event":"message_end","conversation_id":"c1"}

''';
    final parser = DifySseParser();
    parser.addText(sse);
    final chunks = parser.finish();
    expect(chunks.first.message.content, 'Hi');
    expect(chunks.last.message.status, MessageStatus.sent);
  });
}
