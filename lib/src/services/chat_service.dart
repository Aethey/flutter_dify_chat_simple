import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/sdk_config.dart';
import '../models/chat_history.dart';
import '../models/message.dart';

/// Service for handling chat API communication
class ChatService {
  late final Dio _dio;
  final SdkConfig _config = SdkConfig.instance;
  
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
      }
    ));
  }
  
  /// Send a chat message and get a single response
  Future<ChatMessage> sendMessage(ChatHistory chatHistory) async {
    try {
      debugPrint('APIエンドポイント: ${_config.apiEndpoint}');
      debugPrint('APIキー: ${_config.apiKey.substring(0, 4)}...${_config.apiKey.substring(_config.apiKey.length - 4)}');
      
      final requestBody = {
        'query': chatHistory.lastUserMessage?.content ?? '',
        'inputs': {},
        'response_mode': 'blocking',
        'user': 'user-${DateTime.now().millisecondsSinceEpoch}',
        // 会話IDは不要なので削除
      };
      
      debugPrint('リクエスト内容: $requestBody');
      
      final response = await _dio.post(
        '/chat-messages',
        data: requestBody,
      );
      
      debugPrint('レスポンスコード: ${response.statusCode}');
      debugPrint('レスポンス内容: ${response.data}');
      
      return ChatMessage.assistant(content: response.data['answer'] ?? '');
    } on DioException catch (e) {
      final errorMsg = _handleDioError(e);
      debugPrint('DIOエラー: $errorMsg');
      throw Exception(errorMsg);
    } catch (e) {
      debugPrint('一般エラー: $e');
      throw Exception('Error: $e');
    }
  }
  
  /// Send a chat message and stream the response
  Stream<ChatMessage> streamMessage(ChatHistory chatHistory) async* {
    try {
      debugPrint('APIエンドポイント: ${_config.apiEndpoint}');
      debugPrint('APIキー: ${_config.apiKey.substring(0, 4)}...${_config.apiKey.substring(_config.apiKey.length - 4)}');
      
      final requestBody = {
        'query': chatHistory.lastUserMessage?.content ?? '',
        'inputs': {},
        'response_mode': 'streaming',
        'user': 'user-${DateTime.now().millisecondsSinceEpoch}',
        // 会話IDは不要なので削除
      };
      
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
                  if (metadata != null) {
                    debugPrint('メタデータ: $metadata');
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
      yield ChatMessage.assistant(content: 'Error: $errorMsg', status: MessageStatus.error);
    } catch (e) {
      debugPrint('一般エラー: $e');
      yield ChatMessage.assistant(content: 'Error: $e', status: MessageStatus.error);
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