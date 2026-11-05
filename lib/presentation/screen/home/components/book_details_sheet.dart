import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/screen/home/components/library_book_actions.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_cubit.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
import 'package:lingua_pages/presentation/widgets/book/book_cover.dart';
import 'package:share_plus/share_plus.dart';

Future<void> showBookDetailsSheet(BuildContext context, BookEntity book) {
  final cubit = context.read<LibraryCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: BookDetailsSheet(book: book),
    ),
  );
}

class BookDetailsSheet extends StatelessWidget {
  const BookDetailsSheet({
    super.key,
    required this.book,
    this.onRead,
    this.onTrash,
  });

  final BookEntity book;
  final VoidCallback? onRead;
  final VoidCallback? onTrash;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<LibraryCubit>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: WarmEditorialTokens.canvasBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(WarmEditorialTokens.bottomSheetRadius)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with Drag Handle & Close
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: WarmEditorialTokens.hairlineDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: WarmEditorialTokens.subtitleSecondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Scrollable Content
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                // Book Jacket & Editorial Metadata
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Cover 130x195 (2:3)
                    SizedBox(
                      width: 120,
                      height: 180,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(WarmEditorialTokens.cardRadius / 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(WarmEditorialTokens.cardRadius / 2),
                          child: BookCover(book: book),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Details column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (book.series != null && book.series!.isNotEmpty) ...[
                            Text(
                              book.seriesIndex != null
                                  ? '${book.series!.toUpperCase()} · BOOK ${book.seriesIndex!.toInt()}'
                                  : book.series!.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: WarmEditorialTokens.subtitleSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            book.title,
                            key: const Key('book_details_title_text'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.newsreader(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                              color: WarmEditorialTokens.textPrimaryInk,
                            ),
                          ),
                          if (book.author != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              book.author!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.newsreader(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: WarmEditorialTokens.subtitleSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          // Format pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: WarmEditorialTokens.cardSurface,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: WarmEditorialTokens.hairlineDivider),
                            ),
                            child: Text(
                              '${formatCode(book.format)} · Offline',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: WarmEditorialTokens.subtitleSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Progress Card
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: WarmEditorialTokens.cardSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: WarmEditorialTokens.hairlineDivider),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      book.currentChapterTitle ?? 'Reading progress',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: WarmEditorialTokens.textPrimaryInk,
                                      ),
                                    ),
                                    Text(
                                      '${(book.progress * 100).round()}%',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: WarmEditorialTokens.accentInkBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: book.progress.clamp(0.0, 1.0),
                                    minHeight: 4,
                                    backgroundColor: WarmEditorialTokens.hairlineDivider,
                                    valueColor: const AlwaysStoppedAnimation(
                                      WarmEditorialTokens.accentInkBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Action Buttons Row
                Row(
                  children: [
                    // Primary Read Button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          key: const Key('book_details_read_button'),
                          style: FilledButton.styleFrom(
                            backgroundColor: WarmEditorialTokens.accentInkBlue,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          onPressed: onRead ??
                              () {
                                Navigator.of(context).pop();
                                context.router.push(ReaderRoute(book: book));
                              },
                          icon: const Icon(Icons.menu_book, size: 20),
                          label: Text(
                            'Read',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Collect Button
                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: WarmEditorialTokens.cardSurface,
                          foregroundColor: WarmEditorialTokens.textPrimaryInk,
                          side: const BorderSide(color: WarmEditorialTokens.hairlineDivider),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          showBookActions(context, book);
                        },
                        icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                        label: Text(
                          'Collect',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Edit details icon button
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton.outlined(
                        style: IconButton.styleFrom(
                          backgroundColor: WarmEditorialTokens.cardSurface,
                          side: const BorderSide(color: WarmEditorialTokens.hairlineDivider),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          showBookActions(context, book);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Edit details',
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Share icon button
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton.outlined(
                        style: IconButton.styleFrom(
                          backgroundColor: WarmEditorialTokens.cardSurface,
                          side: const BorderSide(color: WarmEditorialTokens.hairlineDivider),
                        ),
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(
                              text: '${book.title} by ${book.author ?? "Unknown"}',
                              subject: book.title,
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_outlined, size: 20),
                        tooltip: 'Share book file',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                const SizedBox(height: 16),
                // Detailed Metadata Grid Card
                Container(
                  decoration: BoxDecoration(
                    color: WarmEditorialTokens.cardSurface,
                    borderRadius: BorderRadius.circular(WarmEditorialTokens.cardRadius),
                    border: Border.all(color: WarmEditorialTokens.hairlineDivider),
                  ),
                  child: Column(
                    children: [
                      _metaRow('Language', book.languageCode ?? 'English (en-US)'),
                      const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                      _metaRow('Encoding', 'UTF-8', isCode: true),
                      const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                      _metaRow('Source', book.sourceFileName, isCode: true),
                      if (book.lastReadAt != null) ...[
                        const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                        _metaRow('Last read', '${book.lastReadAt!.day}/${book.lastReadAt!.month}/${book.lastReadAt!.year}'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Offline Privacy Assurance Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 16,
                      color: WarmEditorialTokens.subtitleSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Archived locally · 100% Offline',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: WarmEditorialTokens.subtitleSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Danger Zone: Move to Trash
                SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    key: const Key('book_details_trash_button'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: WarmEditorialTokens.destructive,
                      side: BorderSide(color: WarmEditorialTokens.destructive.withValues(alpha: 0.4)),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: onTrash ??
                        () async {
                          Navigator.of(context).pop();
                          final moved = await cubit.moveToTrash(book);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                moved
                                    ? l10n.libraryMovedToTrash(book.title)
                                    : l10n.libraryActionFailed,
                              ),
                              action: moved
                                  ? SnackBarAction(
                                      label: l10n.libraryUndo,
                                      onPressed: () => cubit.restoreFromTrash(book),
                                    )
                                  : null,
                            ),
                          );
                        },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text(
                      'Move to Trash',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value, {bool isCode = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: WarmEditorialTokens.subtitleSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: isCode
                  ? GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: WarmEditorialTokens.textPrimaryInk,
                    )
                  : GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: WarmEditorialTokens.textPrimaryInk,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
