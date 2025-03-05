import 'package:flutter/material.dart';
import 'package:chat_bot_sdk/chat_bot_sdk.dart';

void main() {
  // 确保Flutter绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 在应用启动时直接初始化SDK，使用提供的API密钥
  ChatBotSdk.initialize(
    // 请替换为您在Dify.ai获取的实际API密钥
    apiKey: 'your_api_key', // 使用占位符
    // 使用正确的Dify API基础URL
    apiEndpoint: 'https://api.dify.ai/v1',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Bot Demo',
      debugShowCheckedModeBanner: false, // 移除debug标记
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const ChatDemoHome(),
    );
  }
}

class ChatDemoHome extends StatelessWidget {
  const ChatDemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天机器人'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 展示当前使用的API密钥和端点
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '当前配置',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  // API Key
                  Text(
                    'API密钥:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.only(bottom: 8, top: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      'YOUR_DIFY_API_KEY', // 显示API Key占位符
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  // API Endpoint
                  Text(
                    'API端点:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'https://api.dify.ai/v1',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '端点路径: /completion-messages',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // 聊天机器人图标
            Icon(
              Icons.smart_toy_rounded,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              '开始一次对话',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '点击下方按钮开始与AI助手对话',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            
            const Spacer(),
            
            // 开始聊天按钮
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _startChat(context),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('开始聊天'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  
                  // 添加备注
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '注意: 请确保API密钥有效，否则将无法获取响应',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startChat(BuildContext context) {
    ChatBotSdk.startChat(
      context: context,
      title: 'AI 助手',
      initialMessage: '你好！我是AI助手，有什么我可以帮助你的？',
      themeData: Theme.of(context), // 使用当前主题
    );
  }
} 