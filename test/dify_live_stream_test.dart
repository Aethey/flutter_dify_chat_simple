import 'dart:io';

import 'package:chat_bot_sdk/src/core/config/sdk_config.dart';
import 'package:chat_bot_sdk/src/core/network/dify_api_client.dart';
import 'package:chat_bot_sdk/src/data/datasources/dify_remote_datasource.dart';
import 'package:chat_bot_sdk/src/presentation/widgets/assistant_text.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, String> _readEnv(File file) {
  final map = <String, String>{};
  for (final raw in file.readAsLinesSync()) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final index = line.indexOf('=');
    if (index <= 0) continue;
    map[line.substring(0, index)] = line.substring(index + 1);
  }
  return map;
}

void main() {
  final envFile = File('example/.env');
  final liveEnabled = Platform.environment['ENABLE_DIFY_LIVE_TEST'] == '1';

  test(
    'live Dify Chatflow stream returns visible assistant text',
    () async {
      final env = _readEnv(envFile);
      final apiKey = env['DIFY_API_KEY'];
      final endpoint = env['DIFY_API_ENDPOINT'];
      expect(apiKey, isNotNull);
      expect(endpoint, isNotNull);

      SdkConfig.instance.initialize(apiKey: apiKey!, apiEndpoint: endpoint!);

      final source = DifyRemoteDataSource(DifyApiClient());
      final chunks = await source
          .streamChatMessage(query: 'Hello', userId: 'sse-live-test')
          .toList();

      expect(chunks, isNotEmpty, reason: 'SSE parser emitted no chat chunks');
      final visible = visibleAssistantContent(
        chunks.last.message.content,
        streaming: false,
      );
      expect(visible, isNotEmpty, reason: 'assistant content was empty');
    },
    skip: liveEnabled && envFile.existsSync()
        ? false
        : 'Set ENABLE_DIFY_LIVE_TEST=1 with example/.env',
    timeout: const Timeout(Duration(seconds: 90)),
  );
}
