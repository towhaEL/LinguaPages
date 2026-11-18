import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/core/storage/onboarding_preferences.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';

/// Continues the native launch screen (ink ground, the "op" mark)
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
            : OnboardingRoute(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fixed ink, not the theme canvas: this frame must match the native
      // launch screen exactly.
      backgroundColor: AppMark.ink,
      body: Center(
        child: Semantics(label: context.l10n.appName, child: const AppMark()),
      ),
    );
  }
}

/// The app icon's "op" mark (split O, bookmark p with a TXT-blue ribbon),
/// drawn on the icon's 108-unit grid so it lines up with the native launch
/// drawable.
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 108});

  /// Brand colours shared with the native icon and launch resources
  /// (`ic_launcher_background`, `ic_launcher_foreground.xml`), so they stay
  /// fixed whatever the app theme is.
  static const ink = Color(0xFF111315);
  static const cream = Color(0xFFF4F1EA);
  static const ribbonBlue = Color(0xFF5B8FD6);

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: const CustomPaint(
        painter: _AppMarkPainter(light: cream, ribbon: ribbonBlue),
      ),
    );
  }
}

class _AppMarkPainter extends CustomPainter {
  const _AppMarkPainter({required this.light, required this.ribbon});

  final Color light;
  final Color ribbon;

  @override
  void paint(Canvas canvas, Size size) {
    // Paths live on the 352×256 source grid (docs/brand/logo-op); this places
    // them on the 108 grid exactly like ic_launcher_foreground.xml.
    canvas
      ..scale(size.width / 108)
      ..translate(15.28, 26.06)
      ..scale(0.22);

    const r66 = Radius.circular(66);
    const r33 = Radius.circular(33);
    final lightPath = Path()
      // O, left half.
      ..moveTo(96, 34)
      ..arcToPoint(const Offset(96, 166), radius: r66, clockwise: false)
      ..lineTo(96, 133)
      ..arcToPoint(const Offset(96, 67), radius: r33)
      ..close()
      // O, right half, raised like a turning page.
      ..moveTo(104, 26)
      ..arcToPoint(const Offset(104, 158), radius: r66)
      ..lineTo(104, 125)
      ..arcToPoint(const Offset(104, 59), radius: r33, clockwise: false)
      ..close()
      // p: bowl and counter.
      ..addOval(Rect.fromCircle(center: const Offset(256, 96), radius: 66))
      ..addOval(Rect.fromLTRB(232, 67, 286, 125))
      ..fillType = PathFillType.evenOdd;
    // The stem overlaps the bowl, so draw it separately to keep even-odd
    // filling only for the counter.
    final stem = Path()..addRect(const Rect.fromLTRB(190, 32, 226, 164));
    final ribbonPath = Path()
      ..moveTo(190, 164)
      ..lineTo(226, 164)
      ..lineTo(226, 224)
      ..lineTo(208, 206)
      ..lineTo(190, 224)
      ..close();

    final paint = Paint()..color = light;
    canvas
      ..drawPath(lightPath, paint)
      ..drawPath(stem, paint)
      ..drawPath(ribbonPath, Paint()..color = ribbon);
  }

  @override
  bool shouldRepaint(_AppMarkPainter oldDelegate) =>
      oldDelegate.light != light || oldDelegate.ribbon != ribbon;
}
