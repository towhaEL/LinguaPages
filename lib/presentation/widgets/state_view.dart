import 'package:flutter/material.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

/// Centered empty or error state: icon, title, body and an optional action.
class StateView extends StatelessWidget {
  const StateView({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.action,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: iconColor ?? colors.onSurfaceMuted),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(
              body!,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(
                color: colors.onSurfaceMuted,
                height: 1.45,
              ),
            ),
          ],
          if (action != null) ...[const SizedBox(height: 24), action!],
        ],
      ),
    );
  }
}
