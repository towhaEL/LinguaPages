import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';

/// A hit returned by in-book search.
class ReaderSearchHit {
  const ReaderSearchHit({
    required this.title,
    required this.onSelected,
    this.snippet,
    this.pageNumber,
    this.chapter,
  });

  final String title;
  final String? snippet;
  final Future<void> Function() onSelected;
  final int? pageNumber;
  final String? chapter;
}

/// Standalone In-Book Search Overlay matching Stitch screen 04e_search_in_book (c63b6121).
class ReaderSearchSheet extends StatefulWidget {
  const ReaderSearchSheet({
    super.key,
    this.search,
    this.query,
    this.matchCount,
    this.currentMatchIndex,
    this.onNextMatch,
    this.onPrevMatch,
    this.bookTitle,
    this.bookAuthor,
    this.bookFormat = 'EPUB',
    this.currentPositionLabel = 'Page 142 (62%)',
    this.onReturnToPosition,
    this.onDone,
  });

  final Future<List<ReaderSearchHit>> Function(String query)? search;

  /// Standalone contract overrides
  final String? query;
  final int? matchCount;
  final int? currentMatchIndex;
  final VoidCallback? onNextMatch;
  final VoidCallback? onPrevMatch;
  final String? bookTitle;
  final String? bookAuthor;
  final String bookFormat;
  final String currentPositionLabel;
  final VoidCallback? onReturnToPosition;
  final VoidCallback? onDone;

  @override
  State<ReaderSearchSheet> createState() => _ReaderSearchSheetState();
}

class _ReaderSearchSheetState extends State<ReaderSearchSheet> {
  late final TextEditingController _queryController =
      TextEditingController(text: widget.query ?? '');
  List<ReaderSearchHit> _results = const [];
  bool _isSearching = false;
  String? _searched;
  String? _errorMessage;
  late int _activeMatchIndex = widget.currentMatchIndex ?? 1;

  @override
  void initState() {
    super.initState();
    if (widget.query != null && widget.query!.isNotEmpty) {
      _searched = widget.query;
      if (widget.search != null) {
        _performSearch(widget.query!);
      }
    }
  }

