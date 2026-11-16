import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/service/read_aloud_service.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_cubit.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/sleep_timer.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
import 'package:lingua_pages/presentation/widgets/book/book_cover.dart';

const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0];

/// Spotify-style compact mini player for Read Aloud.
class ReadAloudPlayer extends StatefulWidget {
  const ReadAloudPlayer({
    this.onOpenVoiceSettings,
    this.book,
    this.spokenSentence,
    this.isPlaying,
    this.onPlayPause,
    this.onSkipForward,
    this.onSkipBack,
    this.onMinimize,
    this.onBookmark,
    this.onMore,
    super.key,
  });

  final VoidCallback? onOpenVoiceSettings;
  final BookEntity? book;
  final String? spokenSentence;
  final bool? isPlaying;
  final VoidCallback? onPlayPause;
  final VoidCallback? onSkipForward;
  final VoidCallback? onSkipBack;
  final VoidCallback? onMinimize;
  final VoidCallback? onBookmark;
  final VoidCallback? onMore;

  @override
  State<ReadAloudPlayer> createState() => _ReadAloudPlayerState();
}

class _ReadAloudPlayerState extends State<ReadAloudPlayer> {
  late double _progress = (widget.book?.progress ?? 0.35).clamp(0.0, 1.0);

  static final _fallbackBook = BookEntity(
    id: 'active-reading-book',
    title: 'Document',
    author: null,
    format: DocumentFormat.epub,
    sourceUri: '',
    sourceFileName: '',
    contentFingerprint: '',
    addedAt: DateTime(2026, 1, 1),
  );

  @override
  void didUpdateWidget(ReadAloudPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.book?.progress != null &&
        widget.book!.progress != oldWidget.book?.progress) {
      _progress = widget.book!.progress.clamp(0.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    ReadAloudCubit? cubit;
    ReadAloudState? state;
    try {
      cubit = context.read<ReadAloudCubit>();
      state = context.watch<ReadAloudCubit>().state;
    } catch (_) {
      // Standalone contract or test context where ReadAloudCubit is not provided
    }

    final isPlaying = widget.isPlaying ?? state?.isPlaying ?? true;
    final book = widget.book ?? _fallbackBook;

    final speedText = state != null ? '${state.speed}x' : '1.0x';
    final voiceText = state?.voice?.name ?? 'Natural Voice 1';
    final sleepText = state != null && state.sleep != SleepTimerChoice.off
        ? _sleepLabel(context, state.sleep)
        : '30 min timer';

    if (state?.problem != null) {
      return Material(
        key: const Key('read_aloud_player_sheet'),
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _Problem(
            problem: state!.problem!,
            onOpenSettings: widget.onOpenVoiceSettings ?? () {},
            onClose: cubit?.stop ?? () {},
          ),
        ),
      );
    }

    final effectiveProgress = (widget.book?.progress ?? _progress).clamp(0.0, 1.0);

    return Material(
      key: const Key('read_aloud_player_sheet'),
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Scrubber: Slim Spotify-style track across the top
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: WarmEditorialTokens.accentInkBlue,
                inactiveTrackColor: WarmEditorialTokens.surfaceContainerHighest,
                thumbColor: WarmEditorialTokens.accentInkBlue,
                trackHeight: 2.5,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
                trackShape: const RectangularSliderTrackShape(),
              ),
              child: SizedBox(
                height: 8,
                child: Slider(
                  value: _progress.clamp(0.0, 1.0),
                  onChanged: (val) => setState(() => _progress = val.clamp(0.0, 1.0)),
                ),
              ),
            ),

            // Spoken sentence quote card: only rendered when explicitly passed (e.g. tests); omitted in reading mode to keep player minimal
            if (widget.spokenSentence != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                child: Container(
                  key: const Key('player_sentence_quote_card'),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: WarmEditorialTokens.canvasBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(
                      left: BorderSide(
                        color: WarmEditorialTokens.accentInkBlue,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    '“${widget.spokenSentence}”',
                    style: const TextStyle(
                      fontFamily: 'Newsreader',
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: WarmEditorialTokens.textPrimaryInk,
                    ),
                  ),
                ),
              ),
            ],

