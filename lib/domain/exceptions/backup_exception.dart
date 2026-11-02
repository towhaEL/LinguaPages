enum BackupFailureKind { passphraseRequired, passphraseIncorrect }

class BackupException implements Exception {
  const BackupException(this.kind);

  final BackupFailureKind kind;

  @override
  String toString() => 'BackupException: ${kind.name}';
}
