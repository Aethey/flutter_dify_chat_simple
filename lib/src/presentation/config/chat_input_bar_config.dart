import 'package:flutter/widgets.dart';

/// Action assigned to one of the three input-bar slots.
enum ChatInputAction {
  /// Hide this slot.
  none,

  /// Pick a local file and upload it via POST /files/upload.
  uploadFile,

  /// Pick an image and upload it via POST /files/upload.
  image,

  /// Open conversation history.
  history,

  /// Record audio and convert it via POST /audio-to-text.
  voice,
}

/// Configuration for a single input-bar slot (position 1 / 2 / 3).
class ChatInputSlot {
  /// Function this slot performs. [ChatInputAction.none] hides the button.
  final ChatInputAction action;

  /// When true, [icon] is required and used instead of the SDK default icon.
  final bool custom;

  /// Host-provided icon. Required when [custom] is true.
  final Widget? icon;

  const ChatInputSlot({
    this.action = ChatInputAction.none,
    this.custom = false,
    this.icon,
  }) : assert(!custom || icon != null, 'icon is required when custom is true');

  bool get isVisible => action != ChatInputAction.none;
}

/// Layout of the three configurable input-bar buttons.
///
/// Inactive: `slot1 | text field | slot2 | slot3 | send` (one row).
/// Focused: one extra full-width text line above the same tool row.
/// Longer text: field uses the previous expanded height, tools on a second row.
/// Expand control (top-right) goes fullscreen; collapse returns to that height.
class ChatInputBarConfig {
  final ChatInputSlot slot1;
  final ChatInputSlot slot2;
  final ChatInputSlot slot3;

  const ChatInputBarConfig({
    this.slot1 = const ChatInputSlot(action: ChatInputAction.history),
    this.slot2 = const ChatInputSlot(action: ChatInputAction.image),
    this.slot3 = const ChatInputSlot(action: ChatInputAction.voice),
  });
}
