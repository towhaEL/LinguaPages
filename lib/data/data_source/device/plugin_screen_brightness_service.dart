import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/service/screen_brightness_service.dart';
import 'package:screen_brightness/screen_brightness.dart';

@LazySingleton(as: ScreenBrightnessService)
class PluginScreenBrightnessService implements ScreenBrightnessService {
  ScreenBrightness get _plugin => ScreenBrightness.instance;

  @override
  Future<double> current() => _plugin.application;

  @override
  Future<void> set(double brightness) =>
      _plugin.setApplicationScreenBrightness(brightness.clamp(0.0, 1.0));

  @override
  Future<void> reset() => _plugin.resetApplicationScreenBrightness();
}
