import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/presentation/screen/home/components/library_content.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_cubit.dart';

import '../../widgets/widgets.dart';
import 'home_view.dart';

@RoutePage()
class HomeScreen extends Screen {
  const HomeScreen({super.key});

  @override
  Widget buildViewWrapper({required Widget child}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => injector<LibraryCubit>()..load()),
      ],
      child: child,
    );
  }

  @override
  Widget buildMobilePortraitView(BuildContext context) {
    return const HomeView();
  }

  @override
  Widget buildMobileLandscapeView(BuildContext context) {
    return const HomeView(layout: LibraryLayout.phoneLandscape);
  }

  /// Both orientations; the library itself splits into side pane and shelf
  /// once there is room for both.
  @override
  Widget buildTabletView(BuildContext context) {
    return const HomeView(layout: LibraryLayout.tablet);
  }
}
