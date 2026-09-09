import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:chat_bot_sdk/custom/color.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/error/app_exception.dart';
import '../../domain/entities/chat_file_attachment.dart';
import '../config/chat_input_bar_config.dart';
import '../history/show_conversation_history.dart';
import '../state/attachment_notifier.dart';
import '../state/chat_notifier.dart';
import '../state/voice_notifier.dart';
import '../state/voice_state.dart';

/// ChatGPT-style composer with three configurable action slots.
class MessageInput extends ConsumerStatefulWidget {
  final void Function(
    String message,
    String? conversationId, [
    List<ChatFileAttachment>? files,
  ])
  onSendMessage;

  final String userId;
  final String? conversationId;
  final bool isLoading;
  final bool isLoadingHistory;
  final String? hintText;
  final ChatInputBarConfig inputBarConfig;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    required this.userId,
    required this.inputBarConfig,
    this.conversationId,
    this.isLoading = false,
    this.isLoadingHistory = false,
    this.hintText,
  });

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput>
    with TickerProviderStateMixin {
  static const _barH = 44.0;
  static const _slotW = 44.0;
  static const _sendW = 40.0;
  static const _lineH = 22.0;

  /// Focused, little text: one extra full-width line above the tool row.
  static const _tier1FieldH = _lineH;

  /// Previous stacked field height, used when the user types more.
  static const _tier2FieldH = 96.0;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  late final AnimationController _expandController;
  late final AnimationController _stackController;
  late final Animation<double> _expand;
  late final Animation<double> _stack;
  var _isFullscreen = false;
  var _pinTier2 = false;
  var _stackScheduled = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _stackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _expand = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
    _stack = CurvedAnimation(
      parent: _stackController,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
    _textController.addListener(() => setState(() {}));
    _focusNode.addListener(_syncExpansion);
  }

  void _syncExpansion() {
    if (!mounted) return;
    final active = _isComposerActive;
    if (active) {
      _expandController.forward();
    } else {
      _pinTier2 = false;
      _expandController.reverse();
      _stackController.reverse();
    }
  }

  void _scheduleStack(bool wantStack) {
    final shouldForward =
        wantStack &&
        _stackController.status != AnimationStatus.completed &&
        _stackController.status != AnimationStatus.forward;
    final shouldReverse =
        !wantStack &&
        !_isFullscreen &&
        _stackController.status != AnimationStatus.dismissed &&
        _stackController.status != AnimationStatus.reverse;
    if (!shouldForward && !shouldReverse) return;
    if (_stackScheduled) return;
    _stackScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stackScheduled = false;
      if (!mounted) return;
      if (shouldForward) {
        _stackController.forward();
      } else if (shouldReverse) {
        _stackController.reverse();
      }
    });
  }

  bool get _isComposerActive {
    return _focusNode.hasFocus ||
        _isFullscreen ||
        ref.read(voiceProvider).isRecording;
  }

  bool get _isBusy => widget.isLoading || widget.isLoadingHistory;

  bool get _canSend {
    final attachments = ref.read(attachmentProvider);
    final hasText = _textController.text.trim().isNotEmpty;
    return (hasText || attachments.hasReadyFile) &&
        !attachments.isUploading &&
        !_isBusy;
  }

  Future<void> _handleSendMessage() async {
    if (!_canSend) return;
    final files = ref.read(attachmentProvider.notifier).takeReadyFiles();
    widget.onSendMessage(
      _textController.text.trim(),
      widget.conversationId,
      files,
    );
    _textController.clear();
    _isFullscreen = false;
    _pinTier2 = false;
    _focusNode.requestFocus();
  }

  Future<void> _onSlotPressed(ChatInputAction action) async {
    final voice = ref.read(voiceProvider);
    if (_isBusy || voice.isRecording || voice.isTranscribing) {
      if (action == ChatInputAction.voice && voice.isRecording) {
        await _toggleVoice();
      }
      return;
    }

    switch (action) {
      case ChatInputAction.none:
        break;
      case ChatInputAction.history:
        await _openHistory();
      case ChatInputAction.image:
        await _pickImage();
      case ChatInputAction.uploadFile:
        await _pickFile();
      case ChatInputAction.voice:
        await _toggleVoice();
    }
  }

  Future<void> _openHistory() async {
    final chatNotifier = ref.read(chatProvider.notifier);
    await showConversationHistory(
      context: context,
      loadConversations: () => chatNotifier.loadConversations(widget.userId),
      deleteConversation: (id) =>
          chatNotifier.deleteConversation(widget.userId, id),
      onConversationSelected: (conversationId) {
        widget.onSendMessage('', conversationId);
      },
      onNewConversation: () {
        widget.onSendMessage('new_conversation_with_animation', null);
      },
    );
  }

  Future<void> _pickImage() async {
    final l10n = context.l10n;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.pickFromGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.pickFromCamera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    try {
      await ref
          .read(attachmentProvider.notifier)
          .addFile(filePath: picked.path, userId: widget.userId, type: 'image');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.imageUploadFailed)));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    final path = result?.files.single.path;
    if (path == null || !mounted) return;

    try {
      await ref
          .read(attachmentProvider.notifier)
          .addFile(filePath: path, userId: widget.userId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.fileUploadFailed)));
    }
  }

  Future<void> _toggleVoice() async {
    final voiceNotifier = ref.read(voiceProvider.notifier);
    if (ref.read(voiceProvider).isRecording) {
      try {
        final text = await voiceNotifier.stopAndTranscribe(widget.userId);
        if (!mounted || text == null || text.isEmpty) return;
        final current = _textController.text.trim();
        _textController.text = current.isEmpty ? text : '$current $text';
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_voiceErrorText(error))));
      }
      return;
    }

    final permitted = await voiceNotifier.hasPermission();
    if (!permitted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.microphonePermissionDenied)),
      );
      return;
    }
    await voiceNotifier.start();
  }

  String _voiceErrorText(Object error) {
    final l10n = context.l10n;
    if (error is! AppException) return l10n.genericError;
    switch (error.code) {
      case 'speech_to_text_disabled':
        return l10n.speechToTextDisabled;
      case 'model_currently_not_support':
      case 'provider_not_support_speech_to_text':
        return l10n.speechToTextModelUnsupported;
      default:
        final message = error.message;
        if (message == null || message.isEmpty) return l10n.genericError;
        return l10n.speechToTextFailed(message);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  IconData _defaultIcon(ChatInputAction action) {
    switch (action) {
      case ChatInputAction.uploadFile:
        return Icons.attach_file;
      case ChatInputAction.image:
        return Icons.image_outlined;
      case ChatInputAction.history:
        return Icons.history;
      case ChatInputAction.voice:
        return Icons.mic;
      case ChatInputAction.none:
        return Icons.circle;
    }
  }

  String _tooltip(ChatInputAction action) {
    final l10n = context.l10n;
    switch (action) {
      case ChatInputAction.uploadFile:
        return l10n.uploadFile;
      case ChatInputAction.image:
        return l10n.attachImage;
      case ChatInputAction.history:
        return l10n.conversationHistory;
      case ChatInputAction.voice:
        return l10n.voiceInput;
      case ChatInputAction.none:
        return '';
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_syncExpansion);
    _expandController.dispose();
    _stackController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<VoiceState>(voiceProvider, (previous, next) {
      if (previous?.isRecording != next.isRecording) {
        _syncExpansion();
      }
    });

    final attachments = ref.watch(attachmentProvider);
    final voice = ref.watch(voiceProvider);
    final config = widget.inputBarConfig;
    final hintText = voice.isRecording
        ? '${context.l10n.recording} ${_formatDuration(voice.duration)}'
        : (voice.isTranscribing
              ? context.l10n.transcribing
              : (widget.isLoadingHistory
                    ? context.l10n.loadingConversation
                    : (widget.hintText ?? context.l10n.typeMessage)));

    return LayoutBuilder(
      builder: (context, constraints) {
        final bottomPad = MediaQuery.paddingOf(context).bottom + 8;
        const topPad = 8.0;
        const innerPad = 16.0;
        final attachmentH = attachments.items.isEmpty ? 0.0 : 88.0;
        final maxComposerH = constraints.hasBoundedHeight
            ? math.max(
                _barH,
                constraints.maxHeight -
                    topPad -
                    bottomPad -
                    innerPad -
                    attachmentH,
              )
            : double.infinity;

        return Padding(
          padding: EdgeInsets.fromLTRB(12, topPad, 12, bottomPad),
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (attachments.items.isNotEmpty) _buildPendingAttachments(),
                _buildMorphingComposer(
                  config,
                  voice,
                  hintText,
                  maxComposerH: maxComposerH,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMorphingComposer(
    ChatInputBarConfig config,
    VoiceState voice,
    String hintText, {
    required double maxComposerH,
  }) {
    final slot1W = config.slot1.isVisible ? _slotW : 0.0;
    final slot2W = config.slot2.isVisible ? _slotW : 0.0;
    final slot3W = config.slot3.isVisible ? _slotW : 0.0;
    const sendW = _sendW;
    final rightW = slot2W + slot3W + sendW;
    final textStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16,
      height: _lineH / 16,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fullscreenFieldH = _fullscreenFieldHeight(
          maxComposerH: maxComposerH,
        );
        return AnimatedBuilder(
          animation: Listenable.merge([_expand, _stack]),
          builder: (context, _) {
            final t = _expand.value;
            final s = _stack.value;
            final collapsedFieldW = (width - slot1W - rightW).clamp(0.0, width);
            final useTier2 = _shouldUseTier2(width, textStyle);
            _scheduleStack(_isComposerActive && useTier2);
            final extraH = lerpDouble(0, _tier1FieldH, t)!;
            final inlineFieldH = lerpDouble(_barH, _tier1FieldH, t)!;
            final stackedFieldH = _isFullscreen
                ? fullscreenFieldH
                : (maxComposerH.isFinite
                      ? math.min(
                          _tier2FieldH,
                          math.max(0.0, maxComposerH - _barH),
                        )
                      : _tier2FieldH);
            final fieldH = lerpDouble(inlineFieldH, stackedFieldH, s)!;
            final totalH = lerpDouble(
              _barH + extraH,
              stackedFieldH + _barH,
              s,
            )!;
            final fieldLeft = lerpDouble(lerpDouble(slot1W, 0, t)!, 0, s)!;
            final fieldWidth = lerpDouble(
              lerpDouble(collapsedFieldW, width, t)!,
              width,
              s,
            )!;
            final buttonY = lerpDouble(extraH, fieldH, s)!;
            final showExpand = s > 0.7 && (useTier2 || _isFullscreen);

            return SizedBox(
              height: totalH,
              width: width,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    left: fieldLeft,
                    top: 0,
                    width: fieldWidth,
                    height: fieldH,
                    child: _buildTextField(
                      hintText,
                      showExpand: showExpand,
                      stacked: useTier2 || _isFullscreen,
                    ),
                  ),
                  if (showExpand)
                    Positioned(
                      right: 0,
                      top: 0,
                      width: 36,
                      height: 36,
                      child: _buildExpandButton(),
                    ),
                  if (config.slot1.isVisible)
                    Positioned(
                      left: 0,
                      top: buttonY,
                      width: _slotW,
                      height: _barH,
                      child: _buildSlot(config.slot1, voice),
                    ),
                  if (config.slot2.isVisible)
                    Positioned(
                      right: sendW + slot3W,
                      top: buttonY,
                      width: _slotW,
                      height: _barH,
                      child: _buildSlot(config.slot2, voice),
                    ),
                  if (config.slot3.isVisible)
                    Positioned(
                      right: sendW,
                      top: buttonY,
                      width: _slotW,
                      height: _barH,
                      child: _buildSlot(config.slot3, voice),
                    ),
                  Positioned(
                    right: 0,
                    top: buttonY,
                    width: sendW,
                    height: _barH,
                    child: Center(child: _buildSendButton()),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double _fullscreenFieldHeight({required double maxComposerH}) {
    if (!maxComposerH.isFinite) {
      return _tier2FieldH;
    }
    return (maxComposerH - _barH).clamp(0.0, maxComposerH);
  }

  bool _shouldUseTier2(double composerWidth, TextStyle style) {
    if (_isFullscreen || _pinTier2) return true;
    if (!_isComposerActive) return false;
    final text = _textController.text;
    if (text.isEmpty) return false;
    if (text.contains('\n')) return true;
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
    )..layout(maxWidth: math.max(8, composerWidth - 24));
    return painter.computeLineMetrics().length >= 2;
  }

  void _toggleFullscreen() {
    setState(() {
      if (_isFullscreen) {
        _isFullscreen = false;
        _pinTier2 = true;
      } else {
        _isFullscreen = true;
        _pinTier2 = true;
      }
    });
    _syncExpansion();
    if (_isFullscreen && !_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  Widget _buildExpandButton() {
    return Tooltip(
      message: _isFullscreen
          ? context.l10n.collapseComposer
          : context.l10n.expandComposer,
      child: IconButton(
        key: const Key('chat_input_expand'),
        onPressed: _toggleFullscreen,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        visualDensity: VisualDensity.compact,
        icon: Icon(
          _isFullscreen ? Icons.close_fullscreen : Icons.open_in_full,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hintText, {
    required bool showExpand,
    required bool stacked,
  }) {
    final voice = ref.watch(voiceProvider);
    final active = _isComposerActive;
    final int? maxLines;
    final bool expands;
    if (_isFullscreen) {
      maxLines = null;
      expands = true;
    } else if (!active) {
      maxLines = 1;
      expands = false;
    } else if (stacked) {
      maxLines = 6;
      expands = false;
    } else {
      maxLines = 2;
      expands = false;
    }

    final vPad = stacked ? 8.0 : (active ? 0.0 : 8.0);

    return ClipRect(
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.fromLTRB(
            12,
            vPad,
            showExpand ? 40 : 12,
            vPad,
          ),
          hintStyle: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        cursorColor: customColor1,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
          height: _lineH / 16,
        ),
        textAlignVertical: stacked
            ? TextAlignVertical.top
            : TextAlignVertical.center,
        textCapitalization: TextCapitalization.sentences,
        maxLines: maxLines,
        minLines: expands ? null : 1,
        expands: expands,
        enabled: !_isBusy && !voice.isRecording && !voice.isTranscribing,
        textInputAction: active
            ? TextInputAction.newline
            : TextInputAction.send,
        onSubmitted: active ? null : (_) => _handleSendMessage(),
      ),
    );
  }

  Widget _buildSlot(ChatInputSlot slot, VoiceState voice) {
    if (!slot.isVisible) return const SizedBox.shrink();

    final isVoice = slot.action == ChatInputAction.voice;
    final Widget child;
    if (isVoice && voice.isTranscribing) {
      child = const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (isVoice && voice.isRecording) {
      child = const Icon(Icons.stop, size: 22);
    } else {
      child = _slotIcon(slot);
    }

    return Tooltip(
      message: isVoice && voice.isRecording
          ? context.l10n.recording
          : _tooltip(slot.action),
      child: IconButton(
        key: isVoice ? const Key('chat_input_voice') : null,
        onPressed: _isBusy && !(isVoice && voice.isRecording)
            ? null
            : () => _onSlotPressed(slot.action),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        visualDensity: VisualDensity.compact,
        icon: IconTheme(
          data: IconThemeData(
            size: 22,
            color: isVoice && voice.isRecording
                ? Colors.red
                : Theme.of(context).colorScheme.onSurface,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _slotIcon(ChatInputSlot slot) {
    if (slot.custom && slot.icon != null) {
      return slot.icon!;
    }
    return Icon(_defaultIcon(slot.action), size: 22);
  }

  Widget _buildSendButton() {
    final enabled = _canSend;
    return Material(
      color: (customColor0 ?? Theme.of(context).colorScheme.primary).withValues(
        alpha: enabled ? 1 : 0.4,
      ),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? _handleSendMessage : null,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.arrow_upward, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildPendingAttachments() {
    final items = ref.watch(attachmentProvider).items;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Stack(
              children: [
                if (item.type == 'image')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(item.localPath),
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 120,
                    height: 72,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (item.uploading)
                  Container(
                    width: item.type == 'image' ? 72 : 120,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(attachmentProvider.notifier).remove(item.id),
                    child: Tooltip(
                      message: context.l10n.removeImage,
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
