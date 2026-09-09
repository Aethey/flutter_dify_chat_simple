import '../entities/uploaded_file.dart';

/// Dify file upload.
abstract class FileRepository {
  Future<UploadedFile> upload({
    required String filePath,
    required String userId,
  });
}
