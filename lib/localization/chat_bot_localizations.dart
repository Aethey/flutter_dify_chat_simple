import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'chat_bot_localizations_en.dart';
import 'chat_bot_localizations_ja.dart';
import 'chat_bot_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/chat_bot_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat Bot SDK'**
  String get appTitle;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat Assistant'**
  String get chatTitle;

  /// No description provided for @initialMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello! How can I help you today?'**
  String get initialMessage;

  /// No description provided for @resetChat.
  ///
  /// In en, this message translates to:
  /// **'Reset chat'**
  String get resetChat;

  /// No description provided for @resetChatConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will clear the entire chat history. Continue?'**
  String get resetChatConfirmation;

  /// No description provided for @deleteChatConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this conversation history?'**
  String get deleteChatConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get reset;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get startConversation;

  /// No description provided for @typeToBegin.
  ///
  /// In en, this message translates to:
  /// **'Type a message to begin'**
  String get typeToBegin;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorTitle;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error: {message}'**
  String networkError(String message);

  /// No description provided for @networkErrorDesc.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkErrorDesc;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @connectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout: Could not connect to the server'**
  String get connectionTimeout;

  /// No description provided for @receiveTimeout.
  ///
  /// In en, this message translates to:
  /// **'Receive timeout: Failed to receive response from server'**
  String get receiveTimeout;

  /// No description provided for @sendTimeout.
  ///
  /// In en, this message translates to:
  /// **'Send timeout: Failed to send request'**
  String get sendTimeout;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error: Please check your internet connection'**
  String get connectionError;

  /// No description provided for @requestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request was cancelled'**
  String get requestCancelled;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error (HTTP {statusCode}): {message}'**
  String serverError(String statusCode, String message);

  /// No description provided for @apiError.
  ///
  /// In en, this message translates to:
  /// **'API error ({code}): {message}'**
  String apiError(String code, String message);

  /// No description provided for @logToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get logToday;

  /// No description provided for @logYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get logYesterday;

  /// No description provided for @conversationHistory.
  ///
  /// In en, this message translates to:
  /// **'Conversation History'**
  String get conversationHistory;

  /// No description provided for @noConversationHistory.
  ///
  /// In en, this message translates to:
  /// **'No conversation history'**
  String get noConversationHistory;

  /// No description provided for @loadingConversation.
  ///
  /// In en, this message translates to:
  /// **'Loading conversation...'**
  String get loadingConversation;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Photo library'**
  String get pickFromGallery;

  /// No description provided for @pickFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get pickFromCamera;

  /// No description provided for @attachImage.
  ///
  /// In en, this message translates to:
  /// **'Attach image'**
  String get attachImage;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get removeImage;

  /// No description provided for @voiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get voiceInput;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get recording;

  /// No description provided for @transcribing.
  ///
  /// In en, this message translates to:
  /// **'Transcribing...'**
  String get transcribing;

  /// No description provided for @microphonePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required for voice input.'**
  String get microphonePermissionDenied;

  /// No description provided for @imageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image. Please try again.'**
  String get imageUploadFailed;

  /// No description provided for @uploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload file'**
  String get uploadFile;

  /// No description provided for @fileUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload file. Please try again.'**
  String get fileUploadFailed;

  /// No description provided for @speechToTextFailed.
  ///
  /// In en, this message translates to:
  /// **'Voice transcription failed: {message}'**
  String speechToTextFailed(String message);

  /// No description provided for @speechToTextDisabled.
  ///
  /// In en, this message translates to:
  /// **'Speech-to-text is disabled for this Dify app. Enable it in the app Features settings.'**
  String get speechToTextDisabled;

  /// No description provided for @speechToTextModelUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This Dify app\'s speech-to-text model cannot transcribe audio. Set Speech to Text to Whisper (or another STT model) in Dify. The hosted OpenAI GPT-4 trial cannot transcribe.'**
  String get speechToTextModelUnsupported;

  /// No description provided for @emptyAssistantReply.
  ///
  /// In en, this message translates to:
  /// **'No reply was returned. If you sent an image or file, include a short question and send again.'**
  String get emptyAssistantReply;

  /// No description provided for @expandComposer.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expandComposer;

  /// No description provided for @collapseComposer.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapseComposer;

  /// No description provided for @scrollToBottom.
  ///
  /// In en, this message translates to:
  /// **'Scroll to latest'**
  String get scrollToBottom;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
