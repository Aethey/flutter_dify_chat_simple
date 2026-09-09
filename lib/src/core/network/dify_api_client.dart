import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/sdk_config.dart';

/// Thin Dio wrapper for Dify Service API calls.
class DifyApiClient {
  DifyApiClient({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  Dio get dio => _dio;

  static Dio _createDio() {
    final config = SdkConfig.instance;
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiEndpoint,
        headers: {
          'Authorization': 'Bearer ${config.apiKey}',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.contains('/chat-messages') &&
              options.responseType == ResponseType.stream) {
            options.receiveTimeout = const Duration(minutes: 5);
          }
          handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        // Stream responses cannot be logged as text; printing ResponseBody
        // is noisy and does not help debug SSE frames.
        responseBody: false,
        error: true,
        logPrint: (object) {
          debugPrint('API LOG: $object');
        },
      ),
    );

    return dio;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> postJson<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      options: (options ?? Options()).copyWith(
        contentType: 'application/json',
      ),
    );
  }

  Future<Response<ResponseBody>> postSse(
    String path, {
    required Object data,
  }) {
    return _dio.post<ResponseBody>(
      path,
      data: data,
      options: Options(
        responseType: ResponseType.stream,
        contentType: Headers.jsonContentType,
        headers: const {
          'Accept': 'text/event-stream',
        },
        receiveTimeout: const Duration(minutes: 5),
      ),
    );
  }

  Future<Response<T>> postForm<T>(
    String path, {
    required FormData data,
  }) {
    return _dio.post<T>(path, data: data);
  }
}
