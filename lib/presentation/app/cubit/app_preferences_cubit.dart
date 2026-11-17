import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';

/// The app-wide look the user chose: accent colour and interface scale.
class AppPreferences {
  const AppPreferences({
    this.accent = AppAccent.inkBlue,
    this.interfaceScale = 1,
  });

  /// The saved accent, which may be premium while premium is locked.
  final AppAccent accent;
  final double interfaceScale;

  AppPreferences copyWith({AppAccent? accent, double? interfaceScale}) =>
      AppPreferences(
        accent: accent ?? this.accent,
        interfaceScale: interfaceScale ?? this.interfaceScale,
      );
}

/// Holds [AppPreferences] above the router, so a change restyles every
/// screen at once.
@lazySingleton
class AppPreferencesCubit extends Cubit<AppPreferences> {
  AppPreferencesCubit(this._settings) : super(const AppPreferences());

  final SettingsRepository _settings;

  Future<void> load() async {
    try {
      final settings = await _settings.getSettings();
      if (isClosed) return;
      emit(
        AppPreferences(
          accent: settings.appAccent,
          interfaceScale: settings.interfaceScale,
        ),
      );
    } catch (_) {
      // Defaults stay; the app is usable without saved preferences.
    }
  }

  Future<void> setAccent(AppAccent accent) =>
      _update(state.copyWith(accent: accent), 'appAccent', accent.name);

  /// Applies [scale] at once; [persist] is false while a slider is dragged.
  Future<void> setInterfaceScale(double scale, {bool persist = true}) {
    final clamped = scale.clamp(
      SettingsEntity.minInterfaceScale,
      SettingsEntity.maxInterfaceScale,
    );
    final next = state.copyWith(interfaceScale: clamped);
    if (!persist) {
      emit(next);
      return Future.value();
    }
    return _update(next, 'interfaceScale', clamped);
  }

  Future<void> _update(AppPreferences next, String key, Object value) async {
    final previous = state;
    emit(next);
    try {
      await _settings.updateSetting(key: key, value: value);
    } catch (_) {
      if (!isClosed) emit(previous);
    }
  }
}
