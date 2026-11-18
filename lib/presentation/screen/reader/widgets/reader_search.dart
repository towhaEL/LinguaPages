import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/reader_layout.dart';

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

/// In-book search, shown in a bottom sheet under the theme's drag handle.
/// Choosing a hit runs its [ReaderSearchHit.onSelected] and closes the sheet.
class ReaderSearchSheet extends StatefulWidget {
  const ReaderSearchSheet({
    super.key,
    this.search,
    this.query,
    this.selectedIndex,
    this.onSelected,
    this.returnLabel,
    this.onReturnToPosition,
  });

  final Future<List<ReaderSearchHit>> Function(String query)? search;

  /// Searched for straight away, so reopening search shows the last results.
  final String? query;

  /// The hit chosen last time, marked and scrolled to.
  final int? selectedIndex;

  /// Told which hit was chosen, with the query that found it.
  final void Function(String query, int index)? onSelected;

  /// Where the reader was before the first jump to a hit. The link back is
  /// only shown with [onReturnToPosition].
  final String? returnLabel;
  final VoidCallback? onReturnToPosition;

  @override
  State<ReaderSearchSheet> createState() => _ReaderSearchSheetState();
}

class _ReaderSearchSheetState extends State<ReaderSearchSheet> {
  late final TextEditingController _queryController = TextEditingController(
    text: widget.query ?? '',
  );
  final _scrollController = ScrollController();
  List<ReaderSearchHit> _results = const [];
  bool _isSearching = false;
  String? _searched;
  String? _errorMessage;
  late int? _selectedIndex = widget.selectedIndex;

  /// Drops results of a search that a newer one replaced.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_onQueryEdited);
    final query = widget.query?.trim() ?? '';
    if (query.isNotEmpty) {
      unawaited(_performSearch(query, scrollToSelected: true));
    }
  }

  @override
  void dispose() {
    _queryController
      ..removeListener(_onQueryEdited)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Rebuilds for the clear button.
  void _onQueryEdited() => setState(() {});

  Future<void> _performSearch(
    String rawQuery, {
    bool scrollToSelected = false,
  }) async {
    final query = rawQuery.trim();
    final generation = ++_generation;
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _errorMessage = null;
        _searched = null;
        _isSearching = false;
      });
      return;
    }
    final search = widget.search;
    if (search == null) {
      setState(() => _searched = query);
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      if (query != _searched) _selectedIndex = null;
    });

    try {
      final results = await search(query);
      if (!mounted || generation != _generation) return;
      setState(() {
        _results = results;
        _searched = query;
      });
      final selected = _selectedIndex;
      if (scrollToSelected && selected != null && selected < results.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollController.hasClients) return;
          // Rows are roughly this tall; close enough to bring it into view.
          _scrollController.jumpTo(
            (selected * 104.0).clamp(
              0,
              _scrollController.position.maxScrollExtent,
            ),
          );
        });
      }
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _results = const [];
        _errorMessage = 'Search ran into a problem. Please try again.';
      });
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _select(int index) async {
    final navigator = Navigator.of(context);
    widget.onSelected?.call(_searched ?? '', index);
    await _results[index].onSelected();
    if (mounted) await navigator.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final total = _results.length;

    // Transparent: the sheet paints the surface; this hosts ink and fields.
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: SizedBox(
          // Tall enough for a page of results, and steady while typing.
          // Never taller than what the keyboard leaves, which on a phone
          // held sideways is little.
          height: math.max(
            0,
            math.min(
              readerSheetHeight(context, 0.8) - keyboard * 0.5,
              MediaQuery.sizeOf(context).height - keyboard - 32,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _queryController,
                  autofocus: (widget.query ?? '').isEmpty,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _performSearch,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: WarmEditorialTokens.textPrimaryInk,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search in book',
                    hintStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: WarmEditorialTokens.subtitleSecondary,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: WarmEditorialTokens.subtitleSecondary,
                    ),
                    suffixIcon: _queryController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            color: WarmEditorialTokens.subtitleSecondary,
                            tooltip: 'Clear',
                            onPressed: () {
                              _queryController.clear();
                              unawaited(_performSearch(''));
                            },
                          ),
                    filled: true,
                    fillColor: WarmEditorialTokens.surfaceContainerLow,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: accent, width: 1.5),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 8, 4),
                child: SizedBox(
                  height: 36,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          key: const Key('search_match_counter_badge'),
                          _searched == null
                              ? 'Type a word or phrase, then search'
                              : '$total ${total == 1 ? 'result' : 'results'}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: WarmEditorialTokens.subtitleSecondary,
                          ),
                        ),
                      ),
                      if (widget.onReturnToPosition != null)
                        TextButton.icon(
                          key: const Key('search_return_to_position'),
                          style: TextButton.styleFrom(
                            foregroundColor: accent,
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () {
                            widget.onReturnToPosition!();
                            Navigator.of(context).maybePop();
                          },
                          icon: const Icon(Icons.undo_rounded, size: 16),
                          label: Text(
                            widget.returnLabel == null
                                ? 'Back to where you were'
                                : 'Back to ${widget.returnLabel}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(
                height: 1,
                color: WarmEditorialTokens.hairlineDivider,
              ),
              Expanded(child: _buildBody(accent)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(Color accent) {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage case final message?) {
      return _Message(icon: Icons.error_outline_rounded, title: message);
    }
    final searched = _searched;
    if (searched == null) {
      return const _Message(
        icon: Icons.manage_search_rounded,
        title: 'Search the whole book',
        body:
            'Matches show with the text around them. '
            'Tap one to jump to it.',
      );
    }
    if (_results.isEmpty) {
      return _Message(
        icon: Icons.search_off_rounded,
        title: 'No matches for "$searched"',
        body: 'Check the spelling, or try a shorter word.',
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _results.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: WarmEditorialTokens.hairlineDivider,
      ),
      itemBuilder: (context, index) {
        final hit = _results[index];
        final selected = index == _selectedIndex;
        return InkWell(
          onTap: () => _select(index),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: selected ? accent : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(17, 12, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hit.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: selected
                              ? accent
                              : WarmEditorialTokens.subtitleSecondary,
                        ),
                      ),
                    ),
                    if (hit.pageNumber case final page?)
                      Text(
                        'p. $page',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: WarmEditorialTokens.subtitleSecondary,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                  ],
                ),
                if (hit.snippet case final snippet?) ...[
                  const SizedBox(height: 4),
                  Text.rich(
                    highlightMatches(snippet, searched, accent: accent),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// [snippet] with every case-insensitive occurrence of [query] marked.
@visibleForTesting
TextSpan highlightMatches(
  String snippet,
  String query, {
  required Color accent,
}) {
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
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: WarmEditorialTokens.textPrimaryInk,
          backgroundColor: accent.withValues(alpha: 0.18),
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
      height: 1.4,
      color: WarmEditorialTokens.textPrimaryInk,
    ),
    children: spans,
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, this.body});

  final IconData icon;
  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
      child: Column(
        children: [
          Icon(icon, size: 40, color: WarmEditorialTokens.subtitleSecondary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Newsreader',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: WarmEditorialTokens.textPrimaryInk,
            ),
          ),
          if (body case final body?) ...[
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: WarmEditorialTokens.subtitleSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
