import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/conversation.dart';

/// SharedPreferences storage for conversation summaries.
class ConversationLocalDataSource {
  static const String _keyPrefix = 'chat_history_';

  Future<void> save({
    required String userId,
    required String conversationId,
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$userId';
    final history = prefs.getStringList(key) ?? [];

    bool exists = false;
    final updatedHistory = history.map((item) {
      final conversation = jsonDecode(item) as Map<String, dynamic>;
      if (conversation['id'] == conversationId) {
        exists = true;
        return jsonEncode({
          'id': conversationId,
          'name': name ?? conversation['name'] ?? 'Chat',
          'created_at': conversation['created_at'],
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        });
      }
      return item;
    }).toList();

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

  Future<List<Conversation>> list(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$userId';
    final history = prefs.getStringList(key) ?? [];

    return history
        .map((item) =>
            Conversation.fromMap(jsonDecode(item) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> delete({
    required String userId,
    required String conversationId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$userId';
    final history = prefs.getStringList(key) ?? [];

    final updatedHistory = history.where((item) {
      final conversation = jsonDecode(item) as Map<String, dynamic>;
      return conversation['id'] != conversationId;
    }).toList();

    await prefs.setStringList(key, updatedHistory);
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}-${_pad(date.month)}-${_pad(date.day)} ${_pad(date.hour)}:${_pad(date.minute)}';
  }

  String _pad(int number) {
    return number.toString().padLeft(2, '0');
  }
}
