/// Dify speech-to-text.
abstract class AudioRepository {
  Future<String> transcribe({
    required String filePath,
    required String userId,
  });
}
