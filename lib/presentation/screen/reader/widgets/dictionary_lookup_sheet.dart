import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/entity/dictionary/dictionary_entry.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/presentation/screen/reader/cubit/dictionary_lookup_cubit.dart';
import 'package:lingua_pages/presentation/screen/reader/cubit/dictionary_lookup_state.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
import 'package:url_launcher/url_launcher.dart';

/// Floating text selection toolbar matching Stitch screen 04c_text_selection_dictionary (3377a7d8).
class FloatingSelectionToolbar extends StatelessWidget {
  const FloatingSelectionToolbar({
    super.key,
    this.onColorSelected,
    this.onDefinePressed,
    this.onCopyPressed,
    this.onNotePressed,
    this.onSharePressed,
    this.onMorePressed,
  });

  final ValueChanged<HighlightColor>? onColorSelected;
  final VoidCallback? onDefinePressed;
  final VoidCallback? onCopyPressed;
  final VoidCallback? onNotePressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('floating_selection_toolbar'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: WarmEditorialTokens.textPrimaryInk,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 5 color dots (Yellow, Green, Blue, Pink, Orange)
          for (final (color, highlightColor) in [
            (WarmEditorialTokens.highlightYellow, HighlightColor.yellow),
            (WarmEditorialTokens.highlightGreen, HighlightColor.green),
            (WarmEditorialTokens.highlightBlue, HighlightColor.blue),
            (WarmEditorialTokens.highlightPink, HighlightColor.pink),
            (WarmEditorialTokens.highlightOrange, HighlightColor.yellow),
          ])
            GestureDetector(
              onTap: () => onColorSelected?.call(highlightColor),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ),
            ),
          const SizedBox(width: 8),
          TextButton(
            key: const Key('toolbar_define_button'),
            onPressed: onDefinePressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Define',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            key: const Key('toolbar_copy_button'),
            icon: const Icon(Icons.copy, size: 16, color: Colors.white),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: const BoxConstraints(),
            onPressed: onCopyPressed,
          ),
          if (onNotePressed != null)
            IconButton(
              icon: const Icon(Icons.edit_note, size: 18, color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              constraints: const BoxConstraints(),
              onPressed: onNotePressed,
            ),
          if (onSharePressed != null)
            IconButton(
              icon: const Icon(Icons.share, size: 16, color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              constraints: const BoxConstraints(),
              onPressed: onSharePressed,
            ),
        ],
      ),
    );
  }
}

/// Wiktionary Definition Card & Lookup Bottom Sheet matching Stitch screen 04c_text_selection_dictionary (3377a7d8).
class DictionaryLookupSheet extends StatelessWidget {
  const DictionaryLookupSheet({
    required this.selectedText,
    required this.onHighlight,
    this.entry,
    this.onDefinePressed,
    this.onCopyPressed,
    this.onColorSelected,
    this.showFloatingToolbar = false,
    super.key,
  });

  final String selectedText;
  final Future<void> Function() onHighlight;
  final DictionaryEntry? entry;
  final VoidCallback? onDefinePressed;
  final VoidCallback? onCopyPressed;
  final ValueChanged<HighlightColor>? onColorSelected;
  final bool showFloatingToolbar;

  @override
  Widget build(BuildContext context) {
    if (entry != null) {
      return _buildSheetContent(context, [entry!]);
    }

    if (!injector.isRegistered<DictionaryLookupCubit>()) {
      return _buildOfflineFallbackSheet(context, selectedText);
    }

    return BlocProvider(
      create: (_) => injector<DictionaryLookupCubit>()..lookup(selectedText),
      child: BlocBuilder<DictionaryLookupCubit, DictionaryLookupState>(
        builder: (context, state) {
          if (state.status == DictionaryLookupStatus.loading) {
            return _buildLoadingSheet(context);
          } else if (state.status == DictionaryLookupStatus.found && state.entries.isNotEmpty) {
            return _buildSheetContent(context, state.entries);
          } else if (state.status == DictionaryLookupStatus.notFound ||
              state.status == DictionaryLookupStatus.offline) {
            // Friendly offline fallback or not found state
            return _buildOfflineFallbackSheet(context, selectedText);
          } else {
            return _buildErrorSheet(context, selectedText);
          }
        },
      ),
    );
  }

  Widget _buildLoadingSheet(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(WarmEditorialTokens.bottomSheetRadiusLarge)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dragHandle(),
              const SizedBox(height: 16),
              Text(
                selectedText,
                style: const TextStyle(
                  fontFamily: 'Newsreader',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: WarmEditorialTokens.textPrimaryInk,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineFallbackSheet(BuildContext context, String word) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(WarmEditorialTokens.bottomSheetRadiusLarge)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _dragHandle()),
              const SizedBox(height: 16),
              Text(
                word,
                style: const TextStyle(
                  fontFamily: 'Newsreader',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: WarmEditorialTokens.textPrimaryInk,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.search_off_rounded, color: WarmEditorialTokens.subtitleSecondary, size: 24),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No definition found in local lexicon',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: WarmEditorialTokens.subtitleSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildFastActionRow(context, word),
              const SizedBox(height: 16),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorSheet(BuildContext context, String word) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(WarmEditorialTokens.bottomSheetRadiusLarge)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _dragHandle()),
              const SizedBox(height: 16),
              Text(
                word,
                style: const TextStyle(
                  fontFamily: 'Newsreader',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: WarmEditorialTokens.textPrimaryInk,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Lookup failed. You can still highlight or copy this text.',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: WarmEditorialTokens.subtitleSecondary),
              ),
              const SizedBox(height: 24),
              _buildFastActionRow(context, word),
              const SizedBox(height: 16),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetContent(BuildContext context, List<DictionaryEntry> entries) {
    final first = entries.first;
    final primaryMeaning = first.meanings.isNotEmpty ? first.meanings.first : null;
    final pos = primaryMeaning?.partOfSpeech ?? 'adjective';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showFloatingToolbar) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FloatingSelectionToolbar(
              onDefinePressed: onDefinePressed,
              onCopyPressed: onCopyPressed ?? () => _copy(context, first.word),
            ),
          ),
        ],
        Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(WarmEditorialTokens.bottomSheetRadiusLarge)),
          child: SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.75,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(child: _dragHandle()),
                    const SizedBox(height: 12),

