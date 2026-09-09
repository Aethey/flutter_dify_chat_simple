import '../entities/uploaded_file.dart';
import '../repositories/file_repository.dart';

/// Uploads a local file to Dify POST /files/upload.
class UploadChatFile {
  UploadChatFile(this._fileRepository);

  final FileRepository _fileRepository;

  Future<UploadedFile> call({
    required String filePath,
    required String userId,
  }) {
    return _fileRepository.upload(filePath: filePath, userId: userId);
  }
}
