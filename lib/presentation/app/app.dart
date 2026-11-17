import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/entity/premium/appearance_catalog.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/app/cubit/app_preferences_cubit.dart';
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
  final _preferences = injector<AppPreferencesCubit>()..load();

  @override
  Widget build(BuildContext context) {
    // App-wide so the reader, its sheets and Settings share one entitlement
    // and one look.
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: injector<PremiumCubit>()),
        BlocProvider.value(value: _preferences),
      ],
      child: ScreenUtilInit(
        designSize: Screen.screenSize(context),
        minTextAdapt: true,
        splitScreenMode: true,
        // Built in the builder: text styles read ScreenUtil after it is ready.
        builder: (context, _) {
          final orientation = MediaQuery.of(context).orientation;
          final unlocked = context.select(
            (PremiumCubit cubit) => cubit.state.unlocked,
          );
          final preferences = context.watch<AppPreferencesCubit>().state;
          final accent = AppearanceCatalog.effectiveAccent(
            preferences.accent,
            premium: unlocked,
          );
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerDelegate: _appRouter.delegate(),
            routeInformationParser: _appRouter.defaultRouteParser(),
            themeMode: ThemeMode.light,
            theme: AppTheme.light(orientation: orientation, accent: accent),
            darkTheme: AppTheme.dark(orientation: orientation),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // The interface scale multiplies the system text size, so both
            // the accessibility setting and the app's choice apply.
            builder: (context, child) {
              final media = MediaQuery.of(context);
              final scale = preferences.interfaceScale;
              if (scale == 1) return child!;
              return MediaQuery(
                data: media.copyWith(
                  textScaler: _ScaledTextScaler(media.textScaler, scale),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

/// [base] (the system's scaler, which may be non-linear) times [factor].
class _ScaledTextScaler extends TextScaler {
  const _ScaledTextScaler(this.base, this.factor);

  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  @override
  double get textScaleFactor => base.scale(14) / 14 * factor;

  @override
  bool operator ==(Object other) =>
      other is _ScaledTextScaler && other.base == base && other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
