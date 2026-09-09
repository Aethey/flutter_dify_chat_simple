import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import '../models/dify_dtos.dart';

part 'dify_api.g.dart';

/// Generated Dify Service API client.
@RestApi()
abstract class DifyApi {
  factory DifyApi(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _DifyApi;

  @GET('/messages')
  Future<DifyMessagesResponseDto> getMessages({
    @Query('conversation_id') required String conversationId,
    @Query('user') required String user,
    @Query('limit') int limit = 20,
    @Query('first_id') String? firstId,
  });

  @POST('/chat-messages')
  @DioResponseType(ResponseType.stream)
  @Headers(<String, dynamic>{
    'Accept': 'text/event-stream',
    'Content-Type': 'application/json',
  })
  Stream<Uint8List> streamChatMessages(
    @Body() DifyChatMessageRequestDto body,
  );

  @POST('/files/upload')
  @MultiPart()
  Future<DifyUploadedFileDto> uploadFile({
    @Part(name: 'file') required File file,
    @Part(name: 'user') required String user,
    @PartMap() Map<String, dynamic>? metadata,
  });

  @POST('/audio-to-text')
  @MultiPart()
  Future<DifyAudioToTextDto> audioToText({
    @Part(name: 'file') required File file,
    @Part(name: 'user') required String user,
    @PartMap() Map<String, dynamic>? metadata,
  });
}
