// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i6;
import 'package:flutter/foundation.dart' as _i8;
import 'package:lingua_pages/domain/entity/library/book_entity.dart' as _i7;
import 'package:lingua_pages/presentation/screen/dashboard/dashboard_screen.dart'
    as _i1;
import 'package:lingua_pages/presentation/screen/home/home_screen.dart' as _i2;
import 'package:lingua_pages/presentation/screen/reader/reader_screen.dart'
    as _i3;
import 'package:lingua_pages/presentation/screen/settings/settings_screen.dart'
    as _i4;
import 'package:lingua_pages/presentation/screen/splash/splash_screen.dart'
    as _i5;

/// generated route for
/// [_i1.DashboardScreen]
class DashboardRoute extends _i6.PageRouteInfo<void> {
  const DashboardRoute({List<_i6.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i1.DashboardScreen();
    },
  );
}

/// generated route for
/// [_i2.HomeScreen]
class HomeRoute extends _i6.PageRouteInfo<void> {
  const HomeRoute({List<_i6.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomeScreen();
    },
  );
}

/// generated route for
/// [_i3.ReaderScreen]
class ReaderRoute extends _i6.PageRouteInfo<ReaderRouteArgs> {
  ReaderRoute({
    required _i7.BookEntity book,
    _i8.Key? key,
    List<_i6.PageRouteInfo>? children,
  }) : super(
         ReaderRoute.name,
         args: ReaderRouteArgs(book: book, key: key),
         initialChildren: children,
       );

  static const String name = 'ReaderRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReaderRouteArgs>();
      return _i3.ReaderScreen(book: args.book, key: args.key);
    },
  );
}

class ReaderRouteArgs {
  const ReaderRouteArgs({required this.book, this.key});

  final _i7.BookEntity book;

  final _i8.Key? key;

  @override
  String toString() {
    return 'ReaderRouteArgs{book: $book, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReaderRouteArgs) return false;
    return book == other.book && key == other.key;
  }

  @override
  int get hashCode => book.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i4.SettingsScreen]
class SettingsRoute extends _i6.PageRouteInfo<void> {
  const SettingsRoute({List<_i6.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i4.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i5.SplashScreen]
class SplashRoute extends _i6.PageRouteInfo<void> {
  const SplashRoute({List<_i6.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i6.PageInfo page = _i6.PageInfo(
    name,
    builder: (data) {
      return const _i5.SplashScreen();
    },
  );
}
