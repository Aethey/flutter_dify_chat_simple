import 'package:chat_bot_sdk/src/core/error/app_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses Dify hosted GPT-4 speech-to-text 400 body', () {
    final exception = AppException.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/audio-to-text'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/audio-to-text'),
          statusCode: 400,
          data: {
            'code': 'model_currently_not_support',
            'message':
                'Dify Hosted OpenAI trial currently not support the GPT-4 model.',
            'status': 400,
          },
        ),
      ),
    );

    expect(exception.statusCode, 400);
    expect(exception.code, 'model_currently_not_support');
    expect(exception.message, contains('GPT-4'));
  });
}
