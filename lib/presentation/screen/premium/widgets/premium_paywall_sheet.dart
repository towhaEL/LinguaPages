import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lingua_pages/domain/entity/premium/appearance_catalog.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/domain/service/billing_service.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_cubit.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_state.dart';
import 'package:lingua_pages/presentation/theme/app_accent_palette.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

/// Opens the premium offer.
Future<void> showPremiumPaywall(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const PremiumPaywallSheet(),
    );

/// A calm offer: it shows the looks themselves, both plans at the store's
/// prices, that everything else is free, and a restore action. No
/// countdowns, no pre-checked upsells, no guilt copy.
class PremiumPaywallSheet extends StatefulWidget {
  const PremiumPaywallSheet({super.key});

  @override
  State<PremiumPaywallSheet> createState() => _PremiumPaywallSheetState();
}

class _PremiumPaywallSheetState extends State<PremiumPaywallSheet> {
  /// Null until the user picks; then the store's offer decides the default.
  PremiumPlan? _picked;

  PremiumPlan _selected(PremiumState state) =>
      _picked ??
      (state.products.isEmpty || state.products.containsKey(PremiumPlan.yearly)
          ? PremiumPlan.yearly
          : PremiumPlan.lifetime);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .92,
        ),
        child: BlocBuilder<PremiumCubit, PremiumState>(
          builder: (context, state) {
            final cubit = context.read<PremiumCubit>();
            final message = _message(context, state);
            final plan = _selected(state);
            final product = state.products[plan];
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Eyebrow(unlocked: state.unlocked),
                        const SizedBox(height: 8),
                        Semantics(
                          header: true,
                          child: Text(
                            state.unlocked
                                ? 'Thank you for reading with us'
                                : 'Make every page yours',
                            style: GoogleFonts.newsreader(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Premium adds looks. Reading, notes, export, backup '
                          'and the dictionary stay free.',
                          style: text.bodyMedium?.copyWith(
                            color: colors.onSurfaceMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _HeroPreview(),
                        const SizedBox(height: 20),
                        const _Benefits(),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 20),
                        _Heading(l10n.premiumFontsHeading),
                        const SizedBox(height: 6),
                        for (final font in ReaderFont.values.where(
                          (font) => font.isPremium,
                        ))
                          _FontSample(font: font),
                        if (!state.unlocked) ...[
                          const SizedBox(height: 24),
                          _Heading('Choose your plan'),
                          const SizedBox(height: 10),
                          _PlanCard(
                            key: const Key('paywall_yearly_plan_card'),
                            plan: PremiumPlan.yearly,
                            product: state.products[PremiumPlan.yearly],
                            storeLoaded: state.products.isNotEmpty,
                            selected: plan == PremiumPlan.yearly,
                            onTap: () =>
                                setState(() => _picked = PremiumPlan.yearly),
                          ),
                          const SizedBox(height: 10),
                          _PlanCard(
                            key: const Key('paywall_lifetime_plan_card'),
                            plan: PremiumPlan.lifetime,
                            product: state.products[PremiumPlan.lifetime],
                            storeLoaded: state.products.isNotEmpty,
                            selected: plan == PremiumPlan.lifetime,
                            yearly: state.products[PremiumPlan.yearly],
                            onTap: () =>
                                setState(() => _picked = PremiumPlan.lifetime),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // The decision stays in view while the benefits scroll.
                DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: WarmEditorialTokens.hairlineDivider,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (message != null) ...[
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: text.bodyMedium?.copyWith(height: 1.45),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (state.unlocked)
                          FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.premiumDone),
                          )
                        else ...[
                          FilledButton(
                            key: const Key('paywall_unlock_button'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                            onPressed:
                                state.isBusy ||
                                    (state.products.isNotEmpty &&
                                        product == null)
                                ? null
                                : () => cubit.buy(plan),
                            child: state.status == PremiumStatus.purchasing
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(_cta(plan, product)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _finePrint(plan, product),
                            textAlign: TextAlign.center,
                            style: text.bodySmall?.copyWith(
                              color: colors.onSurfaceMuted,
                              height: 1.35,
                            ),
                          ),
                          TextButton(
                            key: const Key('paywall_restore_button'),
                            onPressed: state.isBusy ? null : cubit.restore,
                            child: state.status == PremiumStatus.restoring
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n.premiumRestore),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _cta(PremiumPlan plan, BillingProduct? product) {
    if (product == null) {
      return plan == PremiumPlan.yearly ? 'Subscribe yearly' : 'Unlock forever';
    }
    return switch (plan) {
      PremiumPlan.yearly when product.freeTrialDays != null =>
        'Start ${product.freeTrialDays}-day free trial',
      PremiumPlan.yearly => 'Subscribe for ${product.price} / year',
      PremiumPlan.lifetime => context.l10n.premiumUnlockFor(product.price),
    };
  }

  String _finePrint(PremiumPlan plan, BillingProduct? product) =>
      switch (plan) {
        PremiumPlan.yearly when product?.freeTrialDays != null =>
          'Free for ${product!.freeTrialDays} days, then ${product.price} a '
              'year. Cancel anytime in Google Play before the trial ends and '
              "you won't be charged.",
        PremiumPlan.yearly =>
          'Renews every year until you cancel. Cancel anytime in Google Play.',
        PremiumPlan.lifetime => context.l10n.premiumOneTime,
      };

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
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.unlocked});

  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: context.accentContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              unlocked ? Icons.verified_rounded : Icons.auto_awesome_rounded,
              size: 14,
              color: context.accent,
            ),
            const SizedBox(width: 6),
            Text(
              unlocked ? 'PATRON · ACTIVE' : 'LINGUAPAGES PATRON',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: context.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three premium page themes as small open pages.
class _HeroPreview extends StatelessWidget {
  const _HeroPreview();

  static const _themes = [
    ReaderTheme.sepiaContrast,
    ReaderTheme.twilight,
    ReaderTheme.sage,
  ];

  static final _fonts = [
    for (final font in ReaderFont.values)
      if (font.isPremium) font,
  ];

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        key: const Key('paywall_3theme_preview'),
        height: 132,
        child: Row(
          children: [
            for (final (index, theme) in _themes.indexed) ...[
              if (index > 0) const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(theme.backgroundArgb),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: WarmEditorialTokens.hairlineDivider,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chapter ${index + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: Color(theme.textArgb).withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          'It was a bright cold day, and the pages turned '
                          'themselves in the quiet light.',
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontFamily: _fonts.isEmpty
                                ? null
                                : _fonts[index % _fonts.length].family,
                            fontSize: 12,
                            height: 1.35,
                            color: Color(theme.textArgb),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// What premium includes, counted from the catalog so it stays true.
class _Benefits extends StatelessWidget {
  const _Benefits();

  @override
  Widget build(BuildContext context) {
    final themes = ReaderTheme.values.where((t) => t.isPremium).length;
    final fonts = ReaderFont.values.where((f) => f.isPremium).length;
    final presets = AppearanceCatalog.presets.where((p) => p.isPremium).length;
    final accents = AppAccent.values.where((a) => a.isPremium).toList();
    final rows = [
      (
        Icons.palette_outlined,
        '$themes extra reading themes',
        'Twilight, high-contrast night and sepia, and Sage.',
      ),
      (
        Icons.text_fields_rounded,
        '$fonts book fonts',
        'Literata, Source Serif and EB Garamond, set for long reading.',
      ),
      (
        Icons.tune_rounded,
        '$presets style presets',
        context.l10n.premiumPresets,
      ),
      (
        Icons.color_lens_outlined,
        '${accents.length} app colour themes',
        '${accents.map((a) => a.label).join(', ')}.',
      ),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      decoration: BoxDecoration(
        color: WarmEditorialTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WarmEditorialTokens.hairlineDivider),
      ),
      child: Column(
        children: [
          for (final (icon, title, body) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.accentContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 17, color: context.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: WarmEditorialTokens.textPrimaryInk,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          body,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            height: 1.35,
                            color: WarmEditorialTokens.subtitleSecondary,
                          ),
                        ),
                      ],
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

/// One plan, as a radio card with the store's price.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.product,
    required this.storeLoaded,
    required this.selected,
    required this.onTap,
    this.yearly,
    super.key,
  });

  final PremiumPlan plan;
  final BillingProduct? product;

  /// Whether the store answered; a missing [product] then means the plan is
  /// not offered rather than still loading.
  final bool storeLoaded;
  final bool selected;
  final VoidCallback onTap;

  /// The yearly plan, for showing how soon lifetime pays for itself.
  final BillingProduct? yearly;

  String? _perMonth(BillingProduct product) {
    final raw = product.rawPrice;
    final currency = product.currencyCode;
    if (raw == null || currency == null) return null;
    return NumberFormat.simpleCurrency(name: currency).format(raw / 12);
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    final product = this.product;
    final unavailable = storeLoaded && product == null;
    final title = plan == PremiumPlan.yearly ? 'Yearly' : 'Lifetime';
    final price = product == null
        ? (unavailable ? 'Not available' : '…')
        : plan == PremiumPlan.yearly
        ? '${product.price} / year'
        : '${product.price} once';
    final perMonth = product == null || plan != PremiumPlan.yearly
        ? null
        : _perMonth(product);
    final trial = product?.freeTrialDays;
    final yearlyRaw = yearly?.rawPrice;
    final lifetimeRaw = product?.rawPrice;
    final years =
        plan == PremiumPlan.lifetime &&
            yearlyRaw != null &&
            lifetimeRaw != null &&
            yearlyRaw > 0
        ? (lifetimeRaw / yearlyRaw).ceil()
        : null;
    final detail = switch (plan) {
      PremiumPlan.yearly => [
        ?perMonth == null ? null : '$perMonth / month',
        if (trial != null) '$trial-day free trial' else 'Cancel anytime',
      ].join(' · '),
      PremiumPlan.lifetime =>
        years == null
            ? 'Pay once, keep it forever'
            : 'Pay once, keep it forever · '
                  'costs less than $years ${years == 1 ? 'year' : 'years'}',
    };

    return Semantics(
      selected: selected,
      button: true,
      enabled: !unavailable,
      child: Material(
        color: selected ? accent.withValues(alpha: 0.06) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? accent : WarmEditorialTokens.hairlineDivider,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: unavailable ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected
                      ? accent
                      : WarmEditorialTokens.subtitleSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: unavailable
                                  ? WarmEditorialTokens.subtitleSecondary
                                  : WarmEditorialTokens.textPrimaryInk,
                            ),
                          ),
                          if (plan == PremiumPlan.lifetime) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'BEST VALUE',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (!unavailable) ...[
                        const SizedBox(height: 3),
                        Text(
                          detail,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: WarmEditorialTokens.subtitleSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  price,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: unavailable
                        ? WarmEditorialTokens.subtitleSecondary
                        : WarmEditorialTokens.textPrimaryInk,
                  ),
                ),
              ],
            ),
          ),
        ),
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
