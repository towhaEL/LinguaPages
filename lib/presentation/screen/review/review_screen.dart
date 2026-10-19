import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/entity/review/review_card_entity.dart';
import 'package:lingua_pages/domain/entity/review/review_history_entry.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/domain/entity/vocabulary/vocab_item_entity.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';
import 'package:lingua_pages/domain/repository/vocabulary/vocabulary_repository.dart';
import 'package:lingua_pages/domain/service/review_statistics.dart';
import 'package:lingua_pages/domain/service/review_notification_scheduler.dart';
import 'package:lingua_pages/domain/use_cases/review/review_card_use_case.dart';
import 'package:lingua_pages/l10n/l10n.dart';

@RoutePage()
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) => const _ReviewView();
}

class _ReviewView extends StatefulWidget {
  const _ReviewView();

  @override
  State<_ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<_ReviewView> {
  late final ReviewCardUseCase _reviewUseCase = injector<ReviewCardUseCase>();
  late final VocabularyRepository _vocabularyRepository =
      injector<VocabularyRepository>();
  late final SettingsRepository _settingsRepository =
      injector<SettingsRepository>();
  late final ReviewNotificationScheduler _reviewNotifications =
      injector<ReviewNotificationScheduler>();

  List<ReviewCardEntity> _cards = const [];
  ReviewStatistics _statistics = const ReviewStatistics(
    totalCards: 0,
    reviewedCards: 0,
    dueCards: 0,
    activeDays: 0,
    currentStreak: 0,
  );
  Map<String, VocabItemEntity> _vocabulary = const {};
  List<ReviewHistoryItem> _history = const [];
  var _isLoading = true;
  var _isAnswerVisible = false;
  String? _errorMessage;

  ReviewCardEntity? get _card => _cards.isEmpty ? null : _cards.first;
  VocabItemEntity? get _item =>
      _card == null ? null : _vocabulary[_card!.vocabItemId];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isAnswerVisible = false;
    });
    try {
      final results = await Future.wait<Object>([
        _reviewUseCase.getDueCards(),
        _reviewUseCase.getAllCards(),
        _vocabularyRepository.getAll(),
        _settingsRepository.getSettings(),
        _reviewUseCase.getHistory(),
      ]);
      if (!mounted) return;
      final dueCards = results[0] as List<ReviewCardEntity>;
      final allCards = results[1] as List<ReviewCardEntity>;
      final settings = results[3] as SettingsEntity;
      final history = results[4] as List<ReviewHistoryItem>;
      final cards = _applyDailyNewCardLimit(
        dueCards,
        settings.dailyNewCardLimit,
      );
      setState(() {
        _cards = cards;
        _statistics = ReviewStatistics.fromCards(allCards);
        _vocabulary = {
          for (final item in results[2] as List<VocabItemEntity>) item.id: item,
        };
        _history = history;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cards = const [];
        _history = const [];
        _isLoading = false;
        _errorMessage = context.l10n.reviewLoadFailed;
      });
    }
  }

  List<ReviewCardEntity> _applyDailyNewCardLimit(
    List<ReviewCardEntity> cards,
    int limit,
  ) {
    var newCards = 0;
    return [
      for (final card in cards)
        if (card.state != ReviewCardState.newCard || newCards++ < limit) card,
    ];
  }

  Future<void> _review(ReviewRating rating) async {
    final card = _card;
    if (card == null || !_isAnswerVisible) return;
    try {
      await _reviewUseCase.recordReview(cardId: card.id, rating: rating);
      await _reviewNotifications.sync();
      await _load();
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = context.l10n.reviewSaveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.reviewTitle),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: context.l10n.refresh,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : item == null
          ? _buildEmptyState(context)
          : _buildCard(context, item),
    );
  }

  Widget _buildCard(BuildContext context, VocabItemEntity item) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
      children: [
        _buildStatistics(context),
        const SizedBox(height: 20),
        _buildRecentHistory(context),
        const SizedBox(height: 20),
        Text(
          context.l10n.reviewDueCount(_cards.length),
          style: Theme.of(context).textTheme.labelLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (_isAnswerVisible || item.sourceSentence.isEmpty)
                  Text(
                    item.word,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  )
                else ...[
                  Text(
                    context.l10n.reviewContextPrompt,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _hiddenSentence(item.sourceSentence, item.word),
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                if (_isAnswerVisible) ...[
                  Text(
                    item.translation,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (item.sourceSentence.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      item.sourceSentence,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ] else
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _isAnswerVisible = true),
                    icon: const Icon(Icons.visibility_outlined),
                    label: Text(context.l10n.reviewShowAnswer),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_isAnswerVisible) ...[
          Text(
            context.l10n.reviewRate,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _ratingButton(context, ReviewRating.again, Colors.red),
              _ratingButton(context, ReviewRating.hard, Colors.orange),
              _ratingButton(context, ReviewRating.good, Colors.green),
              _ratingButton(context, ReviewRating.easy, Colors.blue),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
      children: [
        _buildStatistics(context),
        const SizedBox(height: 20),
        _buildRecentHistory(context),
        const SizedBox(height: 36),
        Center(child: Text(context.l10n.reviewEmpty)),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _stat(context.l10n.reviewStatsDue, _statistics.dueCards, textTheme),
            _stat(
              context.l10n.reviewStatsReviewed,
              _statistics.reviewedCards,
              textTheme,
            ),
            _stat(
              context.l10n.reviewStatsStreak,
              _statistics.currentStreak,
              textTheme,
            ),
            _stat(
              context.l10n.reviewStatsActiveDays,
              _statistics.activeDays,
              textTheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHistory(BuildContext context) {
    if (_history.isEmpty) return const SizedBox.shrink();
    final entries = _history.take(10);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                context.l10n.reviewRecentHistory,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final entry in entries)
              ListTile(
                dense: true,
                leading: const Icon(Icons.history_rounded),
                title: Text(
                  _vocabulary[entry.vocabItemId]?.word ?? entry.vocabItemId,
                ),
                subtitle: Text(_ratingLabel(context, entry.rating)),
                trailing: Text(
                  MaterialLocalizations.of(context).formatShortDate(
                    entry.reviewedAt,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, int value, TextTheme textTheme) {
    return Column(
      children: [
        Text('$value', style: textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(label, style: textTheme.labelSmall),
      ],
    );
  }

  String _hiddenSentence(String sentence, String word) {
    final escaped = RegExp.escape(word.trim());
    if (escaped.isEmpty) return sentence;
    return sentence
        .replaceAll(RegExp(escaped, caseSensitive: false), '_____ ')
        .replaceAll('  ', ' ');
  }

  Widget _ratingButton(BuildContext context, ReviewRating rating, Color color) {
    return FilledButton(
      style: FilledButton.styleFrom(backgroundColor: color),
      onPressed: () => _review(rating),
      child: Text(_ratingLabel(context, rating)),
    );
  }

  String _ratingLabel(BuildContext context, ReviewRating rating) =>
      switch (rating) {
        ReviewRating.again => context.l10n.reviewAgain,
        ReviewRating.hard => context.l10n.reviewHard,
        ReviewRating.good => context.l10n.reviewGood,
        ReviewRating.easy => context.l10n.reviewEasy,
      };
}
