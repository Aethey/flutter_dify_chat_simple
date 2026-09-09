import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import '../../core/error/app_exception.dart';
import '../../core/network/dify_api_client.dart';
import '../../domain/entities/chat_file_attachment.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_stream_chunk.dart';
import '../../domain/entities/uploaded_file.dart';
import '../models/dify_dtos.dart';
import 'dify_api.dart';
import 'dify_sse_parser.dart';

/// Dify requires `query`. Used when the user sends files without typing text.
const difyFileOnlyQuery = 'Please look at the attached file.';

/// Builds the `query` field for POST /chat-messages.
String difyRequestQuery(String query, List<ChatFileAttachment> files) {
  final trimmed = query.trim();
  if (trimmed.isNotEmpty) return trimmed;
  if (files.isNotEmpty) return difyFileOnlyQuery;
  return trimmed;
}

/// Dify Service API calls.
class DifyRemoteDataSource {
  DifyRemoteDataSource(this._client) : _api = DifyApi(_client.dio);

  final DifyApiClient _client;
  final DifyApi _api;

  Future<List<ChatMessage>> fetchConversationHistory({
    required String conversationId,
    required String userId,
    int limit = 20,
    String? firstId,
  }) async {
    try {
      final response = await _api.getMessages(
        conversationId: conversationId,
        user: userId,
        limit: limit,
        firstId: firstId,
      );

      final messages = <ChatMessage>[];
      for (var i = response.data.length - 1; i >= 0; i--) {
        final item = response.data[i];
        final query = item.query;
        if (query != null && query.isNotEmpty) {
          messages.add(ChatMessage.user(content: query));
        }
        if (item.answer != null) {
          messages.add(ChatMessage.assistant(
            content: item.answer!,
            status: MessageStatus.sent,
          ));
        }
      }

      return messages;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Stream<ChatStreamChunk> streamChatMessage({
    required String query,
    required String userId,
    String? conversationId,
    List<ChatFileAttachment> files = const [],
  }) async* {
    try {
      final resolvedQuery = difyRequestQuery(query, files);
      if (query.trim().isEmpty && files.isNotEmpty) {
        debugPrint(
          'Dify chat: empty query with ${files.length} file(s); '
          'sending fallback query',
        );
      }

      final request = DifyChatMessageRequestDto(
        query: resolvedQuery,
        inputs: const <String, dynamic>{},
        responseMode: 'streaming',
        user: userId,
        conversationId:
            conversationId != null && conversationId.isNotEmpty
                ? conversationId
                : null,
        files: files.isEmpty
            ? null
            : files
                .map((file) => DifyChatFileDto.fromJson(file.toApiJson()))
                .toList(),
      );

      final parser = DifySseParser();
      await for (final chunk in _api.streamChatMessages(request)) {
        for (final event in parser.addUtf8(chunk)) {
          yield event;
        }
      }
      for (final event in parser.finish()) {
        yield event;
      }
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<UploadedFile> uploadFile({
    required String filePath,
    required String userId,
  }) async {
    try {
      final uploaded = await _api.uploadFile(
        file: File(filePath),
        user: userId,
        metadata: {
          'file_contentType': _mediaTypeForPath(filePath).toString(),
          'file_fileName': p.basename(filePath),
        },
      );
      return UploadedFile(
        id: uploaded.id,
        name: uploaded.name ?? p.basename(filePath),
        mimeType: uploaded.mimeType,
        size: uploaded.size ?? 0,
      );
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<String> audioToText({
    required String filePath,
    required String userId,
  }) async {
    try {
      final result = await _api.audioToText(
        file: File(filePath),
        user: userId,
        metadata: {
          'file_contentType': _audioMediaTypeForPath(filePath).toString(),
          'file_fileName': p.basename(filePath),
        },
      );
      return result.text ?? '';
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  MediaType _mediaTypeForPath(String filePath) {
    switch (p.extension(filePath).toLowerCase()) {
      case '.png':
        return MediaType('image', 'png');
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.gif':
        return MediaType('image', 'gif');
      case '.webp':
        return MediaType('image', 'webp');
      case '.m4a':
        return MediaType('audio', 'm4a');
      case '.mp3':
        return MediaType('audio', 'mp3');
      case '.wav':
        return MediaType('audio', 'wav');
      case '.amr':
        return MediaType('audio', 'amr');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  MediaType _audioMediaTypeForPath(String filePath) {
    switch (p.extension(filePath).toLowerCase()) {
      case '.m4a':
        return MediaType('audio', 'm4a');
      case '.mp3':
        return MediaType('audio', 'mp3');
      case '.wav':
        return MediaType('audio', 'wav');
      case '.amr':
        return MediaType('audio', 'amr');
      default:
        return MediaType('audio', 'm4a');
    }
  }
}
