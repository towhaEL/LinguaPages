import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/widgets/app_bar/widgets.dart';

/// A short reading page, not a set of cards: headings and paragraphs at a
/// comfortable measure.
@RoutePage()
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sections = [
      (l10n.privacyLocalDataTitle, l10n.privacyLocalDataBody),
      (l10n.privacyDictionaryTitle, l10n.privacyDictionaryBody),
      (l10n.privacyBackupTitle, l10n.privacyBackupBody),
      (l10n.privacyPurchasesTitle, l10n.privacyPurchasesBody),
      (l10n.privacyTrackingTitle, l10n.privacyTrackingBody),
    ];
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: CustomAppBar(title: l10n.privacyTitle, showBackIcon: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (index, (title, body)) in sections.indexed) ...[
                    if (index > 0) const SizedBox(height: 28),
                    _Section(title: title, body: body),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        Text(body, style: text.bodyLarge?.copyWith(height: 1.55)),
      ],
    );
  }
}
