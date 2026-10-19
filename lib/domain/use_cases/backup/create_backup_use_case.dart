import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/repository/backup/backup_repository.dart';

@singleton
class CreateBackupUseCase {
  CreateBackupUseCase(this._backupRepository);

  final BackupRepository _backupRepository;

  /// Creates a backup and returns the file path to the archive.
  Future<String> execute({bool includeBookFiles = false}) {
    return _backupRepository.createBackup(includeBookFiles: includeBookFiles);
  }
}
