import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lingua_pages/core/constants/app_constant.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'navigation_rail_item.dart';

class CustomNavigationRail extends StatefulWidget {
  const CustomNavigationRail({
    super.key,
    required this.onTap,
    required this.currentIndex,
  });

  final void Function(int index) onTap;
  final int currentIndex;

  @override
  State<CustomNavigationRail> createState() => _CustomNavigationRailState();
}

class _CustomNavigationRailState extends State<CustomNavigationRail> {
  final AutoSizeGroup group = AutoSizeGroup();

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(right: BorderSide(color: theme.border.withAlpha(128))),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Gap(AppConstant.verticalGap20),
            // App icon
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(AppConstant.borderRadius12),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Colors.white,
              ),
            ),
            Gap(AppConstant.verticalGap20 * 2),
            Expanded(
              child: Column(
                children: [
                  NavigationRailItem(
                    title: context.l10n.navHome,
                    group: group,
                    onTap: () => widget.onTap(0),
                    isSelected: widget.currentIndex == 0,
                    icon: Icons.menu_book_rounded,
                  ),
                  Gap(AppConstant.verticalGap12),
                  NavigationRailItem(
                    title: context.l10n.navVocabulary,
                    group: group,
                    onTap: () => widget.onTap(1),
                    isSelected: widget.currentIndex == 1,
                    icon: Icons.style_rounded,
                  ),
                  Gap(AppConstant.verticalGap12),
                  NavigationRailItem(
                    title: context.l10n.navReview,
                    group: group,
                    onTap: () => widget.onTap(2),
                    isSelected: widget.currentIndex == 2,
                    icon: Icons.replay_rounded,
                  ),
                  Gap(AppConstant.verticalGap12),
                  NavigationRailItem(
                    title: context.l10n.navSettings,
                    group: group,
                    onTap: () => widget.onTap(3),
                    isSelected: widget.currentIndex == 3,
                    icon: Icons.settings_rounded,
                  ),
                ],
              ),
            ),
            Gap(AppConstant.verticalGap20),
          ],
        ),
      ),
    );
  }
}
