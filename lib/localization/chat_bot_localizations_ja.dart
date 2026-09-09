// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'chat_bot_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'チャットボットSDK';

  @override
  String get chatTitle => 'チャットアシスタント';

  @override
  String get initialMessage => 'こんにちは！何かお手伝いできることはありますか？';

  @override
  String get resetChat => 'チャットをリセット';

  @override
  String get resetChatConfirmation => 'チャット履歴がすべて消去されます。続行しますか？';

  @override
  String get deleteChatConfirmation => 'この会話履歴を削除してもよろしいですか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get reset => 'リセット';

  @override
  String get delete => '削除';

  @override
  String get typeMessage => 'メッセージを入力...';

  @override
  String get startConversation => '会話を始めましょう';

  @override
  String get typeToBegin => 'メッセージを入力して始める';

  @override
  String get errorTitle => 'エラーが発生しました';

  @override
  String get genericError => '問題が発生しました。もう一度お試しください。';

  @override
  String networkError(String message) {
    return 'ネットワークエラー: $message';
  }

  @override
  String get networkErrorDesc => 'ネットワークエラー。接続を確認してください。';

  @override
  String get retry => '再試行';

  @override
  String get connectionTimeout => '接続タイムアウト: サーバーに接続できませんでした';

  @override
  String get receiveTimeout => '受信タイムアウト: サーバーからの応答を受信できませんでした';

  @override
  String get sendTimeout => '送信タイムアウト: リクエストの送信に失敗しました';

  @override
  String get connectionError => '接続エラー: インターネット接続を確認してください';

  @override
  String get requestCancelled => 'リクエストがキャンセルされました';

  @override
  String serverError(String statusCode, String message) {
    return 'サーバーエラー (HTTP $statusCode): $message';
  }

  @override
  String apiError(String code, String message) {
    return 'APIエラー ($code): $message';
  }

  @override
  String get logToday => '今日';

  @override
  String get logYesterday => '昨日';

  @override
  String get conversationHistory => '会話履歴';

  @override
  String get noConversationHistory => '会話履歴がありません';

  @override
  String get loadingConversation => '会話を読み込み中...';

  @override
  String get pickFromGallery => 'フォトライブラリ';

  @override
  String get pickFromCamera => 'カメラ';

  @override
  String get attachImage => '画像を添付';

  @override
  String get removeImage => '画像を削除';

  @override
  String get voiceInput => '音声入力';

  @override
  String get recording => '録音中...';

  @override
  String get transcribing => '文字起こし中...';

  @override
  String get microphonePermissionDenied => '音声入力にはマイクの許可が必要です。';

  @override
  String get imageUploadFailed => '画像のアップロードに失敗しました。もう一度お試しください。';

  @override
  String get uploadFile => 'ファイルをアップロード';

  @override
  String get fileUploadFailed => 'ファイルのアップロードに失敗しました。もう一度お試しください。';

  @override
  String speechToTextFailed(String message) {
    return '音声認識に失敗しました: $message';
  }

  @override
  String get speechToTextDisabled =>
      'この Dify アプリでは Speech to Text が無効です。Features で有効にしてください。';

  @override
  String get speechToTextModelUnsupported =>
      'この Dify アプリの音声認識モデルは文字起こしに対応していません。Speech to Text を Whisper などに変更してください（ホステッド GPT-4 トライアルでは転記できません）。';

  @override
  String get emptyAssistantReply =>
      '返信がありませんでした。画像やファイルだけの場合は、短い質問を添えて再送信してください。';

  @override
  String get expandComposer => '拡大';

  @override
  String get collapseComposer => '縮小';

  @override
  String get scrollToBottom => '最新のメッセージへ';
}
