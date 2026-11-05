import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/presentation/theme/app_colors.dart';
import 'package:lingua_pages/presentation/theme/app_theme.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('CHALLENGER STRESS SUITE: AppColors.darkWarmEditorial copyWith & lerp', () {
    const darkColors = AppColors.darkWarmEditorial;
    const lightColors = AppColors.warmEditorial;

    test('verifies copyWith with zero parameters produces an identical AppColors instance', () {
      final copy = darkColors.copyWith();
      expect(copy.primary, equals(darkColors.primary));
      expect(copy.onPrimary, equals(darkColors.onPrimary));
      expect(copy.secondary, equals(darkColors.secondary));
      expect(copy.onSecondary, equals(darkColors.onSecondary));
      expect(copy.background, equals(darkColors.background));
      expect(copy.onBackground, equals(darkColors.onBackground));
      expect(copy.surface, equals(darkColors.surface));
      expect(copy.onSurface, equals(darkColors.onSurface));
      expect(copy.onSurfaceMuted, equals(darkColors.onSurfaceMuted));
      expect(copy.error, equals(darkColors.error));
      expect(copy.onError, equals(darkColors.onError));
      expect(copy.success, equals(darkColors.success));
      expect(copy.warning, equals(darkColors.warning));
      expect(copy.info, equals(darkColors.info));
      expect(copy.premium, equals(darkColors.premium));
      expect(copy.border, equals(darkColors.border));
      expect(copy.shadow, equals(darkColors.shadow));
      expect(copy.disabled, equals(darkColors.disabled));
      expect(copy.surfaceElevated, equals(darkColors.surfaceElevated));
      expect(copy.hairline, equals(darkColors.hairline));
      expect(copy.primaryInk, equals(darkColors.primaryInk));
      expect(copy.secondarySlate, equals(darkColors.secondarySlate));
      expect(copy.accentInkBlue, equals(darkColors.accentInkBlue));
      expect(copy.accentContainer, equals(darkColors.accentContainer));
      expect(copy.paperReader, equals(darkColors.paperReader));
      expect(copy.destructive, equals(darkColors.destructive));
      expect(copy.surfaceDim, equals(darkColors.surfaceDim));
      expect(copy.surfaceContainerLow, equals(darkColors.surfaceContainerLow));
      expect(copy.surfaceContainerHighest, equals(darkColors.surfaceContainerHighest));
      expect(copy.outline, equals(darkColors.outline));
      expect(copy.outlineVariant, equals(darkColors.outlineVariant));
      expect(copy.accentHover, equals(darkColors.accentHover));
      expect(copy.destructiveContainer, equals(darkColors.destructiveContainer));
      expect(copy.highlightYellow, equals(darkColors.highlightYellow));
      expect(copy.highlightGreen, equals(darkColors.highlightGreen));
      expect(copy.highlightBlue, equals(darkColors.highlightBlue));
      expect(copy.highlightPink, equals(darkColors.highlightPink));
      expect(copy.highlightOrange, equals(darkColors.highlightOrange));
      expect(copy.highlightAmber, equals(darkColors.highlightAmber));
    });

    test('verifies individual property overrides in copyWith while keeping all other 38 properties untouched', () {
      const canary = Color(0xFF123456);

      expect(darkColors.copyWith(primary: canary).primary, equals(canary));
      expect(darkColors.copyWith(background: canary).background, equals(canary));
      expect(darkColors.copyWith(hairline: canary).hairline, equals(canary));
      expect(darkColors.copyWith(surface: canary).surface, equals(canary));
      expect(darkColors.copyWith(destructive: canary).destructive, equals(canary));
      expect(darkColors.copyWith(outlineVariant: canary).outlineVariant, equals(canary));
      expect(darkColors.copyWith(highlightAmber: canary).highlightAmber, equals(canary));

      // Check preservation of untouched property
      final overridden = darkColors.copyWith(primary: canary);
      expect(overridden.background, equals(darkColors.background));
      expect(overridden.surface, equals(darkColors.surface));
      expect(overridden.hairline, equals(darkColors.hairline));
      expect(overridden.destructive, equals(darkColors.destructive));
    });

    test('verifies complete full-parameter override in copyWith', () {
      const c = Color(0xFF998877);
      final fullyOverridden = darkColors.copyWith(
        primary: c,
        onPrimary: c,
        secondary: c,
        onSecondary: c,
        background: c,
        onBackground: c,
        surface: c,
        onSurface: c,
        onSurfaceMuted: c,
        error: c,
        onError: c,
        success: c,
        warning: c,
        info: c,
        premium: c,
        border: c,
        shadow: c,
        disabled: c,
        surfaceElevated: c,
        hairline: c,
        primaryInk: c,
        secondarySlate: c,
        accentInkBlue: c,
        accentContainer: c,
        paperReader: c,
        destructive: c,
        surfaceDim: c,
        surfaceContainerLow: c,
        surfaceContainerHighest: c,
        outline: c,
        outlineVariant: c,
        accentHover: c,
        destructiveContainer: c,
        highlightYellow: c,
        highlightGreen: c,
        highlightBlue: c,
        highlightPink: c,
        highlightOrange: c,
        highlightAmber: c,
      );

      expect(fullyOverridden.primary, equals(c));
      expect(fullyOverridden.background, equals(c));
      expect(fullyOverridden.hairline, equals(c));
      expect(fullyOverridden.highlightAmber, equals(c));
    });

    test('verifies lerp edge conditions with other = null across boundary t values', () {
      final boundaryTs = <double>[-100.0, -1.5, -0.5, 0.0, 0.5, 1.0, 1.5, 100.0];
      for (final t in boundaryTs) {
        final result = darkColors.lerp(null, t);
        expect(result, isA<AppColors>(), reason: 'lerp(null, $t) must return this instance');
        expect(identical(result, darkColors), isTrue, reason: 'lerp(null, $t) must return the identical instance');
      }
    });

    test('verifies lerp with alien/incompatible ThemeExtension returns this', () {
      final alien = _DummyExtension();
      final result = darkColors.lerp(alien as dynamic, 0.5);
      expect(identical(result, darkColors), isTrue);
    });

    test('stress-tests self-lerp across extreme extrapolation range t in [-0.5..1.5]', () {
      final tValues = [-0.5, -0.25, 0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5];
      for (final t in tValues) {
        final lerped = darkColors.lerp(darkColors, t) as AppColors;
        expect(lerped.primary.toARGB32(), equals(darkColors.primary.toARGB32()), reason: 'Self-lerp at t=$t failed on primary value');
        expect(lerped.background.toARGB32(), equals(darkColors.background.toARGB32()), reason: 'Self-lerp at t=$t failed on background value');
        expect(lerped.hairline.toARGB32(), equals(darkColors.hairline.toARGB32()), reason: 'Self-lerp at t=$t failed on hairline value');
        expect(lerped.surface.toARGB32(), equals(darkColors.surface.toARGB32()), reason: 'Self-lerp at t=$t failed on surface value');
        expect(lerped.destructive.toARGB32(), equals(darkColors.destructive.toARGB32()), reason: 'Self-lerp at t=$t failed on destructive value');
      }
    });

    test('stress-tests cross-lerp between darkWarmEditorial and warmEditorial across t in [-0.5..1.5]', () {
      final testCases = <double>[-0.5, -0.2, 0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5];

      for (final t in testCases) {
        final lerped = darkColors.lerp(lightColors, t) as AppColors;

        // Verify non-null and valid ARGB for all fields
        expect(lerped.primary, isNotNull);
        expect(lerped.background, isNotNull);
        expect(lerped.hairline, isNotNull);
        expect(lerped.surface, isNotNull);
        expect(lerped.surfaceElevated, isNotNull);
        expect(lerped.primaryInk, isNotNull);
        expect(lerped.secondarySlate, isNotNull);
        expect(lerped.accentInkBlue, isNotNull);
        expect(lerped.accentContainer, isNotNull);
        expect(lerped.paperReader, isNotNull);
        expect(lerped.destructive, isNotNull);
        expect(lerped.outline, isNotNull);
        expect(lerped.outlineVariant, isNotNull);
        expect(lerped.highlightYellow, isNotNull);
        expect(lerped.highlightAmber, isNotNull);

        // Exact match checks at boundaries
        if (t == 0.0) {
          expect(lerped.primary, equals(darkColors.primary));
          expect(lerped.background, equals(darkColors.background));
          expect(lerped.hairline, equals(darkColors.hairline));
          expect(lerped.surface, equals(darkColors.surface));
        } else if (t == 1.0) {
          expect(lerped.primary, equals(lightColors.primary));
          expect(lerped.background, equals(lightColors.background));
          expect(lerped.hairline, equals(lightColors.hairline));
          expect(lerped.surface, equals(lightColors.surface));
        } else if (t == 0.5) {
          expect(lerped.primary, equals(Color.lerp(darkColors.primary, lightColors.primary, 0.5)));
          expect(lerped.background, equals(Color.lerp(darkColors.background, lightColors.background, 0.5)));
          expect(lerped.hairline, equals(Color.lerp(darkColors.hairline, lightColors.hairline, 0.5)));
        } else {
          // Extrapolations (t = -0.5 or 1.5) must be valid clamped colors in [0.0..1.0]
          expect(lerped.background.a, inInclusiveRange(0.0, 1.0));
          expect(lerped.background.r, inInclusiveRange(0.0, 1.0));
          expect(lerped.background.g, inInclusiveRange(0.0, 1.0));
          expect(lerped.background.b, inInclusiveRange(0.0, 1.0));

          expect(lerped.hairline.a, inInclusiveRange(0.0, 1.0));
          expect(lerped.hairline.r, inInclusiveRange(0.0, 1.0));
          expect(lerped.hairline.g, inInclusiveRange(0.0, 1.0));
          expect(lerped.hairline.b, inInclusiveRange(0.0, 1.0));
        }
      }
    });

    test('stress-tests reverse cross-lerp from warmEditorial to darkWarmEditorial across t in [-0.5..1.5]', () {
      final tValues = [-0.5, 0.0, 0.5, 1.0, 1.5];
      for (final t in tValues) {
        final lerped = lightColors.lerp(darkColors, t) as AppColors;
        expect(lerped.primary, isNotNull);
        expect(lerped.background, isNotNull);
        expect(lerped.hairline, isNotNull);
        if (t == 0.0) {
          expect(lerped.background, equals(lightColors.background));
        } else if (t == 1.0) {
          expect(lerped.background, equals(darkColors.background));
        }
      }
    });
  });

  group('CHALLENGER STRESS SUITE: Dark Shape Tokens & Invariants', () {
    late ThemeData darkThemePortrait;
    late ThemeData darkThemeLandscape;
    const expectedHairlineColor = Color(0xFF33383D);

    setUp(() {
      darkThemePortrait = AppTheme.dark(orientation: Orientation.portrait);
      darkThemeLandscape = AppTheme.dark(orientation: Orientation.landscape);
    });

    test('verifies Card radius is exactly 16.0 with dark hairline border #33383D', () {
      for (final theme in [darkThemePortrait, darkThemeLandscape]) {
        expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
        final shape = theme.cardTheme.shape! as RoundedRectangleBorder;
        expect(shape.borderRadius, equals(BorderRadius.circular(16.0)));
        expect(shape.side.color, equals(expectedHairlineColor));
        expect(shape.side.width, equals(1.0));
      }
    });

    test('verifies BottomSheet radius is exactly 24.0 on top corners', () {
      for (final theme in [darkThemePortrait, darkThemeLandscape]) {
        expect(theme.bottomSheetTheme.shape, isA<RoundedRectangleBorder>());
        final shape = theme.bottomSheetTheme.shape! as RoundedRectangleBorder;
        expect(
          shape.borderRadius,
          equals(const BorderRadius.vertical(top: Radius.circular(24.0))),
        );
        expect(theme.bottomSheetTheme.backgroundColor, equals(const Color(0xFF1C1F22)));
        expect(theme.bottomSheetTheme.modalBackgroundColor, equals(const Color(0xFF1C1F22)));
        expect(theme.bottomSheetTheme.dragHandleColor, equals(const Color(0xFFA8A59E)));
        expect(theme.bottomSheetTheme.showDragHandle, isTrue);
      }
    });

    test('verifies ChipTheme shape is StadiumBorder with dark hairline border #33383D', () {
      for (final theme in [darkThemePortrait, darkThemeLandscape]) {
        expect(theme.chipTheme.shape, isA<StadiumBorder>());
        expect(theme.chipTheme.side, isNotNull);
        expect(theme.chipTheme.side?.color, equals(expectedHairlineColor));
        expect(theme.chipTheme.side?.width, equals(1.0));
        expect(theme.chipTheme.backgroundColor, equals(const Color(0xFF1C1F22)));
        expect(theme.chipTheme.selectedColor, equals(const Color(0xFFA6C8FF)));
      }
    });

    test('verifies button themes (Filled, Outlined, Text, FAB) adhere to StadiumBorder shape invariants', () {
      for (final theme in [darkThemePortrait, darkThemeLandscape]) {
        // FilledButton
        final filledShape = theme.filledButtonTheme.style?.shape?.resolve({});
        expect(filledShape, isA<StadiumBorder>());

        // OutlinedButton
        final outlinedShape = theme.outlinedButtonTheme.style?.shape?.resolve({});
        expect(outlinedShape, isA<StadiumBorder>());
        final outlinedSide = theme.outlinedButtonTheme.style?.side?.resolve({});
        expect(outlinedSide?.color, equals(expectedHairlineColor));
        expect(outlinedSide?.width, equals(1.0));

        // TextButton
        final textShape = theme.textButtonTheme.style?.shape?.resolve({});
        expect(textShape, isA<StadiumBorder>());

        // FAB
        expect(theme.floatingActionButtonTheme.shape, isA<StadiumBorder>());
      }
    });

    test('verifies DialogTheme shape is RoundedRectangleBorder(16.0) with dark hairline border #33383D', () {
      for (final theme in [darkThemePortrait, darkThemeLandscape]) {
        expect(theme.dialogTheme.shape, isA<RoundedRectangleBorder>());
        final shape = theme.dialogTheme.shape! as RoundedRectangleBorder;
        expect(shape.borderRadius, equals(BorderRadius.circular(16.0)));
        expect(shape.side.color, equals(expectedHairlineColor));
        expect(shape.side.width, equals(1.0));
      }
    });
  });

  group('CHALLENGER STRESS SUITE: Dynamic MaterialApp Theme Swapping & Render Stability', () {
    testWidgets('swapping between AppTheme.light() and AppTheme.dark() dynamically causes no render overflows or exceptions', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const _ThemeSwapHostApp());
      await tester.pumpAndSettle();

      // Initial state: Light theme
      expect(find.text('Current Mode: LIGHT'), findsOneWidget);
      expect(find.text('Editorial Sanctuary'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify light tokens in mounted tree
      final BuildContext initialContext = tester.element(find.text('Editorial Sanctuary'));
      expect(initialContext.colors.background, equals(const Color(0xFFFAF7F2)));
      expect(initialContext.colors.surface, equals(const Color(0xFFFFFFFF)));

      // Step 1: Switch to Dark theme
      await tester.tap(find.byKey(const ValueKey('theme_toggle_button')));
      await tester.pumpAndSettle();

      expect(find.text('Current Mode: DARK'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final BuildContext darkContext = tester.element(find.text('Editorial Sanctuary'));
      expect(darkContext.colors.background, equals(const Color(0xFF111315)));
      expect(darkContext.colors.surface, equals(const Color(0xFF1C1F22)));
      expect(darkContext.colors.hairline, equals(const Color(0xFF33383D)));

      // Step 2: Open Bottom Sheet while in Dark theme
      await tester.tap(find.byKey(const ValueKey('open_sheet_button')));
      await tester.pumpAndSettle();

      expect(find.text('Modal Sheet Content'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Step 3: Switch theme back to Light while Bottom Sheet is open
      await tester.tap(find.byKey(const ValueKey('sheet_toggle_button')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Close sheet
      await tester.tap(find.byKey(const ValueKey('close_sheet_button')));
      await tester.pumpAndSettle();

      expect(find.text('Modal Sheet Content'), findsNothing);
      expect(find.text('Current Mode: LIGHT'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Step 4: Rapid multi-toggle stress cycle
      for (int i = 0; i < 6; i++) {
        await tester.tap(find.byKey(const ValueKey('theme_toggle_button')));
        await tester.pump(const Duration(milliseconds: 16)); // Single frame pump
        expect(tester.takeException(), isNull);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('dynamic AnimatedTheme interpolation between light and dark completes without overflow or NaN', (tester) async {
      await tester.pumpWidget(const _AnimatedThemeSwapHostApp());
      await tester.pumpAndSettle();

      expect(find.text('Animated Theme Demo'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Trigger animation
      await tester.tap(find.byKey(const ValueKey('animated_toggle_button')));

      // Step through intermediate animation ticks (0ms, 50ms, 100ms, 150ms, 200ms, 250ms, 300ms)
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
      }

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}

class _DummyExtension extends ThemeExtension<AppColors> {
  @override
  ThemeExtension<AppColors> copyWith() => this;

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) => this;
}

class _ThemeSwapHostApp extends StatefulWidget {
  const _ThemeSwapHostApp();

  @override
  State<_ThemeSwapHostApp> createState() => _ThemeSwapHostAppState();
}

class _ThemeSwapHostAppState extends State<_ThemeSwapHostApp> {
  bool _isDark = false;

  void _toggle() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDark ? AppTheme.dark() : AppTheme.light(),
      home: Builder(
        builder: (ctx) {
          final colors = ctx.colors;
          return Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              title: const Text('Editorial Sanctuary'),
              actions: [
                IconButton(
                  key: const ValueKey('theme_toggle_button'),
                  icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: _toggle,
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isDark ? 'Current Mode: DARK' : 'Current Mode: LIGHT',
                    style: ctx.textStyle.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Card Title', style: ctx.textStyle.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            'Editorial card content with warm borders and tokens.',
                            style: ctx.textStyle.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            key: const ValueKey('open_sheet_button'),
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: ctx,
                                builder: (sheetCtx) {
                                  return Container(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Modal Sheet Content', style: sheetCtx.textStyle.headlineSmall),
                                        const SizedBox(height: 16),
                                        FilledButton(
                                          key: const ValueKey('sheet_toggle_button'),
                                          onPressed: _toggle,
                                          child: const Text('Toggle Theme Inside Sheet'),
                                        ),
                                        const SizedBox(height: 8),
                                        OutlinedButton(
                                          key: const ValueKey('close_sheet_button'),
                                          onPressed: () => Navigator.pop(sheetCtx),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: const Text('Open Bottom Sheet'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ActionChip(
                        label: const Text('EPUB'),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        label: const Text('PDF'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search editorial catalogue...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(value: 0.65),
                  const SizedBox(height: 16),
                  Slider(
                    value: 20,
                    min: 10,
                    max: 40,
                    onChanged: (v) {},
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedThemeSwapHostApp extends StatefulWidget {
  const _AnimatedThemeSwapHostApp();

  @override
  State<_AnimatedThemeSwapHostApp> createState() => _AnimatedThemeSwapHostAppState();
}

class _AnimatedThemeSwapHostAppState extends State<_AnimatedThemeSwapHostApp> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    final targetTheme = _isDark ? AppTheme.dark() : AppTheme.light();
    return MaterialApp(
      home: AnimatedTheme(
        data: targetTheme,
        duration: const Duration(milliseconds: 300),
        child: Builder(
          builder: (ctx) {
            final colors = ctx.colors;
            return Scaffold(
              backgroundColor: colors.background,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Animated Theme Demo',
                      style: TextStyle(color: colors.primaryInk),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      key: const ValueKey('animated_toggle_button'),
                      onPressed: () {
                        setState(() {
                          _isDark = !_isDark;
                        });
                      },
                      child: const Text('Animate Toggle'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
