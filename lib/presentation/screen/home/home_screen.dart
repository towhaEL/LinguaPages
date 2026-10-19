import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_cubit.dart';

import '../../widgets/widgets.dart';
import 'home_portrait_view.dart';

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
    return const HomePortraitView();
  }

  @override
  Widget buildMobileLandscapeView(BuildContext context) {
    // Reuse portrait view — landscape-specific layout is a future enhancement.
    return const HomePortraitView();
  }
}
