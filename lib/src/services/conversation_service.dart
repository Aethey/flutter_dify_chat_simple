import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing conversation history
class ConversationService {
  static const String _keyPrefix = 'chat_history_';

  /// Save a conversation to the history
  static Future<void> saveConversation({
    required String userId,
    required String conversationId,
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$userId';
    final history = prefs.getStringList(key) ?? [];

    // Check if the conversation already exists
    bool exists = false;
    final updatedHistory = history.map((item) {
      final conversation = jsonDecode(item) as Map<String, dynamic>;
      if (conversation['id'] == conversationId) {
        exists = true;
        // Update the conversation
        return jsonEncode({
          'id': conversationId,
          'name': name ?? conversation['name'] ?? 'Chat',
          'created_at': conversation['created_at'],
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        });
      }
      return item;
    }).toList();

    // Add new conversation if it doesn't exist
    if (!exists) {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      updatedHistory.add(jsonEncode({
        'id': conversationId,
        'name': name ?? 'Chat ${_formatTimestamp(timestamp)}',
        'created_at': timestamp,
        'updated_at': timestamp,
      }));
    }

    await prefs.setStringList(key, updatedHistory);
  }

  /// Get all conversations for a user
  static Future<List<Map<String, dynamic>>> getConversations(
      String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$userId';
    final history = prefs.getStringList(key) ?? [];

    return history
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList()
      ..sort(
          (a, b) => (b['updated_at'] as int).compareTo(a['updated_at'] as int));
  }

  /// Delete a conversation
  static Future<void> deleteConversation(
      String userId, String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$userId';
    final history = prefs.getStringList(key) ?? [];

    final updatedHistory = history.where((item) {
      final conversation = jsonDecode(item) as Map<String, dynamic>;
      return conversation['id'] != conversationId;
    }).toList();

    await prefs.setStringList(key, updatedHistory);
  }

  /// Format timestamp into readable string
  static String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}-${_pad(date.month)}-${_pad(date.day)} ${_pad(date.hour)}:${_pad(date.minute)}';
  }

  static String _pad(int number) {
    return number.toString().padLeft(2, '0');
  }
}
