import 'package:flutter/material.dart';

import 'package:lingua_pages/presentation/theme/base/app_colors.dart';

abstract class BaseColorTheme {
  AppColors get getAppColors;

  ThemeData getTheme();
}
