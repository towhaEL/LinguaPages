import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.dart';
import 'package:lingua_pages/presentation/theme/base/theme_entity.dart';
import 'package:lingua_pages/presentation/theme/cubit/app_theme_cubit.dart';
import 'package:lingua_pages/presentation/theme/cubit/app_theme_state.dart';
import 'package:lingua_pages/presentation/theme/dark/en_dark_mode.dart';
import 'package:lingua_pages/presentation/theme/light/en_light_mode.dart';
import 'package:lingua_pages/presentation/theme/system/system_mode.dart';
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
    final availableThemes = [
      ThemeEntity(SystemMode(), 'System'),
      ThemeEntity(EnLightMode(), 'Light Mode'),
      ThemeEntity(EnDarkMode(), 'Dark Mode'),
    ];
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) => AppThemeCubit(themeEntities: availableThemes),
        ),
      ],
      child: ScreenUtilInit(
        designSize: Screen.screenSize(context),
        minTextAdapt: true,
        splitScreenMode: true,
        child: BlocBuilder<AppThemeCubit, AppThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerDelegate: _appRouter.delegate(),
              routeInformationParser: _appRouter.defaultRouteParser(),
              theme: themeState.currentTheme.theme.getAppTheme(
                orientation: MediaQuery.of(context).orientation,
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        ),
      ),
    );
  }
}
