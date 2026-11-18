import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/service/read_aloud_service.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_cubit.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/sleep_timer.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
import 'package:lingua_pages/presentation/widgets/book/book_cover.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/reader_layout.dart';

const _speeds = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

/// The compact read-aloud player, the same in the reader and on every other
/// screen. Reads [ReadAloudCubit] from the context.
///
/// [onTap] runs for a tap on the cover and title: the reader opens the
/// listening controls, other screens open the book.
class ReadAloudPlayer extends StatelessWidget {
  const ReadAloudPlayer({
    required this.book,
    required this.progress,
    this.onTap,
    this.onOpenVoiceSettings,
    super.key,
  });

  final BookEntity book;

  /// How far reading has reached in the book, 0 to 1.
  final double progress;
  final VoidCallback? onTap;
  final VoidCallback? onOpenVoiceSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ReadAloudCubit>();
    final state = context.watch<ReadAloudCubit>().state;
    final percent = (progress.clamp(0.0, 1.0) * 100).round();

    return Material(
      key: const Key('read_aloud_player_sheet'),
      color: WarmEditorialTokens.cardSurface,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: .18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: WarmEditorialTokens.hairlineDivider),
      ),
      clipBehavior: Clip.antiAlias,
      child: state.problem != null
          ? Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 8, 6),
              child: _Problem(
                problem: state.problem!,
                onOpenSettings: onOpenVoiceSettings,
                onClose: cubit.stop,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          button: onTap != null,
                          label: l10n.readAloudShowControls,
                          child: InkWell(
                            key: const Key('read_aloud_player_open'),
                            borderRadius: BorderRadius.circular(10),
                            onTap: onTap,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: SizedBox(
                                    width: 38,
                                    height: 50,
                                    child: BookCover(book: book, compact: true),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Newsreader',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: WarmEditorialTokens
                                              .textPrimaryInk,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          if (state.isPlaying) ...[
                                            const Icon(
                                              Icons.graphic_eq_rounded,
                                              size: 14,
                                              color: WarmEditorialTokens
                                                  .accentInkBlue,
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                          Flexible(
                                            child: Text(
                                              l10n.readAloudStatusLine(
                                                _statusLabel(context, state),
                                                percent,
                                              ),
                                              key: const Key(
                                                'read_aloud_status_line',
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                                color: state.isPlaying
                                                    ? WarmEditorialTokens
                                                          .accentInkBlue
                                                    : WarmEditorialTokens
                                                          .subtitleSecondary,
                                                fontFeatures: const [
                                                  FontFeature.tabularFigures(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        key: const Key('read_aloud_skip_back'),
                        tooltip: l10n.readAloudPrevious,
                        icon: const Icon(Icons.skip_previous_rounded),
                        color: WarmEditorialTokens.textPrimaryInk,
                        onPressed: cubit.previous,
                      ),
                      _PlayPauseButton(state: state, cubit: cubit, size: 44),
                      IconButton(
                        key: const Key('read_aloud_skip_forward'),
                        tooltip: l10n.readAloudNext,
                        icon: const Icon(Icons.skip_next_rounded),
                        color: WarmEditorialTokens.textPrimaryInk,
                        onPressed: cubit.next,
                      ),
                      IconButton(
                        key: const Key('read_aloud_close'),
                        tooltip: l10n.readAloudStop,
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: WarmEditorialTokens.subtitleSecondary,
                        visualDensity: VisualDensity.compact,
                        onPressed: cubit.stop,
                      ),
                    ],
                  ),
                ),
                LinearProgressIndicator(
                  key: const Key('read_aloud_progress'),
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 3,
                  color: context.accent,
                  backgroundColor: WarmEditorialTokens.surfaceContainerHighest,
                ),
              ],
            ),
    );
  }
}

String _statusLabel(BuildContext context, ReadAloudState state) {
  final l10n = context.l10n;
  return switch (state.status) {
    ReadAloudStatus.loading => l10n.readAloudStatusLoading,
    ReadAloudStatus.playing => l10n.readAloudStatusPlaying,
    ReadAloudStatus.paused => l10n.readAloudStatusPaused,
    ReadAloudStatus.idle => l10n.readAloudStatusFinished,
  };
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.state,
    required this.cubit,
    required this.size,
  });

  final ReadAloudState state;
  final ReadAloudCubit cubit;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loading = state.status == ReadAloudStatus.loading;
    return Semantics(
      button: true,
      label: state.isPlaying ? l10n.readAloudPause : l10n.readAloudPlay,
      child: Material(
        key: const Key('read_aloud_play_pause_hero'),
        color: context.accent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: state.isPlaying ? cubit.pause : cubit.play,
          child: SizedBox.square(
            dimension: size,
            child: Center(
              child: loading
                  ? SizedBox.square(
                      dimension: size * .42,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      state.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: size * .6,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The full listening controls for [cubit]: position, transport, speed,
/// voice and sleep timer. [progress] is read on every rebuild so the bar
/// keeps moving while the sheet is open.
Future<void> showReadAloudControls(
  BuildContext context, {
  required ReadAloudCubit cubit,
  required BookEntity book,
  required ValueListenable<double> progress,
  VoidCallback? onOpenVoiceSettings,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: WarmEditorialTokens.cardSurface,
    builder: (sheetContext) => BlocProvider.value(
      value: cubit,
      child: _ReadAloudControls(
        book: book,
        progress: progress,
        onOpenVoiceSettings: onOpenVoiceSettings,
      ),
    ),
  );
}

class _ReadAloudControls extends StatelessWidget {
  const _ReadAloudControls({
    required this.book,
    required this.progress,
    this.onOpenVoiceSettings,
  });

  final BookEntity book;
  final ValueListenable<double> progress;
  final VoidCallback? onOpenVoiceSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ReadAloudCubit>();
    final state = context.watch<ReadAloudCubit>().state;
    // Stopping from the sheet closes it with the player.
    if (!state.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).maybePop();
      });
    }

    final nowPlaying = <Widget>[
      Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 56,
              height: 74,
              child: BookCover(book: book, compact: true),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.readAloudListening.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: context.accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Newsreader',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: WarmEditorialTokens.textPrimaryInk,
                  ),
                ),
                if (book.author case final author? when author.isNotEmpty)
                  Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: WarmEditorialTokens.subtitleSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      ValueListenableBuilder<double>(
        valueListenable: progress,
        builder: (context, value, _) {
          final clamped = value.clamp(0.0, 1.0);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: clamped,
                  minHeight: 5,
                  color: context.accent,
                  backgroundColor: WarmEditorialTokens.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.readAloudStatusLine(
                  _statusLabel(context, state),
                  (clamped * 100).round(),
                ),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: WarmEditorialTokens.subtitleSecondary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          );
        },
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: l10n.readAloudPrevious,
            iconSize: 34,
            icon: const Icon(Icons.skip_previous_rounded),
            color: WarmEditorialTokens.textPrimaryInk,
            onPressed: cubit.previous,
          ),
          const SizedBox(width: 20),
          _PlayPauseButton(state: state, cubit: cubit, size: 64),
          const SizedBox(width: 20),
          IconButton(
            tooltip: l10n.readAloudNext,
            iconSize: 34,
            icon: const Icon(Icons.skip_next_rounded),
            color: WarmEditorialTokens.textPrimaryInk,
            onPressed: cubit.next,
          ),
        ],
      ),
    ];
    final options = <Widget>[
      _SectionLabel(l10n.readAloudSpeed),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final speed in _speeds)
            ChoiceChip(
              label: Text(l10n.readAloudSpeedValue(_speedText(speed))),
              selected: state.speed == speed,
              onSelected: (_) => cubit.setSpeed(speed),
            ),
        ],
      ),
      const SizedBox(height: 18),
      _SectionLabel(l10n.readAloudVoice),
      Material(
        color: WarmEditorialTokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          key: const Key('read_aloud_voice_tile'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: const Icon(Icons.record_voice_over_outlined),
          title: Text(
            state.voice?.name ?? '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: state.voice == null ? null : Text(state.voice!.language),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _pickVoice(context, cubit),
        ),
      ),
      const SizedBox(height: 18),
      _SectionLabel(l10n.readAloudSleep),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final choice in SleepTimerChoice.values)
            ChoiceChip(
              label: Text(_sleepLabel(context, choice)),
              selected: state.sleep == choice,
              onSelected: (_) => cubit.setSleep(choice),
            ),
        ],
      ),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        key: const Key('read_aloud_stop_button'),
        icon: const Icon(Icons.stop_rounded),
        label: Text(l10n.readAloudStop),
        onPressed: cubit.stop,
      ),
    ];
    // Sideways, the player sits beside its options instead of above them,
    // so the transport stays on screen without scrolling.
    final size = MediaQuery.sizeOf(context);
    final sideBySide = size.width > size.height && size.width >= 600;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: sideBySide
            ? Row(
                key: const Key('read_aloud_controls_sheet'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: nowPlaying,
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: options,
                    ),
                  ),
                ],
              )
            : Column(
                key: const Key('read_aloud_controls_sheet'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...nowPlaying,
                  const SizedBox(height: 20),
                  ...options,
                ],
              ),
      ),
    );
  }

  Future<void> _pickVoice(BuildContext context, ReadAloudCubit cubit) async {
    final voice = await showModalBottomSheet<ReadAloudVoice>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: WarmEditorialTokens.cardSurface,
      builder: (sheetContext) => _VoicePicker(
        state: cubit.state,
        onOpenVoiceSettings: onOpenVoiceSettings,
      ),
    );
    if (voice != null) await cubit.setVoice(voice);
  }
}

