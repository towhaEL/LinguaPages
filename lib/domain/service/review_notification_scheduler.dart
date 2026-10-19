/// Keeps the optional local review reminder behind a platform-neutral boundary.
abstract interface class ReviewNotificationScheduler {
  Future<void> initialize();

  Future<void> requestPermission();

  /// Reconciles the scheduled reminder with current settings and due cards.
  Future<void> sync();
}
