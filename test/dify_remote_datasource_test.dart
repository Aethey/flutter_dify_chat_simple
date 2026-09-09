import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chat_bot_sdk/src/core/error/app_exception.dart';
import 'package:chat_bot_sdk/src/core/network/dify_api_client.dart';
import 'package:chat_bot_sdk/src/data/datasources/dify_remote_datasource.dart';
import 'package:chat_bot_sdk/src/domain/entities/chat_file_attachment.dart';
import 'package:chat_bot_sdk/src/domain/entities/chat_message.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DifyRemoteDataSource _source(
  void Function(RequestOptions options, RequestInterceptorHandler handler)
      onRequest,
) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/v1'));
  dio.interceptors.add(InterceptorsWrapper(onRequest: onRequest));
  return DifyRemoteDataSource(DifyApiClient(dio: dio));
}

void _resolveJson(
  RequestInterceptorHandler handler,
  RequestOptions options, {
  required int statusCode,
  required Object data,
}) {
  handler.resolve(
    Response<Map<String, dynamic>>(
      requestOptions: options,
      statusCode: statusCode,
      data: data is Map<String, dynamic>
          ? data
          : Map<String, dynamic>.from(data as Map),
    ),
  );
}

void _resolveSse(
  RequestInterceptorHandler handler,
  RequestOptions options,
  String sse,
) {
  handler.resolve(
    Response<ResponseBody>(
      requestOptions: options,
      statusCode: 200,
      data: ResponseBody(
        Stream<Uint8List>.fromIterable([
          Uint8List.fromList(utf8.encode(sse)),
        ]),
        200,
        headers: {
          Headers.contentTypeHeader: ['text/event-stream'],
        },
      ),
    ),
  );
}

