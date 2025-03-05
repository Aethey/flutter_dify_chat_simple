import 'package:uuid/uuid.dart';

/// Role of the message sender
enum MessageRole {
  /// User sent message
  user,
  
  /// AI assistant sent message
  assistant,
  
  /// System message (typically not visible to user)
  system
}

/// Status of a message
enum MessageStatus {
  /// Message is being sent
  sending,
  
  /// Message was successfully sent and received a response
  sent,
  
  /// Message failed to send
  error,
  
  /// Message is streaming a response
  streaming
}

/// Represents a chat message
class ChatMessage {
  /// Unique identifier for the message
  final String id;
  
  /// Content of the message
  String content;
  
  /// Role of the message sender
  final MessageRole role;
  
  /// Current status of the message
  MessageStatus status;
  
  /// Timestamp when the message was created
  final DateTime timestamp;
  
  /// Constructor
  ChatMessage({
    String? id,
    required this.content,
    required this.role,
    this.status = MessageStatus.sent,
    DateTime? timestamp,
  }) : 
    id = id ?? const Uuid().v4(),
    timestamp = timestamp ?? DateTime.now();
  
  /// Create a user message
  static ChatMessage user({
    required String content,
    MessageStatus status = MessageStatus.sent,
  }) {
    return ChatMessage(
      content: content,
      role: MessageRole.user,
      status: status,
    );
  }
  
  /// Create an assistant message
  static ChatMessage assistant({
    required String content,
    MessageStatus status = MessageStatus.sent,
  }) {
    return ChatMessage(
      content: content,
      role: MessageRole.assistant,
      status: status,
    );
  }
  
  /// Create a system message
  static ChatMessage system({
    required String content,
  }) {
    return ChatMessage(
      content: content,
      role: MessageRole.system,
    );
  }
  
  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  /// Create a copy of this message with updated fields
  ChatMessage copyWith({
    String? content,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id,
      content: content ?? this.content,
      role: role,
      status: status ?? this.status,
      timestamp: timestamp,
    );
  }
} 