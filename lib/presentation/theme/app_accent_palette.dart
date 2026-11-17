import 'package:flutter/material.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';

/// The colours one [AppAccent] gives the light theme. White text on
/// [primary] and [primary] text on [container] both keep 4.5:1 or better.
class AccentColors {
  const AccentColors({required this.primary, required this.container});

  final Color primary;

  /// A pale tint for selected chips, badges and the text selection.
  final Color container;
}

extension AppAccentPalette on AppAccent {
  AccentColors get colors => switch (this) {
    AppAccent.inkBlue => const AccentColors(
      primary: Color(0xFF2F4A7A),
      container: Color(0xFFD6E2F5),
    ),
    AppAccent.forest => const AccentColors(
      primary: Color(0xFF2F6A4F),
      container: Color(0xFFD4EADF),
    ),
    AppAccent.teal => const AccentColors(
      primary: Color(0xFF1D6670),
      container: Color(0xFFCDE7EA),
    ),
    AppAccent.plum => const AccentColors(
      primary: Color(0xFF5D3F7D),
      container: Color(0xFFE7DDF3),
    ),
    AppAccent.burgundy => const AccentColors(
      primary: Color(0xFF8C2F3D),
      container: Color(0xFFF4D9DD),
    ),
    AppAccent.terracotta => const AccentColors(
      primary: Color(0xFF9E4A28),
      container: Color(0xFFF7DDCF),
    ),
    AppAccent.ochre => const AccentColors(
      primary: Color(0xFF805A12),
      container: Color(0xFFF3E5C6),
    ),
    AppAccent.graphite => const AccentColors(
      primary: Color(0xFF3B3B3D),
      container: Color(0xFFE4E2DF),
    ),
  };

  String get label => switch (this) {
    AppAccent.inkBlue => 'Ink Blue',
    AppAccent.forest => 'Forest',
    AppAccent.teal => 'Lagoon',
    AppAccent.plum => 'Plum',
    AppAccent.burgundy => 'Bordeaux',
    AppAccent.terracotta => 'Terracotta',
    AppAccent.ochre => 'Ochre',
    AppAccent.graphite => 'Graphite',
  };
}