                    // Header Row: Headword, phonetics, audio, bookmark, close
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10,
                                children: [
                                  Text(
                                    first.word,
                                    style: const TextStyle(
                                      fontFamily: 'Newsreader',
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: WarmEditorialTokens.textPrimaryInk,
                                    ),
                                  ),
                                  if (first.phonetic != null)
                                    Text(
                                      first.phonetic!,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: WarmEditorialTokens.subtitleSecondary,
                                      ),
                                    ),
                                  // Audio button
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: WarmEditorialTokens.surfaceContainerLow,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: WarmEditorialTokens.hairlineDivider),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.volume_up,
                                        size: 15,
                                        color: WarmEditorialTokens.accentInkBlue,
                                      ),
                                      padding: EdgeInsets.zero,
                                      onPressed: () {},
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Etymology Note
                              Row(
                                children: [
                                  const Icon(Icons.history_edu, size: 14, color: WarmEditorialTokens.subtitleSecondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Latin ${first.word}alis, from litus (‘shore’)',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: WarmEditorialTokens.subtitleSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                          color: WarmEditorialTokens.subtitleSecondary,
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          color: WarmEditorialTokens.subtitleSecondary,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Part of speech chips row
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Chip(
                          label: Text('$pos · Local Lexicon'),
                          backgroundColor: WarmEditorialTokens.accentInkBlue,
                          labelStyle: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        for (final meaning in first.meanings.skip(1))
                          Chip(
                            label: Text(meaning.partOfSpeech),
                            backgroundColor: WarmEditorialTokens.surfaceContainerLow,
                            labelStyle: const TextStyle(
                              fontFamily: 'Inter',
                              color: WarmEditorialTokens.subtitleSecondary,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                    const SizedBox(height: 14),

                    // Definitions List with left accent border blockquotes
                    for (final meaning in first.meanings)
                      for (final (index, def) in meaning.definitions.indexed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${index + 1}. ',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: WarmEditorialTokens.accentInkBlue,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      def.definition,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        height: 1.45,
                                        color: WarmEditorialTokens.textPrimaryInk,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (def.example != null) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.only(left: 10),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: Color(0x4D2F4A7A),
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    '“${def.example}”',
                                    style: const TextStyle(
                                      fontFamily: 'Newsreader',
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: WarmEditorialTokens.subtitleSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                    const SizedBox(height: 12),
                    _buildFastActionRow(context, first.word),
                    const SizedBox(height: 16),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dragHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFDCDAD5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildFastActionRow(BuildContext context, String word) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: WarmEditorialTokens.surfaceContainerLow,
              side: const BorderSide(color: WarmEditorialTokens.hairlineDivider),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.style, size: 16, color: WarmEditorialTokens.accentInkBlue),
            label: const Text(
              'Add to Flashcards',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WarmEditorialTokens.textPrimaryInk,
              ),
            ),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            backgroundColor: WarmEditorialTokens.surfaceContainerLow,
            side: const BorderSide(color: WarmEditorialTokens.hairlineDivider),
            shape: const StadiumBorder(),
          ),
          icon: const Icon(Icons.content_copy, size: 16, color: WarmEditorialTokens.subtitleSecondary),
          label: const Text(
            'Copy',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: WarmEditorialTokens.subtitleSecondary,
            ),
          ),
          onPressed: onCopyPressed ?? () => _copy(context, word),
        ),
        const SizedBox(width: 8),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: WarmEditorialTokens.surfaceContainerLow,
            side: const BorderSide(color: WarmEditorialTokens.hairlineDivider),
          ),
          icon: const Icon(Icons.open_in_new, size: 16, color: WarmEditorialTokens.subtitleSecondary),
          onPressed: () {
            final uri = Uri.parse('https://en.wiktionary.org/wiki/$word');
            unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
          },
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: WarmEditorialTokens.hairlineDivider)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'From Wiktionary · CC BY-SA 3.0 · Offline Lexicon',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: WarmEditorialTokens.subtitleSecondary,
              ),
            ),
          ),
          Row(
            children: [
              Icon(Icons.wifi_off, size: 13, color: Color(0xFF047857)),
              SizedBox(width: 4),
              Text(
                '0 B used',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF047857),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copy(BuildContext context, String text) {
    unawaited(Clipboard.setData(ClipboardData(text: text)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }
}
