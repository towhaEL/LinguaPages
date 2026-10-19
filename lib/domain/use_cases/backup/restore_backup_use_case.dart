import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/repository/backup/backup_repository.dart';

@singleton
class RestoreBackupUseCase {
  RestoreBackupUseCase(this._backupRepository);

  final BackupRepository _backupRepository;

  /// Restores a backup from the given file path.
  Future<BackupRestoreResult> execute(String filePath) {
    return _backupRepository.restoreBackup(filePath);
  }
}