void main() {
  test('fetchConversationHistory reverses Dify rows into chat messages',
      () async {
    final source = _source((options, handler) {
      expect(options.method, 'GET');
      expect(options.path, '/messages');
      expect(options.queryParameters['conversation_id'], 'c1');
      expect(options.queryParameters['user'], 'user-1');
      _resolveJson(
        handler,
        options,
        statusCode: 200,
        data: {
          'data': [
            {'query': 'second', 'answer': 'a2'},
            {'query': '', 'answer': 'orphan'},
            {'query': 'first', 'answer': 'a1'},
          ],
        },
      );
    });

    final messages = await source.fetchConversationHistory(
      conversationId: 'c1',
      userId: 'user-1',
    );

    expect(
      messages.map((m) => '${m.role.name}:${m.content}').toList(),
      [
        'user:first',
        'assistant:a1',
        'assistant:orphan',
        'user:second',
        'assistant:a2',
      ],
    );
    expect(messages.last.status, MessageStatus.sent);
  });

  test('fetchConversationHistory wraps Dio errors', () async {
    final source = _source((options, handler) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        ),
      );
    });

    expect(
      () => source.fetchConversationHistory(
        conversationId: 'c1',
        userId: 'user-1',
      ),
      throwsA(
        isA<AppException>().having(
          (e) => e.code,
          'code',
          'CONNECTION_TIMEOUT',
        ),
      ),
    );
  });

  test('streamChatMessage parses SSE and uses a fallback query for files',
      () async {
    Map<String, dynamic>? body;
    const sse = '''
data: {"event":"message","conversation_id":"c1","answer":"Hi"}

data: {"event":"message_end","conversation_id":"c1"}

''';
    final source = _source((options, handler) {
      expect(options.method, 'POST');
      expect(options.path, '/chat-messages');
      body = Map<String, dynamic>.from(options.data as Map);
      _resolveSse(handler, options, sse);
    });

    const image = ChatFileAttachment(
      type: 'image',
      transferMethod: 'local_file',
      uploadFileId: 'file-1',
    );
    final chunks = await source
        .streamChatMessage(
          query: '  ',
          userId: 'user-1',
          conversationId: '',
          files: const [image],
        )
        .toList();

    expect(body?['query'], difyFileOnlyQuery);
    expect(body?.containsKey('conversation_id'), isFalse);
    expect(body?['files'], isNotEmpty);
    expect(chunks, isNotEmpty);
    expect(chunks.last.message.content, 'Hi');
    expect(chunks.last.conversationId, 'c1');
  });

  test('streamChatMessage wraps Dio errors', () async {
    final source = _source((options, handler) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      );
    });

    expect(
      () => source.streamChatMessage(query: 'Hi', userId: 'user-1').toList(),
      throwsA(
        isA<AppException>().having(
          (e) => e.code,
          'code',
          'CONNECTION_ERROR',
        ),
      ),
    );
  });

  test('uploadFile maps the Dify payload and file extensions', () async {
    final dir = await Directory.systemTemp.createTemp('dify_upload');
    addTearDown(() => dir.delete(recursive: true));

    final names = [
      'a.png',
      'a.jpg',
      'a.jpeg',
      'a.gif',
      'a.webp',
      'a.m4a',
      'a.mp3',
      'a.wav',
      'a.amr',
      'a.bin',
    ];

    for (final name in names) {
      final file = File('${dir.path}/$name')..writeAsBytesSync(const [1, 2, 3]);
      final source = _source((options, handler) {
        expect(options.path, '/files/upload');
        _resolveJson(
          handler,
          options,
          statusCode: 200,
          data: {
            'id': 'id-$name',
            'name': name,
            'mime_type': 'image/png',
            'size': 3,
          },
        );
      });

      final uploaded = await source.uploadFile(
        filePath: file.path,
        userId: 'user-1',
      );
      expect(uploaded.id, 'id-$name');
      expect(uploaded.name, name);
      expect(uploaded.size, 3);
    }
  });

  test('uploadFile uses the local basename when Dify omits name', () async {
    final dir = await Directory.systemTemp.createTemp('dify_upload');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/photo.png')..writeAsBytesSync(const [1]);

    final source = _source((options, handler) {
      _resolveJson(
        handler,
        options,
        statusCode: 200,
        data: {'id': 'abc'},
      );
    });

    final uploaded = await source.uploadFile(
      filePath: file.path,
      userId: 'user-1',
    );
    expect(uploaded.id, 'abc');
    expect(uploaded.name, 'photo.png');
    expect(uploaded.size, 0);
  });

  test('uploadFile wraps Dio errors', () async {
    final dir = await Directory.systemTemp.createTemp('dify_upload');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/a.png')..writeAsBytesSync(const [1]);

    final source = _source((options, handler) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'code': 'invalid', 'message': 'nope'},
          ),
        ),
      );
    });

    expect(
      () => source.uploadFile(filePath: file.path, userId: 'user-1'),
      throwsA(isA<AppException>().having((e) => e.code, 'code', 'invalid')),
    );
  });

  test('audioToText returns text and defaults unknown audio types', () async {
    final dir = await Directory.systemTemp.createTemp('dify_audio');
    addTearDown(() => dir.delete(recursive: true));

    for (final name in ['a.m4a', 'a.mp3', 'a.wav', 'a.amr', 'a.ogg']) {
      final file = File('${dir.path}/$name')..writeAsBytesSync(const [1]);
      final source = _source((options, handler) {
        expect(options.path, '/audio-to-text');
        _resolveJson(
          handler,
          options,
          statusCode: 200,
          data: name == 'a.ogg' ? <String, dynamic>{} : {'text': 'hello $name'},
        );
      });

      final text = await source.audioToText(
        filePath: file.path,
        userId: 'user-1',
      );
      if (name == 'a.ogg') {
        expect(text, '');
      } else {
        expect(text, 'hello $name');
      }
    }
  });

  test('audioToText wraps Dio errors', () async {
    final dir = await Directory.systemTemp.createTemp('dify_audio');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/a.m4a')..writeAsBytesSync(const [1]);

    final source = _source((options, handler) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.sendTimeout,
        ),
      );
    });

    expect(
      () => source.audioToText(filePath: file.path, userId: 'user-1'),
      throwsA(
        isA<AppException>().having((e) => e.code, 'code', 'SEND_TIMEOUT'),
      ),
    );
  });
}
