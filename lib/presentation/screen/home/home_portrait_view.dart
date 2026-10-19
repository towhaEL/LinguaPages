import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lingua_pages/core/constants/app_constant.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/home/components/library_content.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_cubit.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_state.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/theme/text/app_text.dart';

class HomePortraitView extends StatelessWidget {
  const HomePortraitView({super.key});

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
