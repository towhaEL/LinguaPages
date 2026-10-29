import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/presentation/theme/base/band_colors.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

/// Short format code printed on a cover band.
String formatCode(DocumentFormat format) => switch (format) {
  DocumentFormat.epub => 'EPUB',
  DocumentFormat.pdf => 'PDF',
  DocumentFormat.txt => 'TXT',
  DocumentFormat.markdown => 'MD',
  DocumentFormat.html => 'HTML',
  DocumentFormat.fb2 => 'FB2',
};

/// A 2:3 paperback cover: a format-coloured band top and bottom, with the
/// extracted cover image (or a cream title label) between them.
class BookCover extends StatelessWidget {
  const BookCover({super.key, required this.book, this.compact = false});

  final BookEntity book;

  /// Smaller label type for list rows and dense grids.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bands = context.bands;
    final band = bands.forFormat(book.format);
    final code = formatCode(book.format);

    return Semantics(
      label: '${book.title}, $code',
      image: true,
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(compact ? 3 : 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: ColoredBox(color: band)),
              Expanded(
                flex: 4,
                child: _CoverFace(book: book, compact: compact),
              ),
              Expanded(
                flex: 3,
                child: ColoredBox(
                  color: band,
                  child: Align(
                    alignment: const Alignment(0, .55),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          code,
                          // Cover art keeps its size; the caption scales.
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            color: bands.onBand,
                            fontSize: compact ? 9 : 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverFace extends StatelessWidget {
  const _CoverFace({required this.book, required this.compact});

  final BookEntity book;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final coverPath = book.coverPath;
    final label = _TitleLabel(book: book, compact: compact);
    if (coverPath == null) return label;
    return Image.file(
      File(coverPath),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => label,
    );
  }
}

class _TitleLabel extends StatelessWidget {
  const _TitleLabel({required this.book, required this.compact});

  final BookEntity book;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bands = context.bands;
    return ColoredBox(
      color: bands.label,
      child: LayoutBuilder(
        // A list-row cover is too narrow to set a title without breaking words.
        builder: (context, constraints) =>
            constraints.maxWidth < 72 ? const SizedBox.expand() : _title(bands),
      ),
    );
  }

  Widget _title(BandColors bands) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.title,
            textScaler: TextScaler.noScaling,
            maxLines: compact ? 3 : 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: bands.onLabel,
              fontSize: compact ? 9 : 13,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (!compact && book.author != null) ...[
            const SizedBox(height: 4),
            Text(
              book.author!,
              textScaler: TextScaler.noScaling,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: bands.onLabel,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
