import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingua_pages/l10n/l10n.dart';

class DashboardLandscape extends StatelessWidget {
  final Widget child;

  const DashboardLandscape({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);
    final l10n = context.l10n;
    // Wide tablet landscape has room for the labelled, extended rail.
    final extended = MediaQuery.sizeOf(context).width >= 1200;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: tabsRouter.activeIndex,
            onDestinationSelected: tabsRouter.setActiveIndex,
            groupAlignment: -0.9,
            extended: extended,
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.auto_stories_outlined),
                selectedIcon: const Icon(Icons.auto_stories),
                label: Text(l10n.navHome),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: Text(l10n.navSettings),
              ),
            ],
          ),
          Expanded(child: SafeArea(left: false, child: child)),
        ],
      ),
    );
  }
}
