/// Brightness for the reader window only; the system setting is untouched.
abstract interface class ScreenBrightnessService {
  /// The window's current brightness, 0–1.
  Future<double> current();

  Future<void> set(double brightness);

  /// Back to following the system brightness.
  Future<void> reset();
}