/// Every installed voice, the book's language first.
class _VoicePicker extends StatelessWidget {
  const _VoicePicker({required this.state, this.onOpenVoiceSettings});

  final ReadAloudState state;
  final VoidCallback? onOpenVoiceSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedLanguage = state.voice?.language
        .toLowerCase()
        .split(RegExp('[-_]'))
        .first;
    bool matches(ReadAloudVoice voice) =>
        selectedLanguage != null &&
        voice.language.toLowerCase().startsWith(selectedLanguage);
    final preferred = state.voices.where(matches).toList();
    final others = state.voices.where((voice) => !matches(voice)).toList();

    Widget tile(ReadAloudVoice voice) => ListTile(
      title: Text(voice.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(voice.language),
      trailing: voice.id == state.voice?.id
          ? Icon(Icons.check_rounded, color: context.accent)
          : null,
      onTap: () => Navigator.of(context).pop(voice),
    );

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: readerSheetHeight(context, .75)),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                l10n.readAloudVoice,
                style: const TextStyle(
                  fontFamily: 'Newsreader',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: WarmEditorialTokens.textPrimaryInk,
                ),
              ),
            ),
            ...preferred.map(tile),
            if (others.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: _SectionLabel(l10n.readAloudOtherVoices),
              ),
              ...others.map(tile),
            ],
            if (onOpenVoiceSettings != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: TextButton.icon(
                  icon: const Icon(Icons.settings_voice_outlined),
                  label: Text(l10n.readAloudOpenSettings),
                  onPressed: onOpenVoiceSettings,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: WarmEditorialTokens.textPrimaryInk,
        ),
      ),
    );
  }
}

String _speedText(double speed) =>
    speed == speed.roundToDouble() ? speed.toStringAsFixed(1) : '$speed';

String _sleepLabel(BuildContext context, SleepTimerChoice choice) {
  final l10n = context.l10n;
  return switch (choice) {
    SleepTimerChoice.off => l10n.readAloudSleepOff,
    SleepTimerChoice.minutes15 => l10n.readAloudSleepMinutes(15),
    SleepTimerChoice.minutes30 => l10n.readAloudSleepMinutes(30),
    SleepTimerChoice.minutes60 => l10n.readAloudSleepMinutes(60),
    SleepTimerChoice.endOfChapter => l10n.readAloudSleepEndOfChapter,
  };
}

class _Problem extends StatelessWidget {
  const _Problem({
    required this.problem,
    required this.onClose,
    this.onOpenSettings,
  });

  final ReadAloudProblem problem;
  final VoidCallback? onOpenSettings;
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
        if (onOpenSettings != null)
          TextButton(
            onPressed: onOpenSettings,
            child: Text(l10n.readAloudOpenSettings),
          ),
      ],
    );
  }
}
