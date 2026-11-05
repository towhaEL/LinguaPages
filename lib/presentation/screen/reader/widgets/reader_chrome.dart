import 'package:flutter/material.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
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
  const ReaderTopBar({
    required this.title,
    this.author,
    this.action,
    this.onSearchPressed,
    this.onBookmarkPressed,
    this.isBookmarked = false,
    this.onMenuPressed,
    super.key,
  });

  final String title;
  final String? author;
  final Widget? action;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onBookmarkPressed;
  final bool isBookmarked;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final topBarBg = Theme.of(context).navigationBarTheme.backgroundColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1C1A)
            : const Color(0xFFF6F1E7));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: topBarBg.withValues(alpha: 0.96),
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontFamily: 'Newsreader',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (author != null && author!.isNotEmpty)
                        Text(
                          author!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontFamily: 'Inter',
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (action != null)
                action!
              else ...[
                if (onSearchPressed != null)
                  IconButton(
                    key: const Key('reader_search_button'),
                    icon: const Icon(Icons.search),
                    tooltip: 'Search',
                    onPressed: onSearchPressed,
                  ),
                if (onBookmarkPressed != null)
                  IconButton(
                    key: const Key('reader_bookmark_button'),
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      color: isBookmarked ? WarmEditorialTokens.accentInkBlue : null,
                    ),
                    tooltip: 'Bookmark',
                    onPressed: onBookmarkPressed,
                  ),
                if (onMenuPressed != null)
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: onMenuPressed,
                  ),
              ],
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
    this.chapterTitle,
    this.timeLeftLabel,
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
  final String? chapterTitle;
  final String? timeLeftLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    final showArrows = previousLabel != null || nextLabel != null;
    final bottomBarBg = Theme.of(context).navigationBarTheme.backgroundColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1C1A)
            : const Color(0xFFFAF7F2));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bottomBarBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (chapterTitle != null || timeLeftLabel != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (chapterTitle != null)
                      Expanded(
                        child: Text(
                          chapterTitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Newsreader',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    if (timeLeftLabel != null)
                      Text(
                        timeLeftLabel!,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                  ],
                ),
              ),
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
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: tool.onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF23272A).withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(tool.icon, color: color, size: 22),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      tool.label,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: enabled ? colors.onSurfaceMuted : colors.disabled,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
