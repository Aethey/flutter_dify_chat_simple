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

  test('maps Dio timeout and connection types', () {
    AppException from(DioExceptionType type) {
      return AppException.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: type,
        ),
      );
    }

    expect(from(DioExceptionType.connectionTimeout).code, 'CONNECTION_TIMEOUT');
    expect(from(DioExceptionType.receiveTimeout).code, 'RECEIVE_TIMEOUT');
    expect(from(DioExceptionType.sendTimeout).code, 'SEND_TIMEOUT');
    expect(from(DioExceptionType.connectionError).code, 'CONNECTION_ERROR');
    expect(from(DioExceptionType.cancel).code, 'REQUEST_CANCELLED');
    expect(from(DioExceptionType.unknown).code, 'NETWORK_ERROR');
  });

  test('parses JSON string and fallback error bodies', () {
    final fromJsonString = AppException.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 500,
          data: '{"code":"SERVER_ERROR","message":"oops"}',
        ),
      ),
    );
    expect(fromJsonString.code, 'SERVER_ERROR');
    expect(fromJsonString.message, 'oops');

    final fromPlain = AppException.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 500,
          data: 'not-json {',
        ),
      ),
    );
    expect(fromPlain.code, 'SERVER_ERROR');
    expect(fromPlain.message, 'not-json {');

    final fromEmpty = AppException.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 502,
          data: null,
        ),
      ),
    );
    expect(fromEmpty.code, 'SERVER_ERROR');
    expect(fromEmpty.statusCode, 502);
  });

  test('toString keeps codes the UI parser understands', () {
    expect(
      const AppException(
        code: 'SERVER_ERROR',
        statusCode: 500,
        message: 'boom',
      ).toString(),
      'SERVER_ERROR:500:boom',
    );
    expect(
      const AppException(code: 'NETWORK_ERROR', message: 'down').toString(),
      'NETWORK_ERROR:down',
    );
    expect(
      const AppException(code: 'CONNECTION_TIMEOUT').toString(),
      'CONNECTION_TIMEOUT',
    );
    expect(
      const AppException(code: 'CUSTOM', message: 'x').toString(),
      'CUSTOM:x',
    );
  });
}
