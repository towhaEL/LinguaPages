import 'package:flutter/material.dart';
import 'package:lingua_pages/presentation/theme/base/app_colors.dart';
import 'package:lingua_pages/presentation/theme/base/app_text_theme.dart';
import 'package:lingua_pages/presentation/theme/base/band_colors.dart';

extension ThemeContext on BuildContext {
  ThemeData get appThemeData => Theme.of(this);

  AppTextTheme get textStyle => appThemeData.extension<AppTextTheme>()!;

  AppColors get colors => appThemeData.extension<AppColors>()!;

  BandColors get bands => appThemeData.extension<BandColors>()!;

  /// The chosen app accent; use it rather than a fixed brand colour.
  Color get accent => appThemeData.colorScheme.primary;

  /// A pale tint of [accent] for badges and selected states.
  Color get accentContainer => appThemeData.colorScheme.primaryContainer;
}
