import 'package:flutter/material.dart';
import 'package:lingua_pages/presentation/theme/base/base_color_theme.dart';
import 'package:lingua_pages/presentation/theme/base/base_text_theme.dart';
import 'package:lingua_pages/presentation/theme/base/base_theme_info.dart';
import 'package:lingua_pages/presentation/theme/dark/dark_color_theme.dart';
import 'package:lingua_pages/presentation/theme/text/landscape_text_style.dart';
import 'package:lingua_pages/presentation/theme/text/portrait_text_style.dart';

class EnDarkMode extends BaseThemeInfo {
  factory EnDarkMode() => _instance;

  EnDarkMode._initial();

  static final EnDarkMode _instance = EnDarkMode._initial();

  @override
  ThemeData getAppTheme({required Orientation orientation}) {
    final theme = getBaseColorTheme(orientation: orientation).getTheme();
    final baseTextTheme = getBaseTextTheme(orientation: orientation);

    return theme.copyWith(
      textTheme: baseTextTheme.appTextStyle.getTextTheme().apply(
        fontFamily: DarkColorTheme.fontFamily,
      ),
      extensions: [
        ...theme.extensions.values.cast<ThemeExtension>(),
        baseTextTheme.appTextStyle,
      ],
    );
  }

  @override
  BaseColorTheme getBaseColorTheme({required Orientation orientation}) =>
      DarkColorTheme();

  @override
  BaseTextTheme getBaseTextTheme({required Orientation orientation}) {
    final textColor = getBaseColorTheme(
      orientation: orientation,
    ).getAppColors.onSurface;

    return orientation == Orientation.portrait
        ? PortraitTextStyle(textColor: textColor)
        : LandscapeTextStyle(textColor: textColor);
  }
}
