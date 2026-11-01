import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lingua_pages/presentation/app/app.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_cubit.dart';

import '../injector/injector.dart';

const _bundledFonts = [
  ('Figtree', 'figtree'),
  ('Literata', 'literata'),
  ('Source Serif 4', 'source_serif_4'),
  ('EB Garamond', 'eb_garamond'),
];

abstract class Env {
  static late Env shared;
  abstract String name;
  abstract String baseUrl;
  bool initialized = false;

  Env() {
    shared = this;
    bootstrap(() => const App());
  }

  Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      log(details.exceptionAsString(), stackTrace: details.stack);
    };
    LicenseRegistry.addLicense(() async* {
      for (final (package, directory) in _bundledFonts) {
        final license = await rootBundle.loadString(
          'assets/fonts/$directory/OFL.txt',
        );
        yield LicenseEntryWithLineBreaks([package], license);
      }
    });
    await configureDependencies(name);
    unawaited(injector<PremiumCubit>().start());

    Bloc.observer = const AppBlocObserver();

    runApp(await builder());
  }
}

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}
