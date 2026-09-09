import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../l10n/app_localizations.dart';
import '../../domain/entities/chat_history.dart';

part 'chat_state.freezed.dart';

/// Error type for localized error handling
enum ChatErrorType {
  generic,
  network,
  connectionTimeout,
  receiveTimeout,
  sendTimeout,
  connectionError,
  requestCancelled,
  serverError,
  api,
  emptyAssistantReply,
}

@freezed
abstract class ErrorInfo with _$ErrorInfo {
  const factory ErrorInfo({
    required ChatErrorType type,
    Map<String, dynamic>? params,
  }) = _ErrorInfo;
}

@freezed
abstract class ChatState with _$ChatState {
  const ChatState._();

  const factory ChatState({
    required ChatHistory chatHistory,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingHistory,
    String? errorMessage,
    ChatErrorType? errorType,
    Map<String, dynamic>? errorParams,
    String? conversationId,
    @Default(true) bool isFirstDisplay,
  }) = _ChatState;

  String? getLocalizedErrorMessage(BuildContext context) {
    if (errorMessage == null || errorType == null) return null;

    switch (errorType!) {
      case ChatErrorType.connectionTimeout:
        return context.l10n.connectionTimeout;
      case ChatErrorType.receiveTimeout:
        return context.l10n.receiveTimeout;
      case ChatErrorType.sendTimeout:
        return context.l10n.sendTimeout;
      case ChatErrorType.connectionError:
        return context.l10n.connectionError;
      case ChatErrorType.requestCancelled:
        return context.l10n.requestCancelled;
      case ChatErrorType.serverError:
        final statusCode = errorParams?['statusCode'] ?? '';
        final message = errorParams?['message'] ?? '';
        return context.l10n.serverError(
          statusCode.toString(),
          message.toString(),
        );
      case ChatErrorType.network:
        final message = errorParams?['message'] ?? '';
        return context.l10n.networkError(message);
      case ChatErrorType.api:
        final code = errorParams?['code'] ?? '';
        final message = errorParams?['message'] ?? '';
        return context.l10n.apiError(code.toString(), message.toString());
      case ChatErrorType.generic:
        return context.l10n.genericError;
      case ChatErrorType.emptyAssistantReply:
        return context.l10n.emptyAssistantReply;
    }
  }
}
