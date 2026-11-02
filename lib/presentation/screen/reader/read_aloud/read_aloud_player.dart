import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_pages/domain/service/read_aloud_service.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_cubit.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/sleep_timer.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0];

/// The read-aloud controls, docked at the bottom of the reader.
class ReadAloudPlayer extends StatelessWidget {
  const ReadAloudPlayer({required this.onOpenVoiceSettings, super.key});

  final VoidCallback onOpenVoiceSettings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<ReadAloudCubit, ReadAloudState>(
      builder: (context, state) {
        final cubit = context.read<ReadAloudCubit>();
        final l10n = context.l10n;
        return Material(
          color: Theme.of(context).navigationBarTheme.backgroundColor,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: state.problem != null
                  ? _Problem(
                      problem: state.problem!,
                      onOpenSettings: onOpenVoiceSettings,
                      onClose: cubit.stop,
                    )
                  : Row(
                      children: [
                        IconButton(
                          tooltip: l10n.readAloudStop,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: cubit.stop,
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: l10n.readAloudPrevious,
                          icon: const Icon(Icons.skip_previous_rounded),
                          onPressed: cubit.previous,
                        ),
                        IconButton.filled(
                          tooltip: state.isPlaying
                              ? l10n.readAloudPause
                              : l10n.readAloudPlay,
                          iconSize: 32,
                          icon: state.status == ReadAloudStatus.loading
                              ? SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: colors.onPrimary,
                                  ),
                                )
                              : Icon(
                                  state.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                          onPressed: state.isPlaying ? cubit.pause : cubit.play,
                        ),
                        IconButton(
                          tooltip: l10n.readAloudNext,
                          icon: const Icon(Icons.skip_next_rounded),
                          onPressed: cubit.next,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _pickSpeed(context, state.speed),
                          child: Text(
                            l10n.readAloudSpeedValue(_speedLabel(state.speed)),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.readAloudSleep,
                          isSelected: state.sleep != SleepTimerChoice.off,
                          icon: const Icon(Icons.bedtime_outlined),
                          selectedIcon: const Icon(Icons.bedtime_rounded),
                          onPressed: () => _pickSleep(context, state.sleep),
                        ),
                        IconButton(
                          tooltip: l10n.readAloudVoice,
                          icon: const Icon(Icons.record_voice_over_outlined),
                          onPressed: () => _pickVoice(context, state),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  static String _speedLabel(double speed) =>
      speed == speed.roundToDouble() ? speed.toStringAsFixed(1) : '$speed';

  Future<void> _pickSpeed(BuildContext context, double current) async {
    final cubit = context.read<ReadAloudCubit>();
    final speed = await _choose<double>(
      context,
      title: context.l10n.readAloudSpeed,
      options: [
        for (final speed in _speeds)
          (speed, context.l10n.readAloudSpeedValue(_speedLabel(speed))),
      ],
      selected: current,
    );
    if (speed != null) await cubit.setSpeed(speed);
  }

  Future<void> _pickSleep(
    BuildContext context,
    SleepTimerChoice current,
  ) async {
    final cubit = context.read<ReadAloudCubit>();
    final l10n = context.l10n;
    final choice = await _choose<SleepTimerChoice>(
      context,
      title: l10n.readAloudSleep,
      options: [
        (SleepTimerChoice.off, l10n.readAloudSleepOff),
        (SleepTimerChoice.minutes15, l10n.readAloudSleepMinutes(15)),
        (SleepTimerChoice.minutes30, l10n.readAloudSleepMinutes(30)),
        (SleepTimerChoice.minutes60, l10n.readAloudSleepMinutes(60)),
        (SleepTimerChoice.endOfChapter, l10n.readAloudSleepEndOfChapter),
      ],
      selected: current,
    );
    if (choice != null) cubit.setSleep(choice);
  }

  Future<void> _pickVoice(BuildContext context, ReadAloudState state) async {
    final cubit = context.read<ReadAloudCubit>();
    final voice = await _choose<ReadAloudVoice>(
      context,
      title: context.l10n.readAloudVoice,
      options: [
        for (final voice in state.voices)
          (voice, '${voice.name} · ${voice.language}'),
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
                  if (value == selected) const Icon(Icons.check_rounded),
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