            // Main Mini Player Row: Cover + Info + Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 8, 4),
              child: Row(
                children: [
                  // Book cover thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 34,
                      height: 44,
                      child: BookCover(book: book, compact: true),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Metadata: Title, format, author, real progress %
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Newsreader',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: WarmEditorialTokens.textPrimaryInk,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: WarmEditorialTokens.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                book.format.name.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: WarmEditorialTokens.subtitleSecondary,
                                ),
                              ),
                            ),
                            if (book.author != null && book.author!.isNotEmpty) ...[
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  book.author!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: WarmEditorialTokens.subtitleSecondary,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 6),
                            Text(
                              '${(effectiveProgress * 100).round()}%',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10.5,
                                color: WarmEditorialTokens.subtitleSecondary,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Controls: Skip Back + Hero Play/Pause + Skip Forward + Close
                  IconButton(
                    key: const Key('read_aloud_skip_back'),
                    icon: const Icon(Icons.replay_10, size: 22),
                    color: WarmEditorialTokens.textPrimaryInk,
                    tooltip: 'Skip back 10s',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: widget.onSkipBack ?? cubit?.previous,
                  ),
                  const SizedBox(width: 2),
                  GestureDetector(
                    key: const Key('read_aloud_play_pause_hero'),
                    onTap: widget.onPlayPause ?? (isPlaying ? cubit?.pause : cubit?.play),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: WarmEditorialTokens.accentInkBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x332F4A7A),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    key: const Key('read_aloud_skip_forward'),
                    icon: const Icon(Icons.forward_10, size: 22),
                    color: WarmEditorialTokens.textPrimaryInk,
                    tooltip: 'Skip forward 10s',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: widget.onSkipForward ?? cubit?.next,
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: WarmEditorialTokens.subtitleSecondary,
                    tooltip: 'Stop player',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    onPressed: widget.onMinimize ?? cubit?.stop ?? () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),

            // Secondary Row: Quick Setting Chips (Speed, Voice, Sleep)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.speed, size: 14, color: WarmEditorialTokens.accentInkBlue),
                      label: Text(speedText),
                      labelStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: WarmEditorialTokens.accentInkBlue,
                      ),
                      backgroundColor: WarmEditorialTokens.surfaceContainerLow,
                      onPressed: () {
                        if (cubit != null) {
                          _pickSpeed(context, cubit.state.speed, cubit);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(
                        Icons.record_voice_over_outlined,
                        size: 14,
                        color: WarmEditorialTokens.subtitleSecondary,
                      ),
                      label: Text(voiceText),
                      labelStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: WarmEditorialTokens.textPrimaryInk,
                      ),
                      backgroundColor: WarmEditorialTokens.surfaceContainerLow,
                      onPressed: () {
                        if (cubit != null && state != null) {
                          _pickVoice(context, state, cubit);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(
                        Icons.bedtime_outlined,
                        size: 14,
                        color: WarmEditorialTokens.subtitleSecondary,
                      ),
                      label: Text(sleepText),
                      labelStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: WarmEditorialTokens.textPrimaryInk,
                      ),
                      backgroundColor: WarmEditorialTokens.surfaceContainerLow,
                      onPressed: () {
                        if (cubit != null && state != null) {
                          _pickSleep(context, state.sleep, cubit);
                        }
                      },
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

  static String _sleepLabel(BuildContext context, SleepTimerChoice choice) =>
      switch (choice) {
        SleepTimerChoice.off => 'Off',
        SleepTimerChoice.minutes15 => '15 min',
        SleepTimerChoice.minutes30 => '30 min',
        SleepTimerChoice.minutes60 => '60 min',
        SleepTimerChoice.endOfChapter => 'End of chapter',
      };

  Future<void> _pickSpeed(
    BuildContext context,
    double current,
    ReadAloudCubit cubit,
  ) async {
    final speed = await _choose<double>(
      context,
      title: 'Speech Rate',
      options: [for (final sp in _speeds) (sp, '${sp}x')],
      selected: current,
    );
    if (speed != null) await cubit.setSpeed(speed);
  }

  Future<void> _pickSleep(
    BuildContext context,
    SleepTimerChoice current,
    ReadAloudCubit cubit,
  ) async {
    final choice = await _choose<SleepTimerChoice>(
      context,
      title: 'Sleep Timer',
      options: [
        (SleepTimerChoice.off, 'Off'),
        (SleepTimerChoice.minutes15, '15 minutes'),
        (SleepTimerChoice.minutes30, '30 minutes'),
        (SleepTimerChoice.minutes60, '60 minutes'),
        (SleepTimerChoice.endOfChapter, 'End of chapter'),
      ],
      selected: current,
    );
    if (choice != null) cubit.setSleep(choice);
  }

  Future<void> _pickVoice(
    BuildContext context,
    ReadAloudState state,
    ReadAloudCubit cubit,
  ) async {
    final availableVoices = state.voices.take(5).toList();
    final voice = await _choose<ReadAloudVoice>(
      context,
      title: 'Read Aloud Voice',
      options: [for (final v in availableVoices) (v, '${v.name} · ${v.language}')],
      selected: state.voice,
    );
    if (voice != null) await cubit.setVoice(voice);
  }

  Future<T?> _choose<T>(
    BuildContext context, {
    required String title,
    required List<(T, String)> options,
    required T? selected,
  }) {
    return showDialog<T>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(title),
        children: [
          for (final (value, label) in options)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(value),
              child: Row(
                children: [
                  Expanded(child: Text(label)),
                  if (value == selected)
                    const Icon(
                      Icons.check_rounded,
                      color: WarmEditorialTokens.accentInkBlue,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem({
    required this.problem,
    required this.onOpenSettings,
    required this.onClose,
  });

  final ReadAloudProblem problem;
  final VoidCallback onOpenSettings;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        IconButton(
          tooltip: l10n.readAloudStop,
          icon: const Icon(Icons.close_rounded),
          onPressed: onClose,
        ),
        Expanded(
          child: Text(
            problem == ReadAloudProblem.noEngine
                ? l10n.readAloudNoEngine
                : l10n.readAloudNoVoice,
          ),
        ),
        TextButton(
          onPressed: onOpenSettings,
          child: Text(l10n.readAloudOpenSettings),
        ),
      ],
    );
  }
}
