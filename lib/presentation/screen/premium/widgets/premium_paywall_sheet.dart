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

/// A calm offer, kept short: the looks themselves, what premium adds in one
/// line each, both plans at the store's prices, and a restore action. No
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
    final size = MediaQuery.sizeOf(context);
    // A landscape phone is too short to stack the offer above the plans.
    final sideBySide = size.width > size.height && size.height < 600;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: size.height * .92),
        child: BlocBuilder<PremiumCubit, PremiumState>(
          builder: (context, state) {
            final offer = _Offer(unlocked: state.unlocked);
            final decision = _decision(context, state);
            if (sideBySide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 12, 16),
                      child: offer,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 0, 24, 8),
                      child: decision,
                    ),
                  ),
                ],
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: offer,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: decision,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// The plans, the button and the fine print: the part that must stay in
  /// view.
  Widget _decision(BuildContext context, PremiumState state) {
    final l10n = context.l10n;
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final cubit = context.read<PremiumCubit>();
    final message = _message(context, state);
    final plan = _selected(state);
    final product = state.products[plan];
    final storeLoaded = state.products.isNotEmpty;

    Widget card(PremiumPlan option) => _PlanCard(
      key: Key('paywall_${option.name}_plan_card'),
      plan: option,
      product: state.products[option],
      storeLoaded: storeLoaded,
      selected: plan == option,
      yearly: state.products[PremiumPlan.yearly],
      onTap: () => setState(() => _picked = option),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!state.unlocked) ...[
          LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth < 320
                ? Column(
                    children: [
                      card(PremiumPlan.yearly),
                      const SizedBox(height: 8),
                      card(PremiumPlan.lifetime),
                    ],
                  )
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: card(PremiumPlan.yearly)),
                        const SizedBox(width: 8),
                        Expanded(child: card(PremiumPlan.lifetime)),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),
        ],
        if (message != null) ...[
          Semantics(
            liveRegion: true,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 8),
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
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: state.isBusy || (storeLoaded && product == null)
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
          const SizedBox(height: 6),
          Text(
            _finePrint(plan, product),
            textAlign: TextAlign.center,
            style: text.labelSmall?.copyWith(
              color: colors.onSurfaceMuted,
              fontWeight: FontWeight.w400,
              height: 1.35,
            ),
          ),
          TextButton(
            key: const Key('paywall_restore_button'),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            onPressed: state.isBusy ? null : cubit.restore,
            child: state.status == PremiumStatus.restoring
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.premiumRestore),
          ),
        ],
      ],
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
              'year. Cancel in Google Play before the trial ends and '
              "you won't be charged.",
        PremiumPlan.yearly =>
          'Renews yearly until you cancel. Cancel anytime in Google Play.',
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

/// The headline, what stays free, the looks and what premium adds.
class _Offer extends StatelessWidget {
  const _Offer({required this.unlocked});

  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            unlocked ? 'Thank you for reading with us' : 'Make every page yours',
            style: GoogleFonts.newsreader(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.15,
              color: colors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.premiumFreeNote,
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 1.35,
            color: colors.onSurfaceMuted,
          ),
        ),
        const SizedBox(height: 16),
        const _ThemeStrip(),
        const SizedBox(height: 14),
        const _Benefits(),
      ],
    );
  }
}

/// Every premium theme as a small page, its "Aa" set in a premium font, so
/// one row shows both the themes and the fonts.
class _ThemeStrip extends StatelessWidget {
  const _ThemeStrip();

  static final _themes = [
    for (final theme in ReaderTheme.values)
      if (theme.isPremium) theme,
  ];

  static final _fonts = [
    for (final font in ReaderFont.values)
      if (font.isPremium) font,
  ];

  String _label(BuildContext context, ReaderTheme theme) => switch (theme) {
    ReaderTheme.twilight => context.l10n.readerThemeTwilight,
    ReaderTheme.nightContrast => context.l10n.readerThemeNightContrast,
    ReaderTheme.sepiaContrast => context.l10n.readerThemeSepiaContrast,
    ReaderTheme.sage => context.l10n.readerThemeSage,
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      key: const Key('paywall_3theme_preview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, theme) in _themes.indexed) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: Semantics(
              label: _label(context, theme),
              excludeSemantics: true,
              child: Column(
                children: [
                  Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(theme.backgroundArgb),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: WarmEditorialTokens.hairlineDivider,
                      ),
                    ),
                    child: Text(
                      'Aa',
                      style: TextStyle(
                        fontFamily: _fonts.isEmpty
                            ? null
                            : _fonts[index % _fonts.length].family,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(theme.textArgb),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _label(context, theme),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// What premium adds, one line each, counted from the catalog so it stays
/// true.
class _Benefits extends StatelessWidget {
  const _Benefits();

  @override
  Widget build(BuildContext context) {
    final themes = ReaderTheme.values.where((t) => t.isPremium).length;
    final fonts = ReaderFont.values.where((f) => f.isPremium).length;
    final presets = AppearanceCatalog.presets.where((p) => p.isPremium).length;
    final accents = AppAccent.values.where((a) => a.isPremium).length;
    final items = [
      '$themes reading themes',
      '$fonts book fonts',
      '$presets style presets',
      '$accents app colours',
    ];
    final accent = context.accent;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: Row(
                  children: [
                    Icon(Icons.check_rounded, size: 16, color: accent),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        item,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: WarmEditorialTokens.textPrimaryInk,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
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
        : product.price;
    final trial = product?.freeTrialDays;
    final perMonth = product == null || plan != PremiumPlan.yearly
        ? null
        : _perMonth(product);
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
            ? 'Pay once, keep forever'
            : 'Less than $years ${years == 1 ? 'year' : 'years'} of yearly',
    };
    final muted = WarmEditorialTokens.subtitleSecondary;
    final ink = unavailable ? muted : WarmEditorialTokens.textPrimaryInk;

    return Semantics(
      selected: selected,
      button: true,
      enabled: !unavailable,
      child: Material(
        color: selected ? accent.withValues(alpha: 0.06) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? accent : WarmEditorialTokens.hairlineDivider,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: unavailable ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      size: 18,
                      color: selected ? accent : muted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    if (plan == PremiumPlan.lifetime) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'BEST VALUE',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text: price,
                    children: [
                      if (product != null)
                        TextSpan(
                          text: plan == PremiumPlan.yearly
                              ? ' / year'
                              : ' once',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: muted,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
                if (!unavailable) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      height: 1.3,
                      color: muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
