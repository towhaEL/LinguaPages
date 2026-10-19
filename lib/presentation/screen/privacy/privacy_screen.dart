import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lingua_pages/core/constants/app_constant.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/theme/text/app_text.dart';
import 'package:lingua_pages/presentation/widgets/app_bar/widgets.dart';

@RoutePage()
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: theme.background,
      appBar: CustomAppBar(title: l10n.privacyTitle),
      body: ListView(
        padding: EdgeInsets.all(AppConstant.horizontalGap16),
        children: [
          _PrivacySection(
            icon: Icons.phone_android_outlined,
            title: l10n.privacyLocalDataTitle,
            body: l10n.privacyLocalDataBody,
          ),
          Gap(AppConstant.verticalGap16),
          _PrivacySection(
            icon: Icons.backup_outlined,
            title: l10n.privacyBackupTitle,
            body: l10n.privacyBackupBody,
          ),
          Gap(AppConstant.verticalGap16),
          _PrivacySection(
            icon: Icons.translate_outlined,
            title: l10n.privacyTranslationTitle,
            body: l10n.privacyTranslationBody,
          ),
        ],
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.primary),
          Gap(AppConstant.verticalGap12),
          AppText.titleMedium(title, fontWeight: FontWeight.w700),
          Gap(AppConstant.verticalGap8),
          AppText.bodyMedium(body, color: theme.onSurface.withAlpha(180)),
        ],
      ),
    );
  }
}
