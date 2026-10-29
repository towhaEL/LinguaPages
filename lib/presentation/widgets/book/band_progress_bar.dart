import 'package:flutter/material.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

/// Progress drawn in the document's band colour, true to scale.
class BandProgressBar extends StatelessWidget {
  const BandProgressBar({
    super.key,
    required this.progress,
    required this.color,
    this.height = 6,
  });

  final double progress;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);
    return Semantics(
      value: '${(value * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: context.colors.surfaceElevated),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: ColoredBox(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
