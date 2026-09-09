import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'providers.dart';
import 'voice_state.dart';

class VoiceNotifier extends Notifier<VoiceState> {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _timer;

  @override
  VoiceState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _recorder.dispose();
    });
    return const VoiceState();
  }

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> start() async {
    if (state.isRecording || state.isTranscribing) return;

    final dir = await getTemporaryDirectory();
    final filePath = p.join(
      dir.path,
      'dify_voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: filePath,
    );

    state = const VoiceState(isRecording: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        duration: state.duration + const Duration(seconds: 1),
      );
    });
  }

  Future<String?> stopAndTranscribe(String userId) async {
    _timer?.cancel();
    final path = await _recorder.stop();
    state = const VoiceState(isTranscribing: true);

    if (path == null || path.isEmpty) {
      state = const VoiceState();
      return null;
    }

    try {
      final text = await ref.read(transcribeAudioUseCaseProvider)(
        filePath: path,
        userId: userId,
      );
      return text;
    } finally {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      if (ref.mounted) {
        state = const VoiceState();
      }
    }
  }
}

final voiceProvider =
    NotifierProvider<VoiceNotifier, VoiceState>(VoiceNotifier.new);
