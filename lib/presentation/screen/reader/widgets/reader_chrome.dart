import 'package:flutter/material.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/widgets/book/band_progress_bar.dart';

const _tabular = [FontFeature.tabularFigures()];

/// Heights of the bars below and above the safe area, for pages that pad
/// their scrolling text clear of the chrome.
const readerTopBarHeight = 56.0;
const readerBottomBarHeight = 120.0;
const _slide = Duration(milliseconds: 200);

/// Slides [child] out through [edge] when [visible] is false. Hidden chrome
/// is removed from hit testing and the accessibility tree.
class ReaderChromeSlot extends StatelessWidget {
  const ReaderChromeSlot({
    required this.visible,
    required this.edge,
    required this.child,
    super.key,
  });

  final bool visible;
  final VerticalDirection edge;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : _slide;
    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: AnimatedSlide(
          offset: visible
              ? Offset.zero
              : Offset(0, edge == VerticalDirection.up ? -1 : 1),
          duration: duration,
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: duration,
            curve: Curves.easeOutCubic,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Back, the book title and one quick action, in a nav-ink band.
class ReaderTopBar extends StatelessWidget {
  const ReaderTopBar({required this.title, this.action, super.key});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).navigationBarTheme.backgroundColor!,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: readerTopBarHeight,
          child: Row(
            children: [
              const SizedBox(width: 4),
              const BackButton(),
              const SizedBox(width: 4),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              ?action,
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

/// A labelled tool in the bottom bar.
class ReaderTool {
  const ReaderTool({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
}

/// Where the reader is (band progress bar, percent or page) and the tools.
class ReaderBottomBar extends StatelessWidget {
  const ReaderBottomBar({
    required this.progress,
    required this.bandColor,
    required this.positionLabel,
    required this.tools,
    this.onPrevious,
    this.onNext,
    this.previousLabel,
    this.nextLabel,
    super.key,
  });

  /// 0–1, or null while the position is not known yet.
  final double? progress;
  final Color bandColor;
  final String? positionLabel;
  final List<ReaderTool> tools;

  /// Page-turn buttons for paged books without a native navigator. Both are
  /// shown when either label is given; a null callback disables one.
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String? previousLabel;
  final String? nextLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final showArrows = previousLabel != null || nextLabel != null;

    return ColoredBox(
      color: Theme.of(context).navigationBarTheme.backgroundColor!,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(showArrows ? 4 : 20, 8, 4, 0),
              child: Row(
                children: [
                  if (showArrows)
                    IconButton(
                      onPressed: onPrevious,
                      tooltip: previousLabel,
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                  Expanded(
                    child: BandProgressBar(
                      progress: progress ?? 0,
                      color: bandColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 40),
                    child: Text(
                      positionLabel ?? '',
                      textAlign: TextAlign.end,
                      style: text.labelMedium?.copyWith(
                        color: colors.onSurfaceMuted,
                        fontWeight: FontWeight.w700,
                        fontFeatures: _tabular,
                      ),
                    ),
                  ),
                  if (showArrows)
                    IconButton(
                      onPressed: onNext,
                      tooltip: nextLabel,
                      icon: const Icon(Icons.chevron_right_rounded),
                    )
                  else
                    const SizedBox(width: 16),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  for (final tool in tools)
                    Expanded(child: _ToolButton(tool: tool)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.tool});

  final ReaderTool tool;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = tool.onPressed != null;
    final color = enabled ? colors.onSurface : colors.disabled;
    return Semantics(
      button: true,
      enabled: enabled,
      excludeSemantics: true,
      label: tool.label,
      onTap: tool.onPressed,
      child: InkWell(
        onTap: tool.onPressed,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tool.icon, color: color),
              const SizedBox(height: 4),
              // Five tools on a narrow phone: shrink a long label rather
              // than cut it.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  tool.label,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: enabled ? colors.onSurfaceMuted : colors.disabled,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
