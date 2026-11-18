import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/entity/vocabulary/saved_word_entity.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_mini_player.dart';
import 'package:lingua_pages/presentation/screen/saved_words/cubit/saved_words_cubit.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/widgets/state_view.dart';

/// Every word saved from the dictionary lookup, across the library.
@RoutePage()
class SavedWordsScreen extends StatelessWidget {
  const SavedWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => injector<SavedWordsCubit>()..load(),
      child: const _SavedWordsView(),
    );
  }
}

class _SavedWordsView extends StatelessWidget {
  const _SavedWordsView();

  Future<void> _delete(BuildContext context, SavedWordEntity word) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<SavedWordsCubit>();
    final deleted = await cubit.delete(word);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          persist: false,
          content: Text(
            deleted
                ? l10n.savedWordsRemoved(word.word)
                : l10n.libraryActionFailed,
          ),
          action: deleted
              ? SnackBarAction(
                  label: l10n.libraryUndo,
                  onPressed: () => cubit.restore(word),
                )
              : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<SavedWordsCubit, SavedWordsState>(
      builder: (context, state) {
        final visible = state.visible;
        return ReadAloudMiniPlayerHost(
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.savedWordsTitle)),
            body: switch (state.status) {
              SavedWordsStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              SavedWordsStatus.failure => Center(
                child: StateView(
                  icon: Icons.error_outline_rounded,
                  title: l10n.savedWordsLoadFailed,
                  action: FilledButton(
                    onPressed: context.read<SavedWordsCubit>().load,
                    child: Text(l10n.retry),
                  ),
                ),
              ),
              SavedWordsStatus.success when state.words.isEmpty => Center(
                child: StateView(
                  icon: Icons.style_outlined,
                  title: l10n.savedWordsEmptyTitle,
                  body: l10n.savedWordsEmptyBody,
                ),
              ),
              SavedWordsStatus.success => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: TextField(
                      key: const Key('saved_words_search'),
                      onChanged: context.read<SavedWordsCubit>().search,
                      decoration: InputDecoration(
                        hintText: l10n.savedWordsSearchHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: visible.isEmpty
                        ? Center(
                            child: StateView(
                              icon: Icons.search_off_rounded,
                              title: l10n.savedWordsNoMatches,
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: visible.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) => _SavedWordCard(
                              word: visible[index],
                              onDelete: () => _delete(context, visible[index]),
                            ),
                          ),
                  ),
                ],
              ),
            },
          ),
        );
      },
    );
  }
}

class _SavedWordCard extends StatelessWidget {
  const _SavedWordCard({required this.word, required this.onDelete});

  final SavedWordEntity word;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final meta = [
      ?word.bookTitle,
      DateFormat.MMMd().format(word.createdAt),
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      decoration: BoxDecoration(
        color: WarmEditorialTokens.cardSurface,
        borderRadius: BorderRadius.circular(WarmEditorialTokens.cardRadius),
        border: Border.all(color: WarmEditorialTokens.hairlineDivider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      word.word,
                      style: const TextStyle(
                        fontFamily: 'Newsreader',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: WarmEditorialTokens.textPrimaryInk,
                      ),
                    ),
                    if (word.phonetic case final phonetic?)
                      Text(
                        phonetic,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: WarmEditorialTokens.subtitleSecondary,
                        ),
                      ),
                    if (word.partOfSpeech case final partOfSpeech?)
                      Text(
                        partOfSpeech,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: context.accent,
                        ),
                      ),
                  ],
                ),
                if (word.definition case final definition?) ...[
                  const SizedBox(height: 4),
                  Text(
                    definition,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      height: 1.4,
                      color: WarmEditorialTokens.textPrimaryInk,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  meta,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: WarmEditorialTokens.subtitleSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.delete,
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: WarmEditorialTokens.subtitleSecondary,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
