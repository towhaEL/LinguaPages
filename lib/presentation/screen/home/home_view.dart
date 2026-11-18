import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/screen/home/components/library_content.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_cubit.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

/// The library screen. [layout] picks the arrangement: phone landscape gets a
/// slim app bar and an icon-only import button so the shelf keeps what little
/// height there is; tablets get a taller, roomier bar.
class HomeView extends StatelessWidget {
  const HomeView({super.key, this.layout = LibraryLayout.phone});

  final LibraryLayout layout;

  @override
  Widget build(BuildContext context) {
    final compact = layout == LibraryLayout.phoneLandscape;
    final tablet = layout == LibraryLayout.tablet;
    return Scaffold(
      backgroundColor: WarmEditorialTokens.canvasBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: compact ? 48 : (tablet ? 72 : kToolbarHeight),
        leading: Padding(
          padding: EdgeInsets.only(left: tablet ? 24 : 16),
          child: Icon(
            Icons.local_library_outlined,
            color: context.accent,
            size: tablet ? 28 : 24,
          ),
        ),
        title: Text(
          context.l10n.libraryTitle,
          style: GoogleFonts.newsreader(
            fontSize: compact ? 20 : (tablet ? 30 : 24),
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: WarmEditorialTokens.textPrimaryInk,
          ),
        ),
        titleSpacing: 12,
        actions: [
          IconButton(
            key: const Key('library_settings_button'),
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined, size: 22),
            color: WarmEditorialTokens.subtitleSecondary,
            onPressed: () => context.router.push(const SettingsRoute()),
          ),
          SizedBox(width: tablet ? 16 : 8),
        ],
      ),
      floatingActionButton: compact
          ? FloatingActionButton(
              key: const Key('library_import_fab'),
              tooltip: 'Import',
              onPressed: () => _import(context),
              backgroundColor: context.accent,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            )
          : FloatingActionButton.extended(
              key: const Key('library_import_fab'),
              onPressed: () => _import(context),
              backgroundColor: context.accent,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                'Import',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
      body: LibraryContent(layout: layout),
    );
  }

  /// Files, or a whole folder where the platform can pick one.
  Future<void> _import(BuildContext context) async {
    final cubit = context.read<LibraryCubit>();
    if (!cubit.canImportFolder) return cubit.importDocument();
    final l10n = context.l10n;
    final folder = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: false,
      backgroundColor: WarmEditorialTokens.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(WarmEditorialTokens.bottomSheetRadius),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: WarmEditorialTokens.hairlineDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(Icons.upload_file_rounded, color: context.accent),
              title: Text(
                l10n.libraryImportFile,
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              onTap: () => Navigator.of(sheetContext).pop(false),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(Icons.folder_open_rounded, color: context.accent),
              title: Text(
                l10n.libraryImportFolder,
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                l10n.libraryImportFolderSubtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: WarmEditorialTokens.subtitleSecondary,
                ),
              ),
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
