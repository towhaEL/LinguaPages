import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/legal/legal_document.dart';

@RoutePage()
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LegalDocument(
      title: l10n.termsTitle,
      intro: l10n.termsIntro,
      keyPrefix: 'terms',
      sections: [
        (l10n.termsAgreementTitle, l10n.termsAgreementBody),
        (l10n.termsLicenseTitle, l10n.termsLicenseBody),
        (l10n.termsContentTitle, l10n.termsContentBody),
        (l10n.termsPremiumTitle, l10n.termsPremiumBody),
        (l10n.termsThirdPartyTitle, l10n.termsThirdPartyBody),
        (l10n.termsUseTitle, l10n.termsUseBody),
        (l10n.termsWarrantyTitle, l10n.termsWarrantyBody),
        (l10n.termsLiabilityTitle, l10n.termsLiabilityBody),
        (l10n.termsChangesTitle, l10n.termsChangesBody),
        (l10n.termsContactTitle, l10n.termsContactBody),
      ],
    );
  }
}
