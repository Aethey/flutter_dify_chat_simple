import '../../domain/repositories/audio_repository.dart';
import '../datasources/dify_remote_datasource.dart';

class AudioRepositoryImpl implements AudioRepository {
  AudioRepositoryImpl(this._remoteDataSource);

  final DifyRemoteDataSource _remoteDataSource;

  @override
  Future<String> transcribe({
    required String filePath,
    required String userId,
  }) {
    return _remoteDataSource.audioToText(filePath: filePath, userId: userId);
  }
}
