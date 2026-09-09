import '../../domain/entities/uploaded_file.dart';
import '../../domain/repositories/file_repository.dart';
import '../datasources/dify_remote_datasource.dart';

class FileRepositoryImpl implements FileRepository {
  FileRepositoryImpl(this._remoteDataSource);

  final DifyRemoteDataSource _remoteDataSource;

  @override
  Future<UploadedFile> upload({
    required String filePath,
    required String userId,
  }) {
    return _remoteDataSource.uploadFile(filePath: filePath, userId: userId);
  }
}
