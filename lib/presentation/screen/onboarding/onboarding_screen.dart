import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/core/storage/onboarding_preferences.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/widgets/book/book_cover.dart';

/// First run: one screen, three facts, one action. The shelf of format
/// covers is the app's signature and its main promise at once.
@RoutePage()
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  var _busy = false;
  String? _error;

  Future<void> _continue() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await injector<OnboardingPreferences>().complete();
      if (!mounted) return;
      await context.router.replaceAll([const DashboardRoute()]);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = context.l10n.onboardingFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              children: [
                const _FormatShelf(),
                const SizedBox(height: 32),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.onboardingTitle,
                    style: text.headlineSmall?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      height: 1.15,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.onboardingSubtitle,
                  style: text.bodyLarge?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                for (final (icon, title, body) in [
                  (
                    Icons.auto_stories_outlined,
                    l10n.onboardingBooksTitle,
                    l10n.onboardingBooksBody,
                  ),
                  (
                    Icons.lock_outline_rounded,
                    l10n.onboardingOfflineTitle,
                    l10n.onboardingOfflineBody,
                  ),
                  (
                    Icons.text_fields_rounded,
                    l10n.onboardingTapTitle,
                    l10n.onboardingTapBody,
                  ),
                ]) ...[
                  _Point(icon: icon, title: title, body: body),
                  const SizedBox(height: 24),
                ],
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: text.bodyMedium?.copyWith(color: colors.error),
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _busy ? null : _continue,
                  child: _busy
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.onboardingContinue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Six plain covers, one per supported format, each with its band and code.
class _FormatShelf extends StatelessWidget {
  const _FormatShelf();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.onboardingFormatsLabel,
      excludeSemantics: true,
      // An explicit height: inside the scroll view the row's height is
      // unbounded, so the covers size themselves from the width here.
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 8.0;
          final count = DocumentFormat.values.length;
          final width = (constraints.maxWidth - gap * (count - 1)) / count;
          return SizedBox(
            height: width * 1.5,
            child: Row(
              children: [
                for (final (index, format)
                    in DocumentFormat.values.indexed) ...[
                  if (index > 0) const SizedBox(width: gap),
                  SizedBox(
                    width: width,
                    child: _FormatCover(format: format),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FormatCover extends StatelessWidget {
  const _FormatCover({required this.format});

  final DocumentFormat format;

  @override
  Widget build(BuildContext context) {
    final bands = context.bands;
    final band = bands.forFormat(format);
    final code = Text(
      formatCode(format),
      maxLines: 1,
      // Cover text keeps its proportions (DESIGN.md).
      textScaler: TextScaler.noScaling,
      style: TextStyle(
        color: bands.onBand,
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
    );
    return SizedBox.expand(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Column(
          // Childless bands would otherwise collapse to zero width.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 3, child: ColoredBox(color: band)),
            Expanded(flex: 4, child: ColoredBox(color: bands.label)),
            Expanded(
              flex: 3,
              child: ColoredBox(
                color: band,
                child: Center(
                  child: FittedBox(fit: BoxFit.scaleDown, child: code),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.onSurfaceMuted, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: text.bodyMedium?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
