import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_stream_chunk.dart';
import '../models/dify_dtos.dart';

/// Incremental parser for Dify POST /chat-messages SSE.
class DifySseParser {
  String _buffer = '';
  var completeAnswer = '';
  String? conversationId;

  List<ChatStreamChunk> addUtf8(List<int> bytes) {
    _buffer += utf8.decode(bytes, allowMalformed: true);
    return _drainCompletedEvents();
  }

  List<ChatStreamChunk> addText(String text) {
    _buffer += text;
    return _drainCompletedEvents();
  }

  List<ChatStreamChunk> finish() {
    final chunks = <ChatStreamChunk>[];
    if (_buffer.trim().isNotEmpty) {
      chunks.addAll(_chunksFromRaw(_buffer));
      _buffer = '';
    }
    if (completeAnswer.isNotEmpty) {
      chunks.add(
        ChatStreamChunk(
          message: ChatMessage.assistant(
            content: completeAnswer,
            status: MessageStatus.sent,
          ),
          conversationId: conversationId,
        ),
      );
    }
    return chunks;
  }

  List<ChatStreamChunk> _drainCompletedEvents() {
    final chunks = <ChatStreamChunk>[];
    while (true) {
      final separator = _sseSeparator(_buffer);
      if (separator == null) break;
      final index = _buffer.indexOf(separator);
      final rawEvent = _buffer.substring(0, index);
      _buffer = _buffer.substring(index + separator.length);
      chunks.addAll(_chunksFromRaw(rawEvent));
    }
    return chunks;
  }

  List<ChatStreamChunk> _chunksFromRaw(String rawEvent) {
    final chunks = <ChatStreamChunk>[];
    for (final frame in _sseFrames(rawEvent)) {
      final parsed = _parseChatEvent(
        frame.data,
        completeAnswer,
        sseEventName: frame.eventName,
      );
      if (parsed == null) continue;
      final chunk = _applyParsed(parsed);
      if (chunk != null) chunks.add(chunk);
    }
    return chunks;
  }

  ChatStreamChunk? _applyParsed(_ParsedChatEvent parsed) {
    if (parsed.conversationId != null) {
      conversationId = parsed.conversationId;
    }
    if (parsed.replaceAnswer != null) {
      completeAnswer = parsed.replaceAnswer!;
    } else if (parsed.appendAnswer != null) {
      completeAnswer += parsed.appendAnswer!;
    }
    if (!parsed.emit) return null;
    return ChatStreamChunk(
      message: ChatMessage.assistant(
        content: completeAnswer,
        status: parsed.isError
            ? MessageStatus.error
            : parsed.isEnd
                ? MessageStatus.sent
                : MessageStatus.streaming,
      ),
      conversationId: conversationId,
    );
  }
}

String? _sseSeparator(String buffer) {
  if (buffer.contains('\r\n\r\n')) return '\r\n\r\n';
  if (buffer.contains('\n\n')) return '\n\n';
  return null;
}

List<_SseFrame> _sseFrames(String rawEvent) {
  String? eventName;
  final dataLines = <String>[];
  for (final line in rawEvent.split(RegExp(r'\r?\n'))) {
    if (line.startsWith('event:')) {
      var value = line.substring(6);
      if (value.startsWith(' ')) value = value.substring(1);
      eventName = value.trim();
    } else if (line.startsWith('data:')) {
      var value = line.substring(5);
      if (value.startsWith(' ')) value = value.substring(1);
      dataLines.add(value);
    }
  }
  if (dataLines.isEmpty) return const [];
  return [_SseFrame(eventName: eventName, data: dataLines.join('\n'))];
}

