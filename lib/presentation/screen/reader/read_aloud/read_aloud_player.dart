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

/// Expanded Read Aloud Player bottom sheet matching Stitch screen 05_read_aloud (b44bfe85).
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

  @override
  State<ReadAloudPlayer> createState() => _ReadAloudPlayerState();
}

class _ReadAloudPlayerState extends State<ReadAloudPlayer> {
  double _progress = 0.35;

  static final _defaultBook = BookEntity(
    id: 'active-reading-book',
    title: 'The Shadow of the Wind',
    author: 'Carlos Ruiz Zafón',
    format: DocumentFormat.epub,
    sourceUri: '',
    sourceFileName: 'shadow_of_the_wind.epub',
    contentFingerprint: 'shadow-wind-fp',
    addedAt: DateTime(2026, 10, 14),
  );

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
    final book = widget.book ?? _defaultBook;
    final sentence = widget.spokenSentence ??
        'I still remember the day that my father took me to the Cemetery of Forgotten Books for the first time.';

    final speedText = state != null ? '${state.speed}x' : '1.25x';
    final voiceText = state?.voice?.name ?? 'Natural Voice 2';
    final sleepText = state != null && state.sleep != SleepTimerChoice.off
        ? _sleepLabel(context, state.sleep)
        : '30 min timer';

    if (state?.problem != null) {
      return Material(
        key: const Key('read_aloud_player_sheet'),
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(WarmEditorialTokens.bottomSheetRadiusLarge)),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _Problem(
              problem: state!.problem!,
              onOpenSettings: widget.onOpenVoiceSettings ?? () {},
              onClose: cubit?.stop ?? () {},
            ),
          ),
        ),
      );
    }

    return Material(
      key: const Key('read_aloud_player_sheet'),
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(WarmEditorialTokens.bottomSheetRadiusLarge)),
      elevation: 12,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Drag Handle Pill
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCDAD5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header: Book cover thumbnail, metadata, minimize button
              Row(
                children: [
                  SizedBox(
                    width: 44,
                    height: 64,
                    child: BookCover(book: book, compact: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: WarmEditorialTokens.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                book.format.name.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: WarmEditorialTokens.subtitleSecondary,
                                ),
                              ),
                            ),
                            if (book.author != null) ...[
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  book.author!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: WarmEditorialTokens.subtitleSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Newsreader',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: WarmEditorialTokens.textPrimaryInk,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Chapter 4 · The Silent Harbour',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: WarmEditorialTokens.subtitleSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, size: 24, color: WarmEditorialTokens.subtitleSecondary),
                    tooltip: 'Minimize player',
                    onPressed: widget.onMinimize ?? () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Spoken sentence quote card with vertical left border in #2F4A7A
              Container(
                key: const Key('player_sentence_quote_card'),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: WarmEditorialTokens.canvasBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(
                    left: BorderSide(
                      color: WarmEditorialTokens.accentInkBlue,
                      width: 3.5,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'We walked through the sleeping alleys without exchanging a single word.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Newsreader',
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Color(0x806B655D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '“$sentence”',
                      style: const TextStyle(
                        fontFamily: 'Newsreader',
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: WarmEditorialTokens.textPrimaryInk,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'It was the early summer of 1945, and we walked through the streets of a city veiled in charcoal skies.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Newsreader',
                        fontSize: 12,
                        color: Color(0x996B655D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Timeline Scrubber & Timestamps
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: WarmEditorialTokens.accentInkBlue,
                      thumbColor: WarmEditorialTokens.accentInkBlue,
                      trackHeight: 3.0,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: _progress,
                      onChanged: (val) => setState(() => _progress = val),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '04:18',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: WarmEditorialTokens.subtitleSecondary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          'Sentence 14 of 48',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: WarmEditorialTokens.accentInkBlue,
                          ),
                        ),
                        Text(
                          '-08:42',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: WarmEditorialTokens.subtitleSecondary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Primary Playback Controls Row with 64px hero play/pause
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.bookmark_add_outlined, size: 22, color: WarmEditorialTokens.subtitleSecondary),
                    onPressed: () {},
                  ),
                  IconButton(
                    key: const Key('read_aloud_skip_back'),
                    icon: const Icon(Icons.replay_10, size: 28, color: WarmEditorialTokens.textPrimaryInk),
                    onPressed: widget.onSkipBack ?? cubit?.previous,
                  ),
                  GestureDetector(
                    key: const Key('read_aloud_play_pause_hero'),
                    onTap: widget.onPlayPause ?? (isPlaying ? cubit?.pause : cubit?.play),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: WarmEditorialTokens.accentInkBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x472F4A7A),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('read_aloud_skip_forward'),
                    icon: const Icon(Icons.forward_10, size: 28, color: WarmEditorialTokens.textPrimaryInk),
                    onPressed: widget.onSkipForward ?? cubit?.next,
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 22, color: WarmEditorialTokens.subtitleSecondary),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Adjustment Chips: Speed, Voice, Sleep timer
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.speed, size: 16, color: Colors.white),
                      label: Text(speedText),
                      backgroundColor: WarmEditorialTokens.accentInkBlue,
                      labelStyle: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      onPressed: () {
                        if (cubit != null) {
                          _pickSpeed(context, cubit.state.speed, cubit);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.record_voice_over_outlined, size: 16, color: WarmEditorialTokens.subtitleSecondary),
                      label: Text(voiceText),
                      backgroundColor: WarmEditorialTokens.surfaceContainerLow,
                      labelStyle: const TextStyle(
                        fontFamily: 'Inter',
                        color: WarmEditorialTokens.textPrimaryInk,
                        fontSize: 12,
                      ),
                      onPressed: () {
                        if (cubit != null && state != null) {
                          _pickVoice(context, state, cubit);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      avatar: const Icon(Icons.bedtime_outlined, size: 16, color: WarmEditorialTokens.subtitleSecondary),
                      label: Text(sleepText),
                      backgroundColor: WarmEditorialTokens.surfaceContainerLow,
                      labelStyle: const TextStyle(
                        fontFamily: 'Inter',
                        color: WarmEditorialTokens.textPrimaryInk,
                        fontSize: 12,
                      ),
                      onPressed: () {
                        if (cubit != null && state != null) {
                          _pickSleep(context, state.sleep, cubit);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Trust & Offline Identity Footer Note
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 12, color: WarmEditorialTokens.subtitleSecondary),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Local On-Device TTS · 0 KB network used',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: WarmEditorialTokens.subtitleSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  Future<void> _pickSpeed(BuildContext context, double current, ReadAloudCubit cubit) async {
    final speed = await _choose<double>(
      context,
      title: 'Speech Rate',
      options: [
        for (final sp in _speeds) (sp, '${sp}x'),
      ],
      selected: current,
    );
    if (speed != null) await cubit.setSpeed(speed);
  }

  Future<void> _pickSleep(BuildContext context, SleepTimerChoice current, ReadAloudCubit cubit) async {
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

  Future<void> _pickVoice(BuildContext context, ReadAloudState state, ReadAloudCubit cubit) async {
    final voice = await _choose<ReadAloudVoice>(
      context,
      title: 'Read Aloud Voice',
      options: [
        for (final v in state.voices) (v, '${v.name} · ${v.language}'),
      ],
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
                  if (value == selected) const Icon(Icons.check_rounded, color: WarmEditorialTokens.accentInkBlue),
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
