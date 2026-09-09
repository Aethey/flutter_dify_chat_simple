import '../repositories/audio_repository.dart';

/// Converts audio to text via Dify POST /audio-to-text.
class TranscribeAudio {
  TranscribeAudio(this._audioRepository);

  final AudioRepository _audioRepository;

  Future<String> call({required String filePath, required String userId}) {
    return _audioRepository.transcribe(filePath: filePath, userId: userId);
  }
}