_ParsedChatEvent? _parseChatEvent(
  String payload,
  String currentAnswer, {
  String? sseEventName,
}) {
  final trimmed = payload.trim();
  if (trimmed.isEmpty || sseEventName == 'ping' || trimmed == 'ping') {
    return null;
  }
  if (trimmed == '[DONE]') {
    return const _ParsedChatEvent(emit: true, isEnd: true);
  }

  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is! Map) return null;
    final dto = DifySseEventDto.fromJson(Map<String, dynamic>.from(decoded));
    final event = dto.event ?? sseEventName;
    final conversationId = dto.conversationId;

    switch (event) {
      case 'message':
      case 'agent_message':
        return _ParsedChatEvent(
          appendAnswer: dto.answer ?? '',
          conversationId: conversationId,
          emit: true,
        );
      case 'text_chunk':
        final text = dto.data?.text ?? dto.text ?? '';
        return _ParsedChatEvent(
          appendAnswer: text,
          conversationId: conversationId,
          emit: text.isNotEmpty,
        );
      case 'message_replace':
        return _ParsedChatEvent(
          replaceAnswer: dto.answer ?? '',
          conversationId: conversationId,
          emit: true,
        );
      case 'message_end':
        return _ParsedChatEvent(
          conversationId: conversationId,
          emit: true,
          isEnd: true,
        );
      case 'error':
        return _ParsedChatEvent(
          replaceAnswer: 'Error: ${dto.message ?? 'Unknown error'}',
          emit: true,
          isEnd: true,
          isError: true,
        );
      case 'node_finished':
        return _answerFromNodeFinished(dto, currentAnswer, conversationId);
      case 'workflow_finished':
        return _answerFromWorkflowFinished(dto, currentAnswer, conversationId);
      case 'ping':
      case 'workflow_started':
      case 'node_started':
      case 'node_retry':
      case 'tts_message':
      case 'tts_message_end':
      case 'agent_thought':
      case 'agent_log':
      case 'message_file':
      case 'reasoning_chunk':
        return _ParsedChatEvent(conversationId: conversationId);
      default:
        debugPrint('Ignored chat event: $event');
        return _ParsedChatEvent(conversationId: conversationId);
    }
  } catch (e) {
    debugPrint('Failed to parse SSE JSON: $e, content: $trimmed');
    return null;
  }
}

_ParsedChatEvent? _answerFromNodeFinished(
  DifySseEventDto dto,
  String currentAnswer,
  String? conversationId,
) {
  final data = dto.data;
  if (data == null) return null;
  final status = data.status;
  if (status != null && status != 'succeeded') return null;

  final outputs = data.outputs;
  final extracted = answerFromOutputs(outputs);
  if (extracted == null || extracted.isEmpty) return null;

  final nodeType = data.nodeType;
  final hasAnswerKey = outputs != null && outputs['answer'] is String;
  if (nodeType == 'answer' || hasAnswerKey) {
    return _ParsedChatEvent(
      replaceAnswer: extracted,
      conversationId: conversationId,
      emit: true,
    );
  }
  if ((nodeType == 'llm' || nodeType == 'agent') && currentAnswer.isEmpty) {
    return _ParsedChatEvent(
      replaceAnswer: extracted,
      conversationId: conversationId,
      emit: true,
    );
  }
  return null;
}

_ParsedChatEvent _answerFromWorkflowFinished(
  DifySseEventDto dto,
  String currentAnswer,
  String? conversationId,
) {
  final extracted = answerFromOutputs(dto.data?.outputs);
  if (extracted != null && extracted.isNotEmpty && currentAnswer.isEmpty) {
    return _ParsedChatEvent(
      replaceAnswer: extracted,
      conversationId: conversationId,
      emit: true,
      isEnd: true,
    );
  }
  return _ParsedChatEvent(
    conversationId: conversationId,
    emit: currentAnswer.isNotEmpty,
    isEnd: true,
  );
}

/// Pulls reply text from Dify node/workflow `outputs`.
@visibleForTesting
String? answerFromOutputs(dynamic outputs) {
  if (outputs is! Map) return null;
  final map = Map<String, dynamic>.from(outputs);
  for (final key in const ['answer', 'text', 'result', 'output']) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) return value;
  }
  final strings = map.values
      .whereType<String>()
      .where((value) => value.trim().isNotEmpty)
      .toList();
  if (strings.length == 1) return strings.single;
  return null;
}

class _SseFrame {
  const _SseFrame({this.eventName, required this.data});

  final String? eventName;
  final String data;
}

class _ParsedChatEvent {
  const _ParsedChatEvent({
    this.appendAnswer,
    this.replaceAnswer,
    this.conversationId,
    this.emit = false,
    this.isEnd = false,
    this.isError = false,
  });

  final String? appendAnswer;
  final String? replaceAnswer;
  final String? conversationId;
  final bool emit;
  final bool isEnd;
  final bool isError;
}
