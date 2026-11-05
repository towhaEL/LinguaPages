import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/domain/entity/premium/appearance_catalog.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_cubit.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_state.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

/// Opens the premium appearance offer.
Future<void> showPremiumPaywall(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const PremiumPaywallSheet(),
    );

/// A calm offer: it shows the looks themselves, the store's price, that
/// everything else is free, and a restore action. No countdowns, no
/// pre-checked upsells, no guilt copy.
class PremiumPaywallSheet extends StatelessWidget {
  const PremiumPaywallSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: BlocBuilder<PremiumCubit, PremiumState>(
            builder: (context, state) {
              final cubit = context.read<PremiumCubit>();
              final message = _message(context, state);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Make every page yours',
                      style: GoogleFonts.newsreader(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Unlock premium reading themes, handcrafted fonts, and visual style presets.',
                    style: text.bodyMedium?.copyWith(
                      color: colors.onSurfaceMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 3-Theme Hero Carousel Preview
                  Row(
                    key: const Key('paywall_3theme_preview'),
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildHeroThemeCard('Warm Linen', const Color(0xFFF5EFEB), const Color(0xFF2D2A26)),
                      _buildHeroThemeCard('Midnight', const Color(0xFF161E2E), const Color(0xFFFAF7F2)),
                      _buildHeroThemeCard('Forest', const Color(0xFF1B2921), const Color(0xFFF3EFEA)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _Heading(l10n.premiumThemesHeading),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // Two-line labels must not lift their swatch.
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final theme in ReaderTheme.values.where(
                        (theme) => theme.isPremium,
                      ))
                        _ThemeSample(theme: theme),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _Heading(l10n.premiumFontsHeading),
                  const SizedBox(height: 10),
                  for (final font in ReaderFont.values.where(
                    (font) => font.isPremium,
                  ))
                    _FontSample(font: font),
                  const SizedBox(height: 20),
                  _Heading(l10n.premiumPresetsHeading),
                  const SizedBox(height: 6),
                  Text(l10n.premiumPresets, style: text.bodyMedium),
                  const SizedBox(height: 24),
                  // Reassuring Ethos Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.hairline),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.verified_user_outlined, size: 20, color: colors.onSurfaceMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.premiumFreeNote,
                            style: text.bodySmall?.copyWith(
                              color: colors.onSurfaceMuted,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Plan Option Card (Lifetime)
                  Card(
                    key: const Key('paywall_lifetime_plan_card'),
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: WarmEditorialTokens.accentInkBlue, width: 2),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: const Icon(Icons.radio_button_checked, color: WarmEditorialTokens.accentInkBlue),
                      title: Text(
                        'Lifetime — \$14.99 one-time',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: Text(
                        'Pay once. Own it forever.',
                        style: GoogleFonts.inter(fontSize: 12, color: colors.onSurfaceMuted),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (message != null) ...[
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: text.bodyMedium?.copyWith(height: 1.45),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (state.unlocked)
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.premiumDone),
                    )
                  else ...[
                    FilledButton(
                      key: const Key('paywall_unlock_button'),
                      style: FilledButton.styleFrom(
                        backgroundColor: WarmEditorialTokens.accentInkBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: state.isBusy ? null : cubit.buy,
                      child: state.status == PremiumStatus.purchasing
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              state.product == null
                                  ? 'Unlock Premium'
                                  : l10n.premiumUnlockFor(state.product!.price),
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      key: const Key('paywall_restore_button'),
                      onPressed: state.isBusy ? null : cubit.restore,
                      child: state.status == PremiumStatus.restoring
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.premiumRestore),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String? _message(BuildContext context, PremiumState state) {
    final l10n = context.l10n;
    if (state.unlocked) {
      // Thanks only for a purchase or restore just made, not for a build
      // where everything is unlocked anyway.
      return state.status == PremiumStatus.purchased ||
              state.status == PremiumStatus.restored
          ? l10n.premiumThankYou
          : l10n.premiumUnlocked;
    }
    return switch (state.status) {
      PremiumStatus.pending => l10n.premiumPending,
      PremiumStatus.nothingToRestore => l10n.premiumNothingToRestore,
      PremiumStatus.storeUnavailable => l10n.premiumStoreUnavailable,
      PremiumStatus.failed => l10n.premiumFailed,
      _ => null,
    };
  }

  Widget _buildHeroThemeCard(String name, Color bg, Color textColor) {
    return Container(
      width: 96,
      height: 110,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WarmEditorialTokens.hairlineDivider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
          Text(
            '“A book has a soul…”',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.newsreader(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: textColor,
            ),
          ),
          Container(
            height: 2,
            width: 24,
            color: textColor.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// A page swatch with "Aa" in the theme's own colours.
class _ThemeSample extends StatelessWidget {
  const _ThemeSample({required this.theme});

  final ReaderTheme theme;

  String _label(BuildContext context) => switch (theme) {
    ReaderTheme.twilight => context.l10n.readerThemeTwilight,
    ReaderTheme.nightContrast => context.l10n.readerThemeNightContrast,
    ReaderTheme.sepiaContrast => context.l10n.readerThemeSepiaContrast,
    ReaderTheme.sage => context.l10n.readerThemeSage,
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final label = _label(context);
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(theme.backgroundArgb),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Text(
                'Aa',
                style: text.titleLarge?.copyWith(
                  color: Color(theme.textArgb),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: text.labelMedium?.copyWith(
                color: colors.onSurfaceMuted,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The font's name set in the font itself, so the sample is the claim.
class _FontSample extends StatelessWidget {
  const _FontSample({required this.font});

  final ReaderFont font;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        font.family!,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontFamily: font.family, fontSize: 22),
      ),
    );
  }
}
