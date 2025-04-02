import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/sdk_config.dart';
import '../models/chat_history.dart';
import '../models/message.dart';
import 'conversation_service.dart';

/// Service for handling chat API communication
class ChatService {
  late final Dio _dio;
  final SdkConfig _config = SdkConfig.instance;

  /// Last received conversation ID from API response
  String? lastConversationId;

  /// Constructor
  ChatService() {
    _dio = Dio(BaseOptions(
      baseUrl: _config.apiEndpoint,
      headers: {
        'Authorization': 'Bearer ${_config.apiKey}',
        'Content-Type': 'application/json',
      },
      // タイムアウト設定を追加
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // ログインターセプターを追加
    _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (object) {
          debugPrint('API LOG: $object');
        }));
  }

  /// Fetch conversation history messages
  Future<List<ChatMessage>> fetchConversationHistory(
      String conversationId, String userId,
      {int limit = 20, String? firstId}) async {
    try {
      debugPrint('Fetching conversation history for ID: $conversationId');

      final Map<String, dynamic> queryParams = {
        'conversation_id': conversationId,
        'user': userId,
        'limit': limit.toString(),
      };

      if (firstId != null) {
        queryParams['first_id'] = firstId;
      }

      final response = await _dio.get(
        '/messages',
        queryParameters: queryParams,
      );

      debugPrint('Conversation history response: ${response.statusCode}');

      final List<ChatMessage> messages = [];
      final data = response.data['data'] as List<dynamic>;

      // Messages are returned in reverse order (newest first), so we need to reverse them
      for (var i = data.length - 1; i >= 0; i--) {
        final item = data[i];
        if (item['query'] != null && item['query'].toString().isNotEmpty) {
          // Add user message
          messages.add(ChatMessage.user(
            content: item['query'],
          ));
        }

        if (item['answer'] != null) {
          // Add assistant response
          messages.add(ChatMessage.assistant(
            content: item['answer'],
            status: MessageStatus.sent,
          ));
        }
      }

      return messages;
    } on DioException catch (e) {
      final errorMsg = _handleDioError(e);
      debugPrint('DIO error fetching history: $errorMsg');
      throw Exception(errorMsg);
    } catch (e) {
      debugPrint('General error fetching history: $e');
      throw Exception('Error fetching conversation history: $e');
    }
  }

  /// Send a chat message and get a single response
  Future<ChatMessage> sendMessage(ChatHistory chatHistory, String userID,
      {String? conversationId}) async {
    try {
      final lastUserMessage = chatHistory.lastUserMessage;
      if (lastUserMessage == null) {
        throw Exception('No user message to respond to');
      }

      // 准备请求数据
      final requestData = {
        'query': lastUserMessage.content,
        'user': userID,
        'response_mode': 'blocking', // 阻塞模式
      };

      // 如果提供了对话ID，添加到请求中
      if (conversationId != null && conversationId.isNotEmpty) {
        requestData['conversation_id'] = conversationId;
      }

      // 发送请求
      final response = await _dio.post(
        '/chat-messages',
        data: requestData,
      );

      // 检查响应
      if (response.statusCode != 200) {
        throw Exception('Error sending message: ${response.statusCode}');
      }

      // 解析响应
      final data = response.data;
      final answer = data['answer'] as String;

      // 保存对话ID
      final responseConversationId = data['conversation_id'] as String?;
      if (responseConversationId != null) {
        lastConversationId = responseConversationId;
        await ConversationService.saveConversation(
          userId: userID,
          conversationId: responseConversationId,
        );
      }

      // 创建并返回助手消息
      return ChatMessage.assistant(
        content: answer,
      );
    } on DioException catch (e) {
      final errorMsg = _handleDioError(e);
      debugPrint('DIO error sending message: $errorMsg');
      throw Exception(errorMsg);
    } catch (e) {
      debugPrint('General error sending message: $e');
      throw Exception('Error sending message: $e');
    }
  }

