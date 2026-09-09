import 'dart:convert';

import 'package:chat_bot_sdk/src/data/datasources/conversation_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ConversationLocalDataSource source;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    source = ConversationLocalDataSource();
  });

  test('list is empty when nothing has been saved', () async {
    expect(await source.list('user-1'), isEmpty);
  });

  test('save inserts a named conversation', () async {
    await source.save(userId: 'user-1', conversationId: 'c1', name: 'First');

    final listed = await source.list('user-1');
    expect(listed.single.id, 'c1');
    expect(listed.single.name, 'First');
  });

  test('list sorts by updatedAt descending', () async {
    SharedPreferences.setMockInitialValues({
      'chat_history_user-1': [
        jsonEncode({
          'id': 'c1',
          'name': 'First',
          'created_at': 1,
          'updated_at': 10,
        }),
        jsonEncode({
          'id': 'c2',
          'name': 'Second',
          'created_at': 1,
          'updated_at': 20,
        }),
      ],
    });

    final listed = await source.list('user-1');
    expect(listed.map((c) => c.id), ['c2', 'c1']);
    expect(listed.first.name, 'Second');
  });

  test('save without a name uses a Chat timestamp', () async {
    await source.save(userId: 'user-1', conversationId: 'c1');

    final listed = await source.list('user-1');
    expect(listed.single.id, 'c1');
    expect(listed.single.name, startsWith('Chat '));
  });

  test('save with a blank name falls back to a Chat timestamp', () async {
    await source.save(userId: 'user-1', conversationId: 'c1', name: '   ');

    final listed = await source.list('user-1');
    expect(listed.single.name, startsWith('Chat '));
  });

  test('save updates an existing conversation and keeps createdAt', () async {
    await source.save(userId: 'user-1', conversationId: 'c1', name: 'Old');
    final createdAt = (await source.list('user-1')).single.createdAt;

    await source.save(userId: 'user-1', conversationId: 'c1', name: 'New');

    final listed = await source.list('user-1');
    expect(listed.single.name, 'New');
    expect(listed.single.createdAt, createdAt);
    expect(listed.single.updatedAt, greaterThanOrEqualTo(createdAt));
  });

  test('delete removes only the matching conversation', () async {
    await source.save(userId: 'user-1', conversationId: 'c1', name: 'Keep');
    await source.save(userId: 'user-1', conversationId: 'c2', name: 'Drop');

    await source.delete(userId: 'user-1', conversationId: 'c2');

    final listed = await source.list('user-1');
    expect(listed.map((c) => c.id), ['c1']);
  });

  test('conversations are isolated per user', () async {
    await source.save(userId: 'user-1', conversationId: 'c1', name: 'A');
    await source.save(userId: 'user-2', conversationId: 'c2', name: 'B');

    expect((await source.list('user-1')).single.id, 'c1');
    expect((await source.list('user-2')).single.id, 'c2');
  });
}
