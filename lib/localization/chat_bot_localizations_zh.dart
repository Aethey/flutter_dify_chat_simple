// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'chat_bot_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '聊天机器人SDK';

  @override
  String get chatTitle => '聊天助手';

  @override
  String get initialMessage => '您好！今天我能为您做什么？';

  @override
  String get resetChat => '重置聊天';

  @override
  String get resetChatConfirmation => '这将清除整个聊天历史记录。继续吗？';

  @override
  String get deleteChatConfirmation => '确定要删除该对话历史吗？';

  @override
  String get cancel => '取消';

  @override
  String get reset => '重置';

  @override
  String get delete => '删除';

  @override
  String get typeMessage => '输入消息...';

  @override
  String get startConversation => '开始对话';

  @override
  String get typeToBegin => '输入消息开始对话';

  @override
  String get errorTitle => '发生错误';

  @override
  String get genericError => '出了点问题。请重试。';

  @override
  String networkError(String message) {
    return '网络错误: $message';
  }

  @override
  String get networkErrorDesc => '网络错误。请检查您的连接。';

  @override
  String get retry => '重试';

  @override
  String get connectionTimeout => '连接超时：无法连接到服务器';

  @override
  String get receiveTimeout => '接收超时：无法从服务器接收响应';

  @override
  String get sendTimeout => '发送超时：无法发送请求';

  @override
  String get connectionError => '连接错误：请检查您的互联网连接';

  @override
  String get requestCancelled => '请求已取消';

  @override
  String serverError(String statusCode, String message) {
    return '服务器错误 (HTTP $statusCode): $message';
  }

  @override
  String apiError(String code, String message) {
    return 'API 错误（$code）：$message';
  }

  @override
  String get logToday => '今天';

  @override
  String get logYesterday => '昨天';

  @override
  String get conversationHistory => '对话历史';

  @override
  String get noConversationHistory => '暂无对话历史';

  @override
  String get loadingConversation => '正在加载对话...';

  @override
  String get pickFromGallery => '相册';

  @override
  String get pickFromCamera => '相机';

  @override
  String get attachImage => '添加图片';

  @override
  String get removeImage => '移除图片';

  @override
  String get voiceInput => '语音输入';

  @override
  String get recording => '正在录音...';

  @override
  String get transcribing => '正在识别...';

  @override
  String get microphonePermissionDenied => '语音输入需要麦克风权限。';

  @override
  String get imageUploadFailed => '图片上传失败，请重试。';

  @override
  String get uploadFile => '上传文件';

  @override
  String get fileUploadFailed => '文件上传失败，请重试。';

  @override
  String speechToTextFailed(String message) {
    return '语音识别失败：$message';
  }

  @override
  String get speechToTextDisabled =>
      '该 Dify 应用未开启语音转文字。请在应用 Features 中启用 Speech to Text。';

  @override
  String get speechToTextModelUnsupported =>
      '该 Dify 应用的语音识别模型不支持转写。请在 Dify 设置里把 Speech to Text 换成 Whisper 等语音模型（试用版 GPT-4 不能转写音频）。';

  @override
  String get emptyAssistantReply => '没有收到回复。如果只发了图片或文件，请附上一句说明再发送。';

  @override
  String get expandComposer => '展开';

  @override
  String get collapseComposer => '收起';

  @override
  String get scrollToBottom => '回到最新消息';
}
