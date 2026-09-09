import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_state.freezed.dart';

@freezed
abstract class VoiceState with _$VoiceState {
  const factory VoiceState({
    @Default(false) bool isRecording,
    @Default(false) bool isTranscribing,
    @Default(Duration.zero) Duration duration,
  }) = _VoiceState;
}
