import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_cubit.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';

/// Standalone Appearance Bottom Sheet matching Stitch screen 04b_appearance_sheet (d8bb2a41).
class AppearanceSheet extends StatefulWidget {
  const AppearanceSheet({
    super.key,
    this.settings,
    this.isPdf = false,
    this.isFallbackPdf = false,
    this.usesReadium = false,
    this.onChanged,
    this.selectedTheme,
    this.onThemeSelected,
    this.fontSize,
    this.onFontSizeChanged,
    this.onReset,
  });

  final SettingsEntity? settings;
  final bool isPdf;
  final bool isFallbackPdf;
  final bool usesReadium;
  final ValueChanged<SettingsEntity>? onChanged;

  /// Standalone contract overrides for testing / external callers
  final String? selectedTheme;
  final ValueChanged<String>? onThemeSelected;
  final double? fontSize;
  final ValueChanged<double>? onFontSizeChanged;
  final VoidCallback? onReset;

  @override
  State<AppearanceSheet> createState() => _AppearanceSheetState();
}

class _AppearanceSheetState extends State<AppearanceSheet> {
  late SettingsEntity _settings = widget.settings ?? const SettingsEntity();
  late String _activeThemeName = widget.selectedTheme ?? _themeToName(_settings.readerTheme);
  late double _fontSize = widget.fontSize ?? _settings.fontSize.clamp(12.0, 28.0);
  late double _lineSpacing = _settings.lineSpacing.clamp(1.1, 2.2);
  late double _margin = _settings.margin.clamp(12.0, 44.0);
  double _brightness = 0.85;
  bool _followSystemBrightness = false;

  static String _themeToName(ReaderTheme theme) => switch (theme) {
        ReaderTheme.light => 'Paper',
        ReaderTheme.sepia => 'Sepia',
        ReaderTheme.dark => 'Night',
        ReaderTheme.nightContrast => 'OLED',
        ReaderTheme.sage => 'Grey',
        _ => 'White',
      };

  static ReaderTheme _nameToTheme(String name) => switch (name) {
        'Paper' => ReaderTheme.light,
        'White' => ReaderTheme.light,
        'Sepia' => ReaderTheme.sepia,
        'Grey' => ReaderTheme.sage,
        'Night' => ReaderTheme.dark,
        'OLED' => ReaderTheme.nightContrast,
        _ => ReaderTheme.light,
      };

