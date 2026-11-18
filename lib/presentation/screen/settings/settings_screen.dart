import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:lingua_pages/presentation/screen/settings/settings_portrait_view.dart';

import '../../widgets/widgets.dart';

@RoutePage()
class SettingsScreen extends Screen {
  const SettingsScreen({super.key});

  /// Below this the detail column of the two-pane layout gets too narrow.
  static const _twoPaneMinWidth = 840.0;

  @override
  Widget buildViewWrapper({required Widget child}) {
    return child;
  }

  @override
  Widget buildMobilePortraitView(BuildContext context) {
    return const SettingsPortraitView();
  }

  @override
  Widget buildMobileLandscapeView(BuildContext context) {
    return const SettingsWideView(navWidth: 240);
  }

  /// Two panes only with room for both; a portrait tablet keeps the single
  /// centred column, which reads better than a nav pane beside a ~450dp
  /// detail column with most of the height empty.
  @override
  Widget buildTabletView(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= _twoPaneMinWidth
        ? const SettingsWideView()
        : const SettingsPortraitView();
  }
}
