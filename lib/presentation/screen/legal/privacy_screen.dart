import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/legal/legal_document.dart';

@RoutePage()
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LegalDocument(
      title: l10n.privacyTitle,
      intro: l10n.privacyIntro,
      keyPrefix: 'privacy',
      sections: [
        (l10n.privacyCollectTitle, l10n.privacyCollectBody),
        (l10n.privacyDeviceTitle, l10n.privacyDeviceBody),
        (l10n.privacyLookupTitle, l10n.privacyLookupBody),
        (l10n.privacyListenTitle, l10n.privacyListenBody),
        (l10n.privacyBackupTitle, l10n.privacyBackupBody),
        (l10n.privacyPurchasesTitle, l10n.privacyPurchasesBody),
        (l10n.privacyTrackingTitle, l10n.privacyTrackingBody),
        (l10n.privacyPermissionsTitle, l10n.privacyPermissionsBody),
        (l10n.privacyChildrenTitle, l10n.privacyChildrenBody),
        (l10n.privacyChangesTitle, l10n.privacyChangesBody),
      ],
    );
  }
}
