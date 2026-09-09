import 'package:chat_bot_sdk/src/data/models/dify_dtos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chat request serializes Dify snake_case fields', () {
    const request = DifyChatMessageRequestDto(
      query: 'Hello',
      inputs: {},
      responseMode: 'streaming',
      user: 'user-1',
      conversationId: 'conv-1',
      files: [
        DifyChatFileDto(
          type: 'image',
          transferMethod: 'local_file',
          uploadFileId: 'file-1',
        ),
      ],
    );

    expect(request.toJson(), {
      'query': 'Hello',
      'inputs': <String, dynamic>{},
      'response_mode': 'streaming',
      'user': 'user-1',
      'conversation_id': 'conv-1',
      'files': [
        {
          'type': 'image',
          'transfer_method': 'local_file',
          'upload_file_id': 'file-1',
        },
      ],
    });
  });

  test('upload response maps mime_type', () {
    final dto = DifyUploadedFileDto.fromJson({
      'id': 'abc',
      'name': 'a.png',
      'mime_type': 'image/png',
      'size': 12,
    });
    expect(dto.id, 'abc');
    expect(dto.mimeType, 'image/png');
    expect(dto.size, 12);
  });

  test('error body maps code and message', () {
    final dto = DifyErrorDto.fromJson({
      'code': 'model_currently_not_support',
      'message': 'not stt',
      'status': 400,
    });
    expect(dto.code, 'model_currently_not_support');
    expect(dto.status, 400);
  });
}
