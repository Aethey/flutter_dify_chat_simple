# Flutter Dify Chat Simple

<details open>
<summary>English</summary>

A simple Flutter SDK for integration with [Dify.ai](https://dify.ai) Chat API.

## Features
- Easy initialization and chat interface
- Streaming responses (typewriter effect)
- Clean single-page UI
- Full Dify.ai API compatibility

## Installation
Add to your `pubspec.yaml`:
```yaml
dependencies:
  flutter_dify_chat_simple:
    path: ../flutter_dify_chat_simple  # Local path to the SDK
```

## Usage
### Initialize
```dart
import 'package:flutter_dify_chat_simple/flutter_dify_chat_simple.dart';

void main() {
  ChatBotSdk.initialize(
    apiKey: 'YOUR_DIFY_API_KEY',
    apiEndpoint: 'https://api.dify.ai/v1',
  );
  runApp(MyApp());
}
```

### Launch Chat
```dart
ChatBotSdk.startChat(
  context: context,
  title: 'AI Assistant',
  initialMessage: 'Hello! How can I help you?',
  themeData: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.light,
    ),
  ),
  locale: const Locale('en'),
);
```

## Dify API Setup
1. Create a Dify.ai account and set up a chat application
2. Get your API key: App → API Access → Copy API Key
</details>

<details>
<summary>中文</summary>

一个用于集成 [Dify.ai](https://dify.ai) 聊天 API 的简易 Flutter SDK。

## 特性
- 简单的初始化和聊天界面
- 流式响应（打字机效果）
- 整洁的单页 UI
- 完全兼容 Dify.ai API

## 安装
添加到 `pubspec.yaml`:
```yaml
dependencies:
  flutter_dify_chat_simple:
    path: ../flutter_dify_chat_simple  # Local path to the SDK
```

## 使用方法
### 初始化
```dart
import 'package:flutter_dify_chat_simple/flutter_dify_chat_simple.dart';

void main() {
  ChatBotSdk.initialize(
    apiKey: 'YOUR_DIFY_API_KEY',
    apiEndpoint: 'https://api.dify.ai/v1',
  );
  runApp(MyApp());
}
```

### 启动聊天
```dart
ChatBotSdk.startChat(
  context: context,
  title: 'AI 助手',
  initialMessage: '你好！有什么我可以帮助你的？',
  themeData: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.light,
    ),
  ),
  locale: const Locale('zh'),
);
```

## Dify API 配置
1. 创建 Dify.ai 账户并设置聊天应用
2. 获取 API 密钥：应用 → API 访问 → 复制 API 密钥
</details>

<details>
<summary>日本語</summary>

[Dify.ai](https://dify.ai) チャット API と統合するためのシンプルな Flutter SDK。

## 特徴
- 簡単な初期化とチャットインターフェース
- ストリーミングレスポンス（タイプライター効果）
- クリーンな単一ページ UI
- Dify.ai API との完全な互換性

## インストール
`pubspec.yaml` に追加:
```yaml
dependencies:
  flutter_dify_chat_simple:
    path: ../flutter_dify_chat_simple  # Local path to the SDK
```

## 使用方法
### 初期化
```dart
import 'package:flutter_dify_chat_simple/flutter_dify_chat_simple.dart';

void main() {
  ChatBotSdk.initialize(
    apiKey: 'YOUR_DIFY_API_KEY',
    apiEndpoint: 'https://api.dify.ai/v1',
  );
  runApp(MyApp());
}
```

### チャットの起動
```dart
ChatBotSdk.startChat(
  context: context,
  title: 'AI アシスタント',
  initialMessage: 'こんにちは！何かお手伝いできることはありますか？',
  themeData: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.light,
    ),
  ),
  locale: const Locale('ja'),
);
```

## Dify API 設定
1. Dify.ai アカウントを作成し、チャットアプリケーションを設定
2. API キーの取得: アプリ → API アクセス → API キーをコピー
</details>