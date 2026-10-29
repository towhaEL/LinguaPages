import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/home/components/library_content.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_cubit.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_state.dart';

class HomePortraitView extends StatelessWidget {
  const HomePortraitView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.libraryTitle),
        titleSpacing: 20,
        toolbarHeight: 64,
        actions: [
          BlocBuilder<LibraryCubit, LibraryState>(
            buildWhen: (previous, current) =>
                previous.isImporting != current.isImporting,
            builder: (context, state) {
              return IconButton.filledTonal(
                onPressed: state.isImporting
                    ? null
                    : context.read<LibraryCubit>().importDocument,
                icon: state.isImporting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_rounded),
                tooltip: context.l10n.libraryImport,
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: const LibraryContent(),
    );
  }
}
