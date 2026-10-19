import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:lingua_pages/presentation/app/app.dart';
import 'package:lingua_pages/domain/service/review_notification_scheduler.dart';

import '../injector/injector.dart';

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
    await configureDependencies(name);

    try {
      final reviewNotifications = injector<ReviewNotificationScheduler>();
      await reviewNotifications.initialize();
      await reviewNotifications.sync();
    } on Object catch (error, stackTrace) {
      log('Review notification setup failed: $error', stackTrace: stackTrace);
    }

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