  @override
  void didUpdateWidget(covariant AppearanceSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.settings != null && widget.settings != oldWidget.settings) {
      _settings = widget.settings!;
      _activeThemeName = widget.selectedTheme ?? _themeToName(_settings.readerTheme);
      _fontSize = widget.fontSize ?? _settings.fontSize.clamp(12.0, 28.0);
      _lineSpacing = _settings.lineSpacing.clamp(1.1, 2.2);
      _margin = _settings.margin.clamp(12.0, 44.0);
    }
    if (widget.selectedTheme != null && widget.selectedTheme != oldWidget.selectedTheme) {
      _activeThemeName = widget.selectedTheme!;
    }
    if (widget.fontSize != null && widget.fontSize != oldWidget.fontSize) {
      _fontSize = widget.fontSize!;
    }
  }

  void _updateSettings(SettingsEntity next) {
    setState(() => _settings = next);
    widget.onChanged?.call(next);
  }

  void _selectTheme(String name, bool isLocked, bool premiumUnlocked) {
    setState(() => _activeThemeName = name);
    widget.onThemeSelected?.call(name);

    final mappedTheme = _nameToTheme(name);
    _updateSettings(_settings.copyWith(readerTheme: mappedTheme));
  }

  void _changeFontSize(double val) {
    setState(() => _fontSize = val);
    widget.onFontSizeChanged?.call(val);
    _updateSettings(_settings.copyWith(fontSize: val));
  }

  void _reset() {
    if (widget.onReset != null) {
      widget.onReset!();
      return;
    }
    const defaultSettings = SettingsEntity();
    setState(() {
      _settings = defaultSettings;
      _activeThemeName = 'Paper';
      _fontSize = 18;
      _lineSpacing = 1.5;
      _margin = 16;
      _brightness = 0.85;
      _followSystemBrightness = false;
    });
    widget.onThemeSelected?.call('Paper');
    widget.onFontSizeChanged?.call(18);
    widget.onChanged?.call(defaultSettings);
  }

  @override
  Widget build(BuildContext context) {
    // If wrapped in BlocProvider for PremiumCubit, check unlocked status
    bool premiumUnlocked = false;
    try {
      final state = context.watch<PremiumCubit>().state;
      premiumUnlocked = state.unlocked;
    } catch (_) {
      // Standalone test harness context where cubit is not provided
    }

    final swatches = [
      ('Paper', const Color(0xFFF6F1E7), false),
      ('White', const Color(0xFFFFFFFF), false),
      ('Sepia', const Color(0xFFF4ECD8), false),
      ('Grey', const Color(0xFFEAE6DF), false),
      ('Night', const Color(0xFF23272A), true),
      ('OLED', const Color(0xFF121212), true),
    ];

    final typefaces = [
      (ReaderFont.serif, 'Newsreader', 'Default', 'Newsreader'),
      (ReaderFont.sans, 'Inter', 'Modern Sans', 'Inter'),
      (ReaderFont.literata, 'Literata', 'Book Serif', 'Literata'),
      (ReaderFont.ebGaramond, 'Garamond', 'Classic', 'EB Garamond'),
      (ReaderFont.sourceSerif, 'Source Serif', 'Warm', 'Source Serif 4'),
    ];

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(WarmEditorialTokens.bottomSheetRadius)),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCEC5BB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 6),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Appearance',
                            style: TextStyle(
                              fontFamily: 'Newsreader',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: WarmEditorialTokens.textPrimaryInk,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Offline reading aesthetics',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: WarmEditorialTokens.subtitleSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _reset,
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: WarmEditorialTokens.subtitleSecondary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: WarmEditorialTokens.subtitleSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),

              // Scrollable Settings
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                  children: [
                    // SECTION 1: Page Tone / Reading Themes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Page Theme',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: WarmEditorialTokens.textPrimaryInk,
                            ),
                          ),
                        ),
                        Text(
                          _activeThemeName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: WarmEditorialTokens.subtitleSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final (name, color, isLocked) in swatches)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 7),
                              child: GestureDetector(
                                key: Key('swatch_$name'),
                                onTap: () => _selectTheme(name, isLocked, premiumUnlocked),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _activeThemeName == name
                                              ? WarmEditorialTokens.accentInkBlue
                                              : (color == Colors.white
                                                  ? WarmEditorialTokens.hairlineDivider
                                                  : Colors.transparent),
                                          width: _activeThemeName == name ? 2.5 : 1.0,
                                        ),
                                        boxShadow: [
                                          if (_activeThemeName == name)
                                            BoxShadow(
                                              color: WarmEditorialTokens.accentInkBlue.withValues(alpha: 0.2),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                        ],
                                      ),
                                      child: isLocked && !premiumUnlocked
                                          ? const Center(
                                              child: Icon(
                                                Icons.lock,
                                                size: 16,
                                                color: Color(0xFF6B401E),
                                              ),
                                            )
                                          : (_activeThemeName == name
                                              ? Icon(
                                                  Icons.check,
                                                  size: 18,
                                                  color: (color == const Color(0xFF23272A) || color == const Color(0xFF121212))
                                                      ? Colors.white
                                                      : WarmEditorialTokens.accentInkBlue,
                                                )
                                              : null),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        fontWeight: _activeThemeName == name ? FontWeight.w600 : FontWeight.w400,
                                        color: _activeThemeName == name
                                            ? WarmEditorialTokens.accentInkBlue
                                            : WarmEditorialTokens.subtitleSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                    const SizedBox(height: 10),

                    // SECTION 2: Typeface Selection
                    if (!widget.isPdf) ...[
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Typeface',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: WarmEditorialTokens.textPrimaryInk,
                              ),
                            ),
                          ),
                          Text(
                            'Editorial Serif',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: WarmEditorialTokens.subtitleSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final (font, title, subtitle, family) in typefaces)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    _updateSettings(_settings.copyWith(readerFont: font));
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _settings.readerFont == font
                                          ? WarmEditorialTokens.accentInkBlue
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _settings.readerFont == font
                                            ? WarmEditorialTokens.accentInkBlue
                                            : WarmEditorialTokens.hairlineDivider,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Aa',
                                          style: TextStyle(
                                            fontFamily: family,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: _settings.readerFont == font
                                                ? Colors.white
                                                : WarmEditorialTokens.textPrimaryInk,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              title,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: _settings.readerFont == font
                                                    ? Colors.white
                                                    : WarmEditorialTokens.textPrimaryInk,
                                              ),
                                            ),
                                            Text(
                                              subtitle,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 10,
                                                color: _settings.readerFont == font
                                                    ? Colors.white70
                                                    : WarmEditorialTokens.subtitleSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (_settings.readerFont == font) ...[
                                          const SizedBox(width: 6),
                                          const Icon(Icons.check, size: 16, color: Colors.white),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                      const SizedBox(height: 8),
                    ],

                    // SECTION 3: Typography & Spacing Sliders
                    const Text(
                      'Typography & Spacing',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: WarmEditorialTokens.textPrimaryInk,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Font Size Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: WarmEditorialTokens.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: WarmEditorialTokens.hairlineDivider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Font Size',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: WarmEditorialTokens.subtitleSecondary,
                                  ),
                                ),
                              ),
                              Text(
                                '${_fontSize.round()} pt',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: WarmEditorialTokens.accentInkBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Text('A−', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: WarmEditorialTokens.accentInkBlue,
                                    thumbColor: WarmEditorialTokens.accentInkBlue,
                                  ),
                                  child: Slider(
                                    key: const Key('appearance_font_slider'),
                                    value: _fontSize.clamp(12.0, 28.0),
                                    min: 12,
                                    max: 28,
                                    onChanged: _changeFontSize,
                                  ),
                                ),
                              ),
                              const Text('A+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Line Spacing Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: WarmEditorialTokens.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: WarmEditorialTokens.hairlineDivider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Line Spacing',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: WarmEditorialTokens.subtitleSecondary,
                                  ),
                                ),
                              ),
                              Text(
                                '${_lineSpacing.toStringAsFixed(1)}×',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: WarmEditorialTokens.accentInkBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.format_line_spacing, size: 18, color: WarmEditorialTokens.subtitleSecondary),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: WarmEditorialTokens.accentInkBlue,
                                    thumbColor: WarmEditorialTokens.accentInkBlue,
                                  ),
                                  child: Slider(
                                    value: _lineSpacing.clamp(1.1, 2.2),
                                    min: 1.1,
                                    max: 2.2,
                                    divisions: 11,
                                    onChanged: (val) {
                                      setState(() => _lineSpacing = val);
                                      _updateSettings(_settings.copyWith(lineSpacing: val));
                                    },
                                  ),
                                ),
                              ),
                              const Icon(Icons.density_medium, size: 20, color: WarmEditorialTokens.subtitleSecondary),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Side Margins Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: WarmEditorialTokens.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: WarmEditorialTokens.hairlineDivider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Side Margins',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: WarmEditorialTokens.subtitleSecondary,
                                  ),
                                ),
                              ),
                              Text(
                                '${_margin.round()} px',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: WarmEditorialTokens.accentInkBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.width_normal, size: 18, color: WarmEditorialTokens.subtitleSecondary),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: WarmEditorialTokens.accentInkBlue,
                                    thumbColor: WarmEditorialTokens.accentInkBlue,
                                  ),
                                  child: Slider(
                                    value: _margin.clamp(12.0, 44.0),
                                    min: 12,
                                    max: 44,
                                    divisions: 16,
                                    onChanged: (val) {
                                      setState(() => _margin = val);
                                      _updateSettings(_settings.copyWith(margin: val));
                                    },
                                  ),
                                ),
                              ),
                              const Icon(Icons.width_wide, size: 18, color: WarmEditorialTokens.subtitleSecondary),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                    const SizedBox(height: 10),

                    // SECTION 4: Layout & Flow
                    const Text(
                      'Layout & Flow',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: WarmEditorialTokens.textPrimaryInk,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Segmented Control (Scroll / Pages / Two Columns)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBE8E3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _updateSettings(
                                  _settings.copyWith(
                                    readerMode: ReaderMode.continuous,
                                    readerColumns: ReaderColumns.one,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _settings.readerMode == ReaderMode.continuous
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: _settings.readerMode == ReaderMode.continuous
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  'Scroll',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: _settings.readerMode == ReaderMode.continuous
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: _settings.readerMode == ReaderMode.continuous
                                        ? WarmEditorialTokens.accentInkBlue
                                        : WarmEditorialTokens.subtitleSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _updateSettings(
                                  _settings.copyWith(
                                    readerMode: ReaderMode.paginated,
                                    readerColumns: ReaderColumns.one,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _settings.readerMode == ReaderMode.paginated &&
                                          _settings.readerColumns != ReaderColumns.two
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: _settings.readerMode == ReaderMode.paginated &&
                                          _settings.readerColumns != ReaderColumns.two
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  'Pages',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: _settings.readerMode == ReaderMode.paginated &&
                                            _settings.readerColumns != ReaderColumns.two
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: _settings.readerMode == ReaderMode.paginated &&
                                            _settings.readerColumns != ReaderColumns.two
                                        ? WarmEditorialTokens.accentInkBlue
                                        : WarmEditorialTokens.subtitleSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _updateSettings(
                                  _settings.copyWith(
                                    readerMode: ReaderMode.paginated,
                                    readerColumns: ReaderColumns.two,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _settings.readerColumns == ReaderColumns.two
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: _settings.readerColumns == ReaderColumns.two
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  'Two Columns',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: _settings.readerColumns == ReaderColumns.two
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: _settings.readerColumns == ReaderColumns.two
                                        ? WarmEditorialTokens.accentInkBlue
                                        : WarmEditorialTokens.subtitleSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Toggles Inset Grouped Card
                    Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: WarmEditorialTokens.hairlineDivider),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile.adaptive(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            activeTrackColor: WarmEditorialTokens.accentInkBlue,
                            title: const Text(
                              'Justify text',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: WarmEditorialTokens.textPrimaryInk,
                              ),
                            ),
                            subtitle: const Text(
                              'Align text flush along both margins',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: WarmEditorialTokens.subtitleSecondary,
                              ),
                            ),
                            value: _settings.readerTextAlignment == ReaderTextAlignment.justify,
                            onChanged: (val) {
                              _updateSettings(
                                _settings.copyWith(
                                  readerTextAlignment: val ? ReaderTextAlignment.justify : ReaderTextAlignment.left,
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16, color: WarmEditorialTokens.hairlineDivider),
                          SwitchListTile.adaptive(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            activeTrackColor: WarmEditorialTokens.accentInkBlue,
                            title: const Text(
                              'Hyphenation',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: WarmEditorialTokens.textPrimaryInk,
                              ),
                            ),
                            subtitle: const Text(
                              'Break words cleanly across lines',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: WarmEditorialTokens.subtitleSecondary,
                              ),
                            ),
                            value: _settings.hyphenation,
                            onChanged: (val) {
                              _updateSettings(_settings.copyWith(hyphenation: val));
                            },
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16, color: WarmEditorialTokens.hairlineDivider),
                          SwitchListTile.adaptive(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            activeTrackColor: WarmEditorialTokens.accentInkBlue,
                            title: const Text(
                              'Publisher styles',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: WarmEditorialTokens.textPrimaryInk,
                              ),
                            ),
                            subtitle: const Text(
                              'Retain original book font overrides',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: WarmEditorialTokens.subtitleSecondary,
                              ),
                            ),
                            value: _settings.publisherStyles,
                            onChanged: (val) {
                              _updateSettings(_settings.copyWith(publisherStyles: val));
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                    const SizedBox(height: 10),

                    // SECTION 5: Display Brightness
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Display Brightness',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: WarmEditorialTokens.textPrimaryInk,
                            ),
                          ),
                        ),
                        Text(
                          '${(_brightness * 100).round()}%',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: WarmEditorialTokens.accentInkBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: WarmEditorialTokens.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: WarmEditorialTokens.hairlineDivider),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.light_mode, size: 18, color: WarmEditorialTokens.subtitleSecondary),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: WarmEditorialTokens.accentInkBlue,
                                    thumbColor: WarmEditorialTokens.accentInkBlue,
                                  ),
                                  child: Slider(
                                    value: _brightness,
                                    min: 0.1,
                                    max: 1.0,
                                    onChanged: _followSystemBrightness
                                        ? null
                                        : (val) => setState(() => _brightness = val),
                                  ),
                                ),
                              ),
                              const Icon(Icons.brightness_high, size: 20, color: WarmEditorialTokens.accentInkBlue),
                            ],
                          ),
                          const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Follow system brightness',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: WarmEditorialTokens.subtitleSecondary,
                                  ),
                                ),
                              ),
                              Switch.adaptive(
                                key: const Key('switch_follow_system_brightness'),
                                value: _followSystemBrightness,
                                activeTrackColor: WarmEditorialTokens.accentInkBlue,
                                onChanged: (val) => setState(() => _followSystemBrightness = val),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
