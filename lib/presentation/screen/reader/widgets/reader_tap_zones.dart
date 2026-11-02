import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';

enum ReaderTapAction { previous, next, menu }

/// What a tap at [position] on a page of [size] does under [scheme]: the
/// outer thirds turn the page (left/right or top/bottom), the middle toggles
/// the reader controls.
ReaderTapAction readerTapAction(
  Offset position,
  Size size,
  ReaderTapZones scheme,
) {
  final (along, length) = switch (scheme) {
    ReaderTapZones.sides => (position.dx, size.width),
    ReaderTapZones.topBottom => (position.dy, size.height),
    ReaderTapZones.off => (0.0, 0.0),
  };
  if (length <= 0) return ReaderTapAction.menu;
  if (along < length / 3) return ReaderTapAction.previous;
  if (along > length * 2 / 3) return ReaderTapAction.next;
  return ReaderTapAction.menu;
}

/// Transparent page-turn zones over a fallback page. Long presses still
/// reach the text below for selection; screen readers get Previous and Next
/// as actions whatever the scheme.
class ReaderTapZonesOverlay extends StatelessWidget {
  const ReaderTapZonesOverlay({
    required this.scheme,
    required this.previousLabel,
    required this.nextLabel,
    required this.onPrevious,
    required this.onNext,
    required this.onToggleControls,
    super.key,
  });

  final ReaderTapZones scheme;
  final String previousLabel;
  final String nextLabel;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onToggleControls;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Semantics(
        customSemanticsActions: {
          CustomSemanticsAction(label: previousLabel): ?onPrevious,
          CustomSemanticsAction(label: nextLabel): ?onNext,
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          excludeFromSemantics: true,
          onTapUp: (details) => switch (readerTapAction(
            details.localPosition,
            constraints.biggest,
            scheme,
          )) {
            ReaderTapAction.previous => onPrevious?.call(),
            ReaderTapAction.next => onNext?.call(),
            ReaderTapAction.menu => onToggleControls(),
          },
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
