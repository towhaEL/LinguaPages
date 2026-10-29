import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.dart';
import 'package:lingua_pages/presentation/theme/dark/en_dark_mode.dart';
import '../widgets/widgets.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Screen.screenSize(context),
      minTextAdapt: true,
      splitScreenMode: true,
      // Built in the builder: text styles read ScreenUtil after it is ready.
      builder: (context, _) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerDelegate: _appRouter.delegate(),
        routeInformationParser: _appRouter.defaultRouteParser(),
        // The app chrome is dark-only; reading pages keep their own themes.
        themeMode: ThemeMode.dark,
        darkTheme: EnDarkMode().getAppTheme(
          orientation: MediaQuery.of(context).orientation,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