  /// Send a chat message and stream the response
  Stream<ChatMessage> streamMessage(ChatHistory chatHistory, String userID,
      {String? conversationId}) async* {
    try {
      debugPrint('APIエンドポイント: ${_config.apiEndpoint}');
      debugPrint(
          'APIキー: ${_config.apiKey.substring(0, 4)}...${_config.apiKey.substring(_config.apiKey.length - 4)}');

      final requestBody = {
        'query': chatHistory.lastUserMessage?.content ?? '',
        'inputs': {},
        'response_mode': 'streaming',
        'user': userID,
      };

      // Add conversation ID if provided
      if (conversationId != null && conversationId.isNotEmpty) {
        requestBody['conversation_id'] = conversationId;
        debugPrint('会話ID: $conversationId');
      }

      debugPrint('リクエスト内容: $requestBody');

      final response = await _dio.post(
        '/chat-messages',
        data: requestBody,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
      );

      debugPrint('SSEストリーミング開始');

      // 正しいストリーム処理方法に修正
      final responseStream = response.data.stream as Stream<Uint8List>;
      String buffer = '';
      String completeAnswer = '';
      String? responseConversationId;

      await for (final chunk in responseStream) {
        final decodedChunk = utf8.decode(chunk);
        buffer += decodedChunk;
        debugPrint('受信データ: $decodedChunk');

        // SSEはdata:で始まる行で区切られる
        while (buffer.contains('\n\n') || buffer.contains('data:')) {
          int index = buffer.indexOf('\n\n');
          if (index == -1) {
            index = buffer.indexOf('data:');
            if (index > 0) {
              buffer = buffer.substring(index);
              continue;
            }
          }

          String chunk;
          if (buffer.contains('\n\n')) {
            index = buffer.indexOf('\n\n');
            chunk = buffer.substring(0, index);
            buffer = buffer.substring(index + 2);
          } else {
            int nextIndex = buffer.indexOf('data:', 5);
            if (nextIndex != -1) {
              chunk = buffer.substring(0, nextIndex);
              buffer = buffer.substring(nextIndex);
            } else {
              break; // 完全なチャンクがまだない
            }
          }

          if (chunk.startsWith('data:')) {
            // 'data: ' の後のコンテンツを取得
            final content = chunk.substring(5).trim();
            if (content == '[DONE]') {
              debugPrint('ストリーミング完了マーカー受信: [DONE]');
              continue;
            }

            try {
              final json = jsonDecode(content);
              debugPrint('パースしたJSON: $json');

              // イベントタイプに基づいて処理
              final event = json['event'] as String?;
              switch (event) {
                case 'message':
                  final answer = json['answer'] as String? ?? '';
                  completeAnswer += answer;
                  yield ChatMessage.assistant(
                    content: completeAnswer,
                    status: MessageStatus.streaming,
                  );
                  break;

                case 'message_end':
                  debugPrint('メッセージ終了イベント受信');
                  // メタデータを取得
                  final metadata = json['metadata'];
                  responseConversationId = json['conversation_id'] as String?;
                  if (metadata != null) {
                    debugPrint('メタデータ: $metadata');
                  }

                  // Save conversation to history and update lastConversationId
                  if (responseConversationId != null) {
                    lastConversationId = responseConversationId;
                    await ConversationService.saveConversation(
                      userId: userID,
                      conversationId: responseConversationId,
                    );
                  }

                  yield ChatMessage.assistant(
                    content: completeAnswer,
                    status: MessageStatus.sent,
                  );
                  break;

                case 'workflow_started':
                case 'node_started':
                case 'node_finished':
                case 'workflow_finished':
                  // ワークフロー関連のイベントは無視またはログに記録
                  debugPrint('ワークフローイベント受信: $event');
                  break;

                case 'tts_message':
                case 'tts_message_end':
                  // TTSイベントは現在無視
                  debugPrint('TTSイベント受信: $event');
                  break;

                case 'error':
                  debugPrint('エラーイベント受信: ${json['message']}');
                  yield ChatMessage.assistant(
                    content: 'Error: ${json['message'] ?? 'Unknown error'}',
                    status: MessageStatus.error,
                  );
                  break;

                default:
                  debugPrint('未知のイベント受信: $event');
                  break;
              }
            } catch (e) {
              debugPrint('JSONパース失敗: $e, 内容: $content');
            }
          }
        }
      }
    } on DioException catch (e) {
      final errorMsg = _handleDioError(e);
      debugPrint('DIOエラー: $errorMsg');
      yield ChatMessage.assistant(
          content: 'Error: $errorMsg', status: MessageStatus.error);
    } catch (e) {
      debugPrint('一般エラー: $e');
      yield ChatMessage.assistant(
          content: 'Error: $e', status: MessageStatus.error);
    }
  }

  /// DIOエラーを処理して詳細なエラーメッセージを返す
  /// エラーメッセージは後でUIレイヤーで多言語化される
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        return 'SERVER_ERROR:$statusCode:${responseData ?? e.message}';
      case DioExceptionType.connectionTimeout:
        return 'CONNECTION_TIMEOUT';
      case DioExceptionType.receiveTimeout:
        return 'RECEIVE_TIMEOUT';
      case DioExceptionType.sendTimeout:
        return 'SEND_TIMEOUT';
      case DioExceptionType.connectionError:
        return 'CONNECTION_ERROR';
      case DioExceptionType.cancel:
        return 'REQUEST_CANCELLED';
      default:
        return 'NETWORK_ERROR:${e.message}';
    }
  }
}
