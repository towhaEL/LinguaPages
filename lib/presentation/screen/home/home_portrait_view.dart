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
                onPressed: state.isImporting ? null : () => _import(context),
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

  /// Files, or a whole folder where the platform can pick one.
  Future<void> _import(BuildContext context) async {
    final cubit = context.read<LibraryCubit>();
    if (!cubit.canImportFolder) return cubit.importDocument();
    final l10n = context.l10n;
    final folder = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.libraryImportFile),
              onTap: () => Navigator.of(sheetContext).pop(false),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Icons.folder_open_outlined),
              title: Text(l10n.libraryImportFolder),
              subtitle: Text(l10n.libraryImportFolderSubtitle),
              onTap: () => Navigator.of(sheetContext).pop(true),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (folder == null) return;
    await (folder ? cubit.importFolder() : cubit.importDocument());
  }
}
