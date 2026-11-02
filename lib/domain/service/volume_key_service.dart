enum PageTurn { previous, next }

/// Hardware volume keys as page turns while the reader asks for them.
abstract interface class VolumeKeyService {
  Stream<PageTurn> get pageTurns;

  /// While enabled the keys no longer change the volume.
  Future<void> setEnabled({required bool enabled});
}
