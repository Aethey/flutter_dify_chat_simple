// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'chat_bot_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Chat Bot SDK';

  @override
  String get chatTitle => 'Chat Assistant';

  @override
  String get initialMessage => 'Hello! How can I help you today?';

  @override
  String get resetChat => 'Reset chat';

  @override
  String get resetChatConfirmation => 'This will clear the entire chat history. Continue?';

  @override
  String get deleteChatConfirmation => 'Are you sure you want to delete this conversation history?';

  @override
  String get cancel => 'CANCEL';

  @override
  String get reset => 'RESET';

  @override
  String get delete => 'DELETE';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get startConversation => 'Start a conversation';

  @override
  String get typeToBegin => 'Type a message to begin';

  @override
  String get errorTitle => 'An error occurred';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String networkError(String message) {
    return 'Network error: $message';
  }

  @override
  String get networkErrorDesc => 'Network error. Please check your connection.';

  @override
  String get retry => 'Retry';

  @override
  String get connectionTimeout => 'Connection timeout: Could not connect to the server';

  @override
  String get receiveTimeout => 'Receive timeout: Failed to receive response from server';

  @override
  String get sendTimeout => 'Send timeout: Failed to send request';

  @override
  String get connectionError => 'Connection error: Please check your internet connection';

  @override
  String get requestCancelled => 'Request was cancelled';

  @override
  String serverError(String statusCode, String message) {
    return 'Server error (HTTP $statusCode): $message';
  }

  @override
  String get logToday => 'Today';

  @override
  String get logYesterday => 'Yesterday';

  @override
  String get conversationHistory => 'Conversation History';

  @override
  String get noConversationHistory => 'No conversation history';

  @override
  String get loadingConversation => 'Loading conversation...';
}
