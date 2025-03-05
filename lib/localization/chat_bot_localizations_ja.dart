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
  String get cancel => 'キャンセル';

  @override
  String get reset => 'リセット';

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
}
