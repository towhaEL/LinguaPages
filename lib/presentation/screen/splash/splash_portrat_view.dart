import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/core/storage/onboarding_preferences.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

/// Continues the native launch screen (ink ground, the three-paperback mark)
/// for exactly one frame, then routes. No artificial delay: the reader wants
/// their book, not a logo.
class SplashPortraitView extends StatefulWidget {
  const SplashPortraitView({super.key});

  @override
  State<SplashPortraitView> createState() => _SplashPortraitViewState();
}

class _SplashPortraitViewState extends State<SplashPortraitView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.replaceRoute(
        injector<OnboardingPreferences>().isComplete
            ? const DashboardRoute()
            : const OnboardingRoute(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: Semantics(label: context.l10n.appName, child: const AppMark()),
      ),
    );
  }
}

/// The app icon's three paperbacks, drawn on the icon's 108-unit grid so it
/// lines up with the native launch drawable.
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 108});

  final double size;

  @override
  Widget build(BuildContext context) {
    final bands = context.bands;
    final unit = size / 108;
    // (colour, left, top, height, band) on the 108 grid; every book is 12 wide.
    final books = [
      (bands.epub, 33.0, 40.0, 40.0, 9.0),
      (bands.pdf, 48.0, 34.0, 46.0, 10.0),
      (bands.txt, 63.0, 44.0, 36.0, 8.0),
    ];
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          for (final (color, left, top, height, band) in books)
            Positioned(
              left: left * unit,
              top: top * unit,
              width: 12 * unit,
              height: height * unit,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(height: band * unit, color: color),
                  Expanded(child: ColoredBox(color: bands.label)),
                  Container(height: band * unit, color: color),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
