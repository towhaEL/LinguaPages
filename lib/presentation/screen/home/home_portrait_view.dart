import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lingua_pages/core/constants/app_constant.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/repository/review/review_repository.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/home/components/library_content.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_cubit.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_state.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/theme/text/app_text.dart';

class HomePortraitView extends StatefulWidget {
  const HomePortraitView({super.key});

  @override
  State<HomePortraitView> createState() => _HomePortraitViewState();
}

class _HomePortraitViewState extends State<HomePortraitView>
    with WidgetsBindingObserver {
  late final ReviewRepository _reviewRepository = injector<ReviewRepository>();
  late Future<int> _dueCount = _reviewRepository.dueCount();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshDueCount();
    }
  }

  void _refreshDueCount() {
    final dueCount = _reviewRepository.dueCount();
    if (!mounted) return;
    setState(() {
      _dueCount = dueCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: AppText.titleLarge(
          context.l10n.libraryTitle,
          style: context.textStyle.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primary,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: theme.surface,
        actions: [
          FutureBuilder<int>(
            future: _dueCount,
            builder: (context, snapshot) {
              final dueCount = snapshot.data ?? 0;
              return IconButton(
                onPressed: () => AutoTabsRouter.of(context).setActiveIndex(2),
                tooltip: context.l10n.reviewDueCount(dueCount),
                icon: Badge(
                  isLabelVisible: dueCount > 0,
                  label: Text('$dueCount'),
                  child: const Icon(Icons.replay_rounded),
                ),
              );
            },
          ),
          BlocBuilder<LibraryCubit, LibraryState>(
            buildWhen: (previous, current) =>
                previous.isImporting != current.isImporting,
            builder: (context, state) {
              return IconButton(
                onPressed: state.isImporting
                    ? null
                    : context.read<LibraryCubit>().importDocument,
                icon: state.isImporting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_rounded),
                tooltip: context.l10n.libraryImport,
              );
            },
          ),
          Gap(AppConstant.horizontalGap8),
        ],
      ),
      body: const LibraryContent(),
    );
  }
}
