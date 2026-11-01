import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/entity/dictionary/dictionary_entry.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/reader/cubit/dictionary_lookup_cubit.dart';
import 'package:lingua_pages/presentation/screen/reader/cubit/dictionary_lookup_state.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bottom sheet that defines the selected word. Highlight and Copy are always
/// available, even when there is no definition.
class DictionaryLookupSheet extends StatelessWidget {
  const DictionaryLookupSheet({
    required this.selectedText,
    required this.onHighlight,
    super.key,
  });

  final String selectedText;
  final Future<void> Function() onHighlight;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => injector<DictionaryLookupCubit>()..lookup(selectedText),
      child: SafeArea(
        // Fits short answers; long definitions scroll within 75% of the
        // screen.
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .75,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: BlocBuilder<DictionaryLookupCubit, DictionaryLookupState>(
              builder: (context, state) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    child: SingleChildScrollView(child: _Body(state: state)),
                  ),
                  const SizedBox(height: 20),
                  _Actions(
                    state: state,
                    selectedText: selectedText,
                    onHighlight: onHighlight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final DictionaryLookupState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final word = state.word ?? '';
    return switch (state.status) {
      DictionaryLookupStatus.loading => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Headword(word: word),
          const SizedBox(height: 32),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 32),
        ],
      ),
      DictionaryLookupStatus.found => _Definitions(entries: state.entries),
      DictionaryLookupStatus.notFound => _Message(
        word: word,
        icon: Icons.search_off_rounded,
        title: l10n.readerNoDefinition,
        body: l10n.dictionaryNotFoundBody,
      ),
      DictionaryLookupStatus.offline => _Message(
        word: word,
        icon: Icons.cloud_off_outlined,
        title: l10n.dictionaryOfflineTitle,
        body: l10n.dictionaryOfflineBody,
      ),
      DictionaryLookupStatus.failed => _Message(
        word: word,
        icon: Icons.error_outline,
        title: l10n.readerLookupFailed,
        action: OutlinedButton.icon(
          onPressed: () => context.read<DictionaryLookupCubit>().retry(),
          icon: const Icon(Icons.refresh),
          label: Text(l10n.dictionaryRetry),
        ),
      ),
      DictionaryLookupStatus.notAWord => _Message(
        title: l10n.dictionaryNotAWord,
      ),
    };
  }
}

class _Headword extends StatelessWidget {
  const _Headword({required this.word, this.phonetic});

  final String word;
  final String? phonetic;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 12,
      children: [
        // Display style (28/800) from DESIGN.md: the word is the subject.
        Text(
          word,
          style: textTheme.headlineSmall?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        if (phonetic != null)
          Text(
            phonetic!,
            style: textTheme.titleMedium?.copyWith(
              color: context.colors.onSurfaceMuted,
            ),
          ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.title,
    this.word,
    this.icon,
    this.body,
    this.action,
  });

  final String title;
  final String? word;
  final IconData? icon;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (word != null && word!.isNotEmpty) ...[
          _Headword(word: word!),
          const SizedBox(height: 20),
        ],
        if (icon != null) ...[
          Icon(icon, color: context.colors.onSurfaceMuted),
          const SizedBox(height: 8),
        ],
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (body != null) ...[
          const SizedBox(height: 6),
          Text(
            body!,
            style: textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceMuted,
            ),
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerLeft, child: action),
        ],
      ],
    );
  }
}

class _Definitions extends StatelessWidget {
  const _Definitions({required this.entries});

  final List<DictionaryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final first = entries.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Headword(word: first.word, phonetic: first.phonetic),
        for (final entry in entries)
          for (final meaning in entry.meanings) _MeaningView(meaning: meaning),
        const SizedBox(height: 20),
        _Attribution(entry: first),
      ],
    );
  }
}

class _MeaningView extends StatelessWidget {
  const _MeaningView({required this.meaning});

  final DictionaryMeaning meaning;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;
    final synonyms = {
      ...meaning.synonyms,
      for (final definition in meaning.definitions) ...definition.synonyms,
    }.take(8).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meaning.partOfSpeech,
            style: textTheme.labelLarge?.copyWith(
              color: colors.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
          for (final (index, definition) in meaning.definitions.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Text('${index + 1}.', style: textTheme.bodyLarge),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(definition.definition, style: textTheme.bodyLarge),
                        if (definition.example != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '“${definition.example}”',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (synonyms.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  context.l10n.dictionarySynonyms,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
                for (final synonym in synonyms)
                  Chip(
                    label: Text(synonym),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Wiktionary content is CC BY-SA, so every result shows its license and
/// source, and says what was sent over the network.
class _Attribution extends StatelessWidget {
  const _Attribution({required this.entry});

  final DictionaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final license = entry.license;
    final source = entry.sourceUrls.isEmpty ? null : entry.sourceUrls.first;
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceMuted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dictionaryAttribution, style: style),
        Wrap(
          spacing: 4,
          children: [
            if (license != null)
              TextButton(
                onPressed: () => _open(license.url),
                child: Text(l10n.dictionaryLicense(license.name)),
              ),
            if (source != null)
              TextButton(
                onPressed: () => _open(source),
                child: Text(l10n.dictionarySource),
              ),
          ],
        ),
        Text(l10n.dictionaryNetworkNote, style: style),
      ],
    );
  }

  void _open(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') return;
    unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.state,
    required this.selectedText,
    required this.onHighlight,
  });

  final DictionaryLookupState state;
  final String selectedText;
  final Future<void> Function() onHighlight;

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final copiedText = context.l10n.readerWordCopied;
    final entries = state.entries;
    final definition = entries.isEmpty
        ? null
        : entries.first.meanings.firstOrNull?.definitions.firstOrNull;
    await Clipboard.setData(
      ClipboardData(
        text: definition == null
            ? selectedText
            : '${entries.first.word}: ${definition.definition}',
      ),
    );
    messenger.showSnackBar(SnackBar(content: Text(copiedText)));
  }

  /// Closes this sheet first, so the highlight sheet that follows is not
  /// stacked on top of the definition.
  Future<void> _highlight(BuildContext context) async {
    Navigator.of(context).pop();
    await onHighlight();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _copy(context),
            icon: const Icon(Icons.copy_outlined),
            label: Text(l10n.readerCopy),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _highlight(context),
            icon: const Icon(Icons.border_color_outlined),
            label: Text(l10n.readerHighlight),
          ),
        ),
      ],
    );
  }
}
