import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lingua_pages/domain/entity/premium/appearance_catalog.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/domain/service/billing_service.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_cubit.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_state.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

/// Opens the premium offer as a full-screen sheet.
Future<void> showPremiumPaywall(BuildContext context) {
  unawaited(context.read<PremiumCubit>().paywallOpened());
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    builder: (_) => const PremiumPaywallSheet(),
  );
}

/// A calm offer, read top to bottom: close and restore, the headline, the
/// plans at the store's prices, what premium adds, then the legal links. No
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
    return SizedBox(
      height: double.infinity,
      child: BlocBuilder<PremiumCubit, PremiumState>(
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopBar(state: state),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Center(
                  // Tablets keep the reading width of a phone.
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: _content(context, state),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, PremiumState state) {
    final l10n = context.l10n;
    final colors = context.colors;
    final message = _message(context, state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            state.unlocked
                ? 'Thank you for reading with us'
                : 'Make every page yours',
            textAlign: TextAlign.center,
            style: GoogleFonts.newsreader(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              height: 1.15,
              color: colors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.premiumFreeNote,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.4,
            color: colors.onSurfaceMuted,
          ),
        ),
        const SizedBox(height: 24),
        if (!state.unlocked) ...[
          _products(state),
          const SizedBox(height: 12),
        ],
        if (message != null) ...[
          Semantics(
            liveRegion: true,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        _action(context, state),
        const SizedBox(height: 32),
        const _Features(),
        const SizedBox(height: 24),
        const _LegalLinks(),
      ],
    );
  }

  /// The plans, one under the other.
  Widget _products(PremiumState state) {
    final plan = _selected(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, option) in PremiumPlan.values.indexed) ...[
          if (index > 0) const SizedBox(height: 10),
          _PlanCard(
            key: Key('paywall_${option.name}_plan_card'),
            plan: option,
            product: state.products[option],
            storeLoaded: state.products.isNotEmpty,
            selected: plan == option,
            yearly: state.products[PremiumPlan.yearly],
            onTap: () => setState(() => _picked = option),
          ),
        ],
      ],
    );
  }

  /// The buy button and its fine print, or Done once unlocked.
  Widget _action(BuildContext context, PremiumState state) {
    final colors = context.colors;
    if (state.unlocked) {
      return FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        onPressed: () => Navigator.of(context).pop(),
        child: Text(context.l10n.premiumDone),
      );
    }
    final plan = _selected(state);
    final product = state.products[plan];
    final storeLoaded = state.products.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          key: const Key('paywall_unlock_button'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: state.isBusy || (storeLoaded && product == null)
              ? null
              : () => context.read<PremiumCubit>().buy(plan),
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
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceMuted,
            fontWeight: FontWeight.w400,
            height: 1.35,
          ),
        ),
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

/// Close on the left, restore on the right.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.state});

  final PremiumState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          const _DelayedCloseButton(),
          const Spacer(),
          if (!state.unlocked)
            TextButton(
              key: const Key('paywall_restore_button'),
              onPressed: state.isBusy
                  ? null
                  : context.read<PremiumCubit>().restore,
              child: state.status == PremiumStatus.restoring
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.premiumRestore),
            ),
        ],
      ),
    );
  }
}

/// Starts dimmed and inactive, so the offer gets a moment to be read, then
/// becomes a normal close button.
class _DelayedCloseButton extends StatefulWidget {
  const _DelayedCloseButton();

  static const delay = Duration(seconds: 2);

  @override
  State<_DelayedCloseButton> createState() => _DelayedCloseButtonState();
}

class _DelayedCloseButtonState extends State<_DelayedCloseButton> {
  late final Timer _timer;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      _DelayedCloseButton.delay,
      () => setState(() => _active = true),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _active ? 1 : 0.5,
      duration: const Duration(milliseconds: 250),
      child: IconButton(
        key: const Key('paywall_close_button'),
        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        icon: const Icon(Icons.close_rounded),
        color: context.colors.onSurface,
        // Keep the full colour; the opacity above does the dimming.
        disabledColor: context.colors.onSurface,
        onPressed: _active ? () => Navigator.of(context).pop() : null,
      ),
    );
  }
}

/// What premium adds: the looks themselves, then one line each, counted from
/// the catalog so it stays true.
class _Features extends StatelessWidget {
  const _Features();

  @override
  Widget build(BuildContext context) {
    final themes = ReaderTheme.values.where((t) => t.isPremium).length;
    final fonts = ReaderFont.values.where((f) => f.isPremium).length;
    final presets = AppearanceCatalog.presets.where((p) => p.isPremium).length;
    final accents = AppAccent.values.where((a) => a.isPremium).length;
    final items = [
      (Icons.palette_outlined, '$themes reading themes'),
      (Icons.text_fields_rounded, '$fonts book fonts'),
      (Icons.tune_rounded, '$presets style presets'),
      (Icons.color_lens_outlined, '$accents app colours'),
    ];
    final accent = context.accent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            "WHAT'S INCLUDED",
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: context.colors.onSurfaceMuted,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _ThemeStrip(),
        const SizedBox(height: 16),
        for (final (icon, label) in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
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

/// Privacy policy and terms, at the foot of the offer.
class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.onSurfaceMuted;
    final style = TextButton.styleFrom(
      foregroundColor: muted,
      visualDensity: VisualDensity.compact,
      textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
    );
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TextButton(
          key: const Key('paywall_privacy_button'),
          style: style,
          onPressed: () => context.router.root.push(const PrivacyRoute()),
          child: const Text('Privacy Policy'),
        ),
        Text('·', style: TextStyle(color: muted)),
        TextButton(
          key: const Key('paywall_terms_button'),
          style: style,
          onPressed: () => context.router.root.push(const TermsRoute()),
          child: const Text('Terms of Use'),
        ),
      ],
    );
  }
}

/// One plan as a full-width radio row: name and detail on the left, the
/// store's price on the right.
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
            padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 22,
                  color: selected ? accent : muted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: ink,
                              ),
                            ),
                          ),
                          if (plan == PremiumPlan.lifetime) ...[
                            const SizedBox(width: 8),
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
                      if (!unavailable) ...[
                        const SizedBox(height: 2),
                        Text(
                          detail,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            height: 1.3,
                            color: muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // A long localized price shrinks rather than crowding the
                // plan's name.
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          price,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                      ),
                      if (product != null)
                        Text(
                          plan == PremiumPlan.yearly ? 'per year' : 'once',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: muted,
                          ),
                        ),
                    ],
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