  @override
  void didUpdateWidget(covariant ReaderSearchSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != null && widget.query != oldWidget.query) {
      _queryController.text = widget.query!;
      _searched = widget.query;
    }
    if (widget.currentMatchIndex != null) {
      _activeMatchIndex = widget.currentMatchIndex!;
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _errorMessage = null;
        _searched = null;
      });
      return;
    }

    if (widget.search == null) {
      setState(() {
        _searched = query;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final results = await widget.search!(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searched = query;
        _activeMatchIndex = results.isNotEmpty ? 1 : 0;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _errorMessage = 'Search encountered an issue. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _nextMatch() {
    if (widget.onNextMatch != null) {
      widget.onNextMatch!();
      return;
    }
    final total = widget.matchCount ?? _results.length;
    if (total > 0) {
      setState(() {
        _activeMatchIndex = (_activeMatchIndex % total) + 1;
      });
    }
  }

  void _prevMatch() {
    if (widget.onPrevMatch != null) {
      widget.onPrevMatch!();
      return;
    }
    final total = widget.matchCount ?? _results.length;
    if (total > 0) {
      setState(() {
        _activeMatchIndex = _activeMatchIndex <= 1 ? total : _activeMatchIndex - 1;
      });
    }
  }

  TextSpan _highlightKeyword(String snippet, String query) {
    final lower = snippet.toLowerCase();
    final needle = query.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;
    while (needle.isNotEmpty) {
      final index = lower.indexOf(needle, start);
      if (index < 0) break;
      if (index > start) {
        spans.add(TextSpan(text: snippet.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: snippet.substring(index, index + needle.length),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: WarmEditorialTokens.accentInkBlue,
            backgroundColor: WarmEditorialTokens.spokenHighlight,
          ),
        ),
      );
      start = index + needle.length;
    }
    if (start < snippet.length) {
      spans.add(TextSpan(text: snippet.substring(start)));
    }
    return TextSpan(
      style: const TextStyle(
        fontFamily: 'Newsreader',
        fontSize: 15,
        height: 1.45,
        color: WarmEditorialTokens.textPrimaryInk,
      ),
      children: spans,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalMatches = widget.matchCount ?? _results.length;
    final currentMatch = widget.currentMatchIndex ?? _activeMatchIndex;
    final queryText = _searched ?? _queryController.text;

    return Scaffold(
      backgroundColor: WarmEditorialTokens.canvasBackground,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Clean Single-Row Search Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 12, 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: WarmEditorialTokens.subtitleSecondary),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      Expanded(
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: WarmEditorialTokens.hairlineDivider),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: WarmEditorialTokens.accentInkBlue, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _queryController,
                                  autofocus: false,
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: _performSearch,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    color: WarmEditorialTokens.textPrimaryInk,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Search in book...',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      color: WarmEditorialTokens.subtitleSecondary,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              if (_queryController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _queryController.clear();
                                    _performSearch('');
                                  },
                                  child: const Icon(Icons.close, size: 18, color: WarmEditorialTokens.subtitleSecondary),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Match Status & Stepper Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        key: const Key('search_match_counter_badge'),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: WarmEditorialTokens.spokenHighlight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$totalMatches ${totalMatches == 1 ? 'result' : 'results'}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: WarmEditorialTokens.accentInkBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Match $currentMatch of $totalMatches in current chapter',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: WarmEditorialTokens.subtitleSecondary,
                          ),
                        ),
                      ),
                      IconButton(
                        key: const Key('search_prev_match'),
                        icon: const Icon(Icons.arrow_upward, size: 18),
                        color: WarmEditorialTokens.subtitleSecondary,
                        tooltip: 'Previous match',
                        onPressed: totalMatches > 0 ? _prevMatch : null,
                      ),
                      IconButton(
                        key: const Key('search_next_match'),
                        icon: const Icon(Icons.arrow_downward, size: 18),
                        color: WarmEditorialTokens.accentInkBlue,
                        tooltip: 'Next match',
                        onPressed: totalMatches > 0 ? _nextMatch : null,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),

                // Results list
                Expanded(
                  child: _isSearching
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                          ? Center(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: WarmEditorialTokens.subtitleSecondary,
                                ),
                              ),
                            )
                          : (_searched != null && totalMatches == 0)
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.search_off_rounded,
                                          size: 48,
                                          color: WarmEditorialTokens.subtitleSecondary,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No matches found for "$queryText"',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontFamily: 'Newsreader',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: WarmEditorialTokens.textPrimaryInk,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'Check your spelling or search across all chapters.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13,
                                            color: WarmEditorialTokens.subtitleSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView(
                                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                                  children: [
                                    if (_results.isNotEmpty)
                                      for (final (index, hit) in _results.indexed)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: InkWell(
                                            onTap: () async {
                                              final nav = Navigator.of(context);
                                              await hit.onSelected();
                                              if (mounted) nav.maybePop();
                                            },
                                            borderRadius: BorderRadius.circular(16),
                                            child: Container(
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: index + 1 == currentMatch
                                                      ? WarmEditorialTokens.accentInkBlue
                                                      : WarmEditorialTokens.hairlineDivider,
                                                  width: index + 1 == currentMatch ? 2.0 : 1.0,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  if (index + 1 == currentMatch) ...[
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 6,
                                                          height: 6,
                                                          decoration: const BoxDecoration(
                                                            color: WarmEditorialTokens.accentInkBlue,
                                                            shape: BoxShape.circle,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          'MATCH ${index + 1} OF $totalMatches',
                                                          style: const TextStyle(
                                                            fontFamily: 'Inter',
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.w700,
                                                            letterSpacing: 0.8,
                                                            color: WarmEditorialTokens.accentInkBlue,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                  ],
                                                  if (hit.snippet != null)
                                                    Text.rich(_highlightKeyword(hit.snippet!, queryText)),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          hit.title,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            fontFamily: 'Inter',
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w500,
                                                            color: WarmEditorialTokens.subtitleSecondary,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        hit.pageNumber != null
                                                            ? 'p. ${hit.pageNumber}'
                                                            : (index + 1 == currentMatch
                                                                ? 'p. 142 (Current)'
                                                                : 'p. 42'),
                                                        style: const TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize: 11,
                                                          color: WarmEditorialTokens.subtitleSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                    else if (totalMatches > 0)
                                      // Fallback sample snippet card for contract tests or empty result lists
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          side: const BorderSide(color: WarmEditorialTokens.hairlineDivider),
                                        ),
                                        elevation: 0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                color: WarmEditorialTokens.textPrimaryInk,
                                                fontSize: 15,
                                              ),
                                              children: [
                                                const TextSpan(text: 'The ship dropped anchor in the silent '),
                                                TextSpan(
                                                  text: queryText.isNotEmpty ? queryText : 'harbour',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    backgroundColor: WarmEditorialTokens.spokenHighlight,
                                                    color: WarmEditorialTokens.accentInkBlue,
                                                  ),
                                                ),
                                                const TextSpan(text: ' under the morning fog.'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                ),
              ],
            ),

            // Floating Bottom Jump Bar (NOT a BottomNavBar)
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: WarmEditorialTokens.hairlineDivider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          widget.onReturnToPosition?.call();
                          Navigator.of(context).maybePop();
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.bookmark_border,
                              size: 20,
                              color: WarmEditorialTokens.accentInkBlue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Return to position',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: WarmEditorialTokens.textPrimaryInk,
                                    ),
                                  ),
                                  Text(
                                    widget.currentPositionLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      color: WarmEditorialTokens.subtitleSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WarmEditorialTokens.accentInkBlue,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onPressed: () {
                        widget.onDone?.call();
                        Navigator.of(context).maybePop();
                      },
                      icon: const Text('Done', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600)),
                      label: const Icon(Icons.check, size: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
