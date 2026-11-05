import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_cubit.dart';
import 'package:lingua_pages/presentation/theme/app_theme.dart';
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
    // App-wide so the reader, its sheets and Settings share one entitlement.
    return BlocProvider.value(
      value: injector<PremiumCubit>(),
      child: ScreenUtilInit(
        designSize: Screen.screenSize(context),
        minTextAdapt: true,
        splitScreenMode: true,
        // Built in the builder: text styles read ScreenUtil after it is ready.
        builder: (context, _) {
          final orientation = MediaQuery.of(context).orientation;
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerDelegate: _appRouter.delegate(),
            routeInformationParser: _appRouter.defaultRouteParser(),
            themeMode: ThemeMode.light,
            theme: AppTheme.light(orientation: orientation),
            darkTheme: AppTheme.dark(orientation: orientation),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
