# ChatBot SDK 示例项目

此目录包含一个示例应用程序，演示如何将 ChatBot SDK 集成到您的 Flutter 应用程序中。

## 集成步骤

### 1. 添加依赖

在您的 `pubspec.yaml` 文件中添加 ChatBot SDK 依赖：

```yaml
dependencies:
  chat_bot_sdk:
    path: ../  # 或者使用您发布的版本
```

### 2. 初始化 SDK

在您的应用程序启动时初始化 SDK：

```dart
import 'package:chat_bot_sdk/chat_bot_sdk.dart';

void main() {
  // 初始化 SDK
  ChatBotSdk.initialize(
    apiKey: 'YOUR_API_KEY',
    apiEndpoint: 'https://api.dify.ai/v1',  // 可选，默认为 Dify.ai
  );
  
  runApp(MyApp());
}
```

### 3. 启动聊天界面

在您的应用程序中，您可以使用以下代码启动聊天界面：

```dart
ElevatedButton(
  onPressed: () {
    ChatBotSdk.startChat(
      context: context,
      title: '聊天助手',  // 可选
      initialMessage: '您好，我能帮您什么？',  // 可选
      locale: const Locale('zh'),  // 可选，指定界面语言
    );
  },
  child: Text('启动聊天'),
),
```

### 4. 切换语言

SDK 支持英语、日语和中文。您可以通过 `locale` 参数切换语言：

```dart
// 英文界面
ChatBotSdk.startChat(
  context: context,
  locale: const Locale('en'),
);

// 日文界面
ChatBotSdk.startChat(
  context: context,
  locale: const Locale('ja'),
);

// 中文界面
ChatBotSdk.startChat(
  context: context,
  locale: const Locale('zh'),
);
```

## 本地化与集成

ChatBot SDK 使用封装的本地化系统，不会与您的应用程序本地化资源冲突。您可以放心集成 SDK，同时保持您自己的应用程序本地化设置。

详细的本地化信息请参见 SDK 文档中的 `lib/src/l10n/README.md`。 