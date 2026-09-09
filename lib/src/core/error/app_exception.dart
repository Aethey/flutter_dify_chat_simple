import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/dify_dtos.dart';

/// Normalized exception thrown by data sources.
class AppException implements Exception {
  /// Machine-readable error code used by the UI layer.
  final String code;

  /// Optional human-readable details.
  final String? message;

  /// Optional HTTP status code.
  final int? statusCode;

  const AppException({
    required this.code,
    this.message,
    this.statusCode,
  });

  factory AppException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.badResponse:
        final parsed = _difyErrorBody(error.response?.data);
        debugPrint(
          'API ERROR: status=${error.response?.statusCode} '
          'code=${parsed.code} message=${parsed.message}',
        );
        return AppException(
          code: parsed.code ?? 'SERVER_ERROR',
          statusCode: error.response?.statusCode,
          message: parsed.message ??
              '${error.response?.data ?? error.message}',
        );
      case DioExceptionType.connectionTimeout:
        return const AppException(code: 'CONNECTION_TIMEOUT');
      case DioExceptionType.receiveTimeout:
        return const AppException(code: 'RECEIVE_TIMEOUT');
      case DioExceptionType.sendTimeout:
        return const AppException(code: 'SEND_TIMEOUT');
      case DioExceptionType.connectionError:
        return const AppException(code: 'CONNECTION_ERROR');
      case DioExceptionType.cancel:
        return const AppException(code: 'REQUEST_CANCELLED');
      default:
        return AppException(
          code: 'NETWORK_ERROR',
          message: error.message,
        );
    }
  }

  @override
  String toString() {
    if (code == 'SERVER_ERROR') {
      return 'SERVER_ERROR:${statusCode ?? '?'}:${message ?? ''}';
    }
    if (code == 'NETWORK_ERROR') {
      return 'NETWORK_ERROR:${message ?? ''}';
    }
    return message == null || message!.isEmpty ? code : '$code:$message';
  }
}

class _DifyErrorBody {
  const _DifyErrorBody({this.code, this.message});

  final String? code;
  final String? message;
}

_DifyErrorBody _difyErrorBody(dynamic data) {
  Map<String, dynamic>? map;
  if (data is Map) {
    map = Map<String, dynamic>.from(data);
  } else if (data is String && data.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        map = Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return _DifyErrorBody(message: data);
    }
  }
  if (map == null) return const _DifyErrorBody();
  try {
    final dto = DifyErrorDto.fromJson(map);
    final code = dto.code;
    final message = dto.message;
    return _DifyErrorBody(
      code: (code == null || code.isEmpty) ? null : code,
      message: (message == null || message.isEmpty) ? null : message,
    );
  } catch (_) {
    final code = map['code']?.toString();
    final message = map['message']?.toString();
    return _DifyErrorBody(
      code: (code == null || code.isEmpty) ? null : code,
      message: (message == null || message.isEmpty) ? null : message,
    );
  }
}
