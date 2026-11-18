part of "widgets.dart";

abstract class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return buildViewWrapper(child: _buildView(context));
  }

  static bool isMobilePortrait(BuildContext context) {
    final media = MediaQuery.of(context);
    final orientation = media.orientation;
    final shortestSide = media.size.shortestSide;

    return shortestSide < 600 && orientation == Orientation.portrait;
  }

  static bool isMobileLandscape(BuildContext context) {
    final media = MediaQuery.of(context);
    final orientation = media.orientation;
    final shortestSide = media.size.shortestSide;

    return shortestSide < 600 && orientation == Orientation.landscape;
  }

  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600;
  }

  static bool isSplitScreen(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final aspectRatio = size.width / size.height;

    // Split-screen detection
    return (aspectRatio > 0.8 && aspectRatio < 1.2) ||
        (media.orientation == Orientation.landscape && aspectRatio < 1.5);
  }

  static Size screenSize(BuildContext context) {
    // Checked before split screen: a landscape tablet's aspect ratio (~1.33)
    // would otherwise read as split screen and get the phone design size.
    if (isTablet(context)) {
      return MediaQuery.of(context).orientation == Orientation.landscape
          ? const Size(1024, 768)
          : const Size(768, 1024);
    }
    if (isSplitScreen(context)) {
      final media = MediaQuery.of(context);
      if (media.orientation == Orientation.landscape) {
        return const Size(874, 402);
      } else {
        return const Size(402, 874);
      }
    }
    if (isMobileLandscape(context)) {
      return const Size(874, 402);
    }
    if (isMobilePortrait(context)) {
      return const Size(402, 874);
    }
    return const Size(402, 874);
  }

  Widget _buildView(BuildContext context) {
    return ScreenUtilInit(
      designSize: screenSize(context),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return child!;
      },
      child: _getProperWidget(context),
    );
  }

  Widget _getProperWidget(BuildContext context) {
    // Tablet first, for the same reason as in [screenSize]. Tablet views lay
    // out against the available width, so they also cope with a tablet in
    // split screen.
    if (isTablet(context)) {
      Widget? child = buildTabletView(context);
      return child ?? buildMobilePortraitView(context);
    }

    if (isSplitScreen(context)) {
      return buildMobilePortraitView(context);
    }

    if (isMobilePortrait(context)) {
      return buildMobilePortraitView(context);
    }

    if (isMobileLandscape(context)) {
      Widget? child = buildMobileLandscapeView(context);
      return child ?? buildMobilePortraitView(context);
    }

    return buildMobilePortraitView(context);
  }

  Widget buildViewWrapper({required Widget child}) => child;

  Widget buildMobilePortraitView(BuildContext context);

  Widget? buildMobileLandscapeView(BuildContext context) => null;

  /// Used for tablets in both orientations; branch on
  /// [isTabletLandscape] or the available width inside.
  Widget? buildTabletView(BuildContext context) => null;

  static bool isTabletLandscape(BuildContext context) =>
      isTablet(context) &&
      MediaQuery.of(context).orientation == Orientation.landscape;
}
