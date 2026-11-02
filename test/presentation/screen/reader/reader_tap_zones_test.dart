import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/reader_tap_zones.dart';

void main() {
  const page = Size(300, 600);

  ReaderTapAction tap(double x, double y, ReaderTapZones scheme) =>
      readerTapAction(Offset(x, y), page, scheme);

  test('left and right thirds turn pages with the sides scheme', () {
    expect(tap(10, 300, ReaderTapZones.sides), ReaderTapAction.previous);
    expect(tap(150, 300, ReaderTapZones.sides), ReaderTapAction.menu);
    expect(tap(290, 300, ReaderTapZones.sides), ReaderTapAction.next);
    // Height does not matter for sides.
    expect(tap(290, 5, ReaderTapZones.sides), ReaderTapAction.next);
  });

  test('top and bottom thirds turn pages with the top/bottom scheme', () {
    expect(tap(150, 50, ReaderTapZones.topBottom), ReaderTapAction.previous);
    expect(tap(150, 300, ReaderTapZones.topBottom), ReaderTapAction.menu);
    expect(tap(150, 590, ReaderTapZones.topBottom), ReaderTapAction.next);
    expect(tap(10, 300, ReaderTapZones.topBottom), ReaderTapAction.menu);
  });

  test('taps only toggle the controls when turning is off', () {
    for (final x in [5.0, 150.0, 295.0]) {
      expect(tap(x, 300, ReaderTapZones.off), ReaderTapAction.menu);
    }
  });
}
