// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i10;
import 'package:flutter/foundation.dart' as _i14;
import 'package:flutter/material.dart' as _i11;
import 'package:lingua_pages/core/document/document_locator.dart' as _i13;
import 'package:lingua_pages/domain/entity/library/book_entity.dart' as _i12;
import 'package:lingua_pages/presentation/screen/annotations/annotations_screen.dart'
    as _i1;
import 'package:lingua_pages/presentation/screen/dashboard/dashboard_screen.dart'
    as _i2;
import 'package:lingua_pages/presentation/screen/home/home_screen.dart' as _i3;
import 'package:lingua_pages/presentation/screen/onboarding/onboarding_screen.dart'
    as _i4;
import 'package:lingua_pages/presentation/screen/privacy/privacy_screen.dart'
    as _i5;
import 'package:lingua_pages/presentation/screen/reader/reader_screen.dart'
    as _i6;
import 'package:lingua_pages/presentation/screen/saved_words/saved_words_screen.dart'
    as _i7;
import 'package:lingua_pages/presentation/screen/settings/settings_screen.dart'
    as _i8;
import 'package:lingua_pages/presentation/screen/splash/splash_screen.dart'
    as _i9;

/// generated route for
/// [_i1.AnnotationsScreen]
class AnnotationsRoute extends _i10.PageRouteInfo<void> {
  const AnnotationsRoute({List<_i10.PageRouteInfo>? children})
    : super(AnnotationsRoute.name, initialChildren: children);

  static const String name = 'AnnotationsRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i1.AnnotationsScreen();
    },
  );
}

/// generated route for
/// [_i2.DashboardScreen]
class DashboardRoute extends _i10.PageRouteInfo<void> {
  const DashboardRoute({List<_i10.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i2.DashboardScreen();
    },
  );
}

/// generated route for
/// [_i3.HomeScreen]
class HomeRoute extends _i10.PageRouteInfo<void> {
  const HomeRoute({List<_i10.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomeScreen();
    },
  );
}

/// generated route for
/// [_i4.OnboardingScreen]
class OnboardingRoute extends _i10.PageRouteInfo<OnboardingRouteArgs> {
  OnboardingRoute({
    _i11.Key? key,
    _i11.VoidCallback? onImportFirstBook,
    _i11.VoidCallback? onExploreFirst,
    List<_i10.PageRouteInfo>? children,
  }) : super(
         OnboardingRoute.name,
         args: OnboardingRouteArgs(
           key: key,
           onImportFirstBook: onImportFirstBook,
           onExploreFirst: onExploreFirst,
         ),
         initialChildren: children,
       );

  static const String name = 'OnboardingRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OnboardingRouteArgs>(
        orElse: () => const OnboardingRouteArgs(),
      );
      return _i4.OnboardingScreen(
        key: args.key,
        onImportFirstBook: args.onImportFirstBook,
        onExploreFirst: args.onExploreFirst,
      );
    },
  );
}

class OnboardingRouteArgs {
  const OnboardingRouteArgs({
    this.key,
    this.onImportFirstBook,
    this.onExploreFirst,
  });

  final _i11.Key? key;

  final _i11.VoidCallback? onImportFirstBook;

  final _i11.VoidCallback? onExploreFirst;

  @override
  String toString() {
    return 'OnboardingRouteArgs{key: $key, onImportFirstBook: $onImportFirstBook, onExploreFirst: $onExploreFirst}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OnboardingRouteArgs) return false;
    return key == other.key &&
        onImportFirstBook == other.onImportFirstBook &&
        onExploreFirst == other.onExploreFirst;
  }

  @override
  int get hashCode =>
      key.hashCode ^ onImportFirstBook.hashCode ^ onExploreFirst.hashCode;
}

/// generated route for
/// [_i5.PrivacyScreen]
class PrivacyRoute extends _i10.PageRouteInfo<void> {
  const PrivacyRoute({List<_i10.PageRouteInfo>? children})
    : super(PrivacyRoute.name, initialChildren: children);

  static const String name = 'PrivacyRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i5.PrivacyScreen();
    },
  );
}

/// generated route for
/// [_i6.ReaderScreen]
class ReaderRoute extends _i10.PageRouteInfo<ReaderRouteArgs> {
  ReaderRoute({
    required _i12.BookEntity book,
    _i13.DocumentLocator? openAt,
    _i14.Key? key,
    List<_i10.PageRouteInfo>? children,
  }) : super(
         ReaderRoute.name,
         args: ReaderRouteArgs(book: book, openAt: openAt, key: key),
         initialChildren: children,
       );

  static const String name = 'ReaderRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReaderRouteArgs>();
      return _i6.ReaderScreen(
        book: args.book,
        openAt: args.openAt,
        key: args.key,
      );
    },
  );
}

class ReaderRouteArgs {
  const ReaderRouteArgs({required this.book, this.openAt, this.key});

  final _i12.BookEntity book;

  final _i13.DocumentLocator? openAt;

  final _i14.Key? key;

  @override
  String toString() {
    return 'ReaderRouteArgs{book: $book, openAt: $openAt, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReaderRouteArgs) return false;
    return book == other.book && openAt == other.openAt && key == other.key;
  }

  @override
  int get hashCode => book.hashCode ^ openAt.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i7.SavedWordsScreen]
class SavedWordsRoute extends _i10.PageRouteInfo<void> {
  const SavedWordsRoute({List<_i10.PageRouteInfo>? children})
    : super(SavedWordsRoute.name, initialChildren: children);

  static const String name = 'SavedWordsRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i7.SavedWordsScreen();
    },
  );
}

/// generated route for
/// [_i8.SettingsScreen]
class SettingsRoute extends _i10.PageRouteInfo<void> {
  const SettingsRoute({List<_i10.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i8.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i9.SplashScreen]
class SplashRoute extends _i10.PageRouteInfo<void> {
  const SplashRoute({List<_i10.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i10.PageInfo page = _i10.PageInfo(
    name,
    builder: (data) {
      return const _i9.SplashScreen();
    },
  );
}
