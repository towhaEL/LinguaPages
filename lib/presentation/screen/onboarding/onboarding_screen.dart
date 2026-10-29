import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lingua_pages/core/constants/app_constant.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/core/storage/onboarding_preferences.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/theme/text/app_text.dart';

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
    final theme = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppConstant.horizontalGap20,
            AppConstant.verticalGap32,
            AppConstant.horizontalGap20,
            AppConstant.verticalGap20,
          ),
          children: [
            Container(
              height: 88,
              width: 88,
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Colors.white,
                size: 46,
              ),
            ),
            Gap(AppConstant.verticalGap24),
            AppText.displayMediumBold(l10n.onboardingTitle),
            Gap(AppConstant.verticalGap8),
            AppText.bodyLarge(
              l10n.onboardingSubtitle,
              color: theme.onSurface.withAlpha(180),
            ),
            Gap(AppConstant.verticalGap24),
            _OnboardingCard(
              icon: Icons.library_books_outlined,
              title: l10n.onboardingBooksTitle,
              body: l10n.onboardingBooksBody,
            ),
            Gap(AppConstant.verticalGap12),
            _OnboardingCard(
              icon: Icons.offline_bolt_outlined,
              title: l10n.onboardingOfflineTitle,
              body: l10n.onboardingOfflineBody,
            ),
            Gap(AppConstant.verticalGap12),
            _OnboardingCard(
              icon: Icons.touch_app_outlined,
              title: l10n.onboardingTapTitle,
              body: l10n.onboardingTapBody,
            ),
            if (_error != null) ...[
              Gap(AppConstant.verticalGap16),
              Text(_error!, style: TextStyle(color: theme.error)),
            ],
            Gap(AppConstant.verticalGap28),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _busy ? null : _continue,
                child: _busy
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.onboardingContinue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    return Container(
      padding: EdgeInsets.all(AppConstant.horizontalGap16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppConstant.borderRadius12),
        border: Border.all(color: theme.border.withAlpha(128)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.primary),
          Gap(AppConstant.horizontalGap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.bodyLarge(title, fontWeight: FontWeight.w700),
                Gap(AppConstant.verticalGap4),
                AppText.bodyMedium(body, color: theme.onSurface.withAlpha(170)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
