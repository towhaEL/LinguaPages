import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/appearance_sheet.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/reader_chrome.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/reader_layout.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/reader_search.dart';
import 'package:lingua_pages/presentation/theme/app_theme.dart';

const _phone = Size(402, 874);
const _phoneLandscape = Size(874, 402);
const _tablet = Size(800, 1280);
const _tabletLandscape = Size(1280, 800);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  void setSize(WidgetTester tester, Size size) {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Widget app(Widget home) => MaterialApp(theme: AppTheme.light(), home: home);

  final tools = [
    for (final (icon, label) in [
      (Icons.list_rounded, 'Contents'),
      (Icons.search_rounded, 'Search'),
      (Icons.text_fields_rounded, 'Appearance'),
      (Icons.edit_note_rounded, 'Notes'),
      (Icons.headphones_rounded, 'Listen'),
    ])
      ReaderTool(icon: icon, label: label, onPressed: () {}),
  ];

  Widget bottomBar() => ReaderBottomBar(
    key: const Key('bar'),
    progress: 0.4,
    bandColor: Colors.teal,
    positionLabel: '40%',
    tools: tools,
    previousLabel: 'Previous page',
    nextLabel: 'Next page',
    onPrevious: () {},
    onNext: () {},
    chapterTitle: 'Chapter 3: The long way round',
    timeLeftLabel: '12 min left',
  );

  group('bottom bar', () {
    Future<double> barHeight(WidgetTester tester, Size size) async {
      setSize(tester, size);
      await tester.pumpWidget(
        app(
          Scaffold(
            body: Align(alignment: Alignment.bottomCenter, child: bottomBar()),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      return tester.getSize(find.byKey(const Key('bar'))).height;
    }

    testWidgets('phone landscape is much shorter than portrait', (
      tester,
    ) async {
      final portrait = await barHeight(tester, _phone);
      final landscape = await barHeight(tester, _phoneLandscape);
      // Handle, chapter line and tool labels go: about 70dp of a 402dp page.
      expect(portrait - landscape, greaterThanOrEqualTo(60));
    });

    testWidgets('tablet landscape keeps the full bar', (tester) async {
      final tablet = await barHeight(tester, _tabletLandscape);
      final portrait = await barHeight(tester, _phone);
      expect(tablet, portrait);
    });

    testWidgets('phone landscape shows tools as icons only', (tester) async {
      setSize(tester, _phoneLandscape);
      await tester.pumpWidget(
        app(
          Scaffold(
            body: Align(alignment: Alignment.bottomCenter, child: bottomBar()),
          ),
        ),
      );

      expect(find.text('Contents'), findsNothing);
      expect(find.byTooltip('Contents'), findsOneWidget);
      expect(find.bySemanticsLabel('Contents'), findsOneWidget);
    });

    testWidgets('tablet keeps the controls within reach', (tester) async {
      setSize(tester, _tabletLandscape);
      await tester.pumpWidget(
        app(
          Scaffold(
            body: Align(alignment: Alignment.bottomCenter, child: bottomBar()),
          ),
        ),
      );

      expect(find.text('Contents'), findsOneWidget);
      final first = tester.getRect(find.byIcon(Icons.list_rounded));
      final last = tester.getRect(find.byIcon(Icons.headphones_rounded));
      expect(
        last.right - first.left,
        lessThanOrEqualTo(readerControlsMaxWidth),
      );
    });
  });

  group('appearance sheet', () {
    Future<void> open(WidgetTester tester, Size size) async {
      setSize(tester, size);
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AppearanceSheet(selectedTheme: 'Paper'),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    for (final (name, size) in [
      ('phone portrait', _phone),
      ('phone landscape', _phoneLandscape),
      ('tablet portrait', _tablet),
      ('tablet landscape', _tabletLandscape),
    ]) {
      testWidgets('$name lays out without overflow', (tester) async {
        await open(tester, size);
        expect(tester.takeException(), isNull);
        expect(find.text('Appearance'), findsOneWidget);
      });
    }

    testWidgets('landscape puts page tone beside the type settings', (
      tester,
    ) async {
      await open(tester, _phoneLandscape);

      final swatch = tester.getRect(find.byKey(const Key('swatch_Paper')));
      final typeface = tester.getRect(find.text('Typeface'));
      expect(swatch.right, lessThanOrEqualTo(typeface.left));
      // No drag handle or subtitle on a phone held sideways.
      expect(find.text('Offline reading aesthetics'), findsNothing);
    });

    testWidgets('portrait keeps one column with the subtitle', (tester) async {
      await open(tester, _phone);

      final swatch = tester.getRect(find.byKey(const Key('swatch_Paper')));
      final typeface = tester.getRect(find.text('Typeface'));
      expect(swatch.bottom, lessThanOrEqualTo(typeface.top));
      expect(find.text('Offline reading aesthetics'), findsOneWidget);
    });
  });

  testWidgets('search fits beside a keyboard on a landscape phone', (
    tester,
  ) async {
    setSize(tester, _phoneLandscape);
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      app(Scaffold(body: ReaderSearchSheet(search: (_) async => const []))),
    );

    expect(tester.takeException(), isNull);
  });
}
