import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class OnboardingPreferences {
  OnboardingPreferences(this._preferences);

  static const completedKey = 'onboarding.completed';

  final SharedPreferences _preferences;

  bool get isComplete => _preferences.getBool(completedKey) ?? false;

  Future<void> complete() => _preferences.setBool(completedKey, true);
}
