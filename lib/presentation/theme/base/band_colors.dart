import 'package:flutter/material.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';

/// Series band colours: every document format wears one flat print colour.
///
/// All bands keep ≥4.5:1 contrast with [onBand], so the format code printed
/// on a band stays legible at label size.
@immutable
class BandColors extends ThemeExtension<BandColors> {
  const BandColors({
    required this.epub,
    required this.pdf,
    required this.txt,
    required this.markdown,
    required this.html,
    required this.fb2,
    required this.onBand,
    required this.label,
    required this.onLabel,
  });

  final Color epub;
  final Color pdf;
  final Color txt;
  final Color markdown;
  final Color html;
  final Color fb2;

  /// Ink printed on any band.
  final Color onBand;

  /// Cream title panel used when a document has no cover image.
  final Color label;
  final Color onLabel;

  Color forFormat(DocumentFormat format) => switch (format) {
    DocumentFormat.epub => epub,
    DocumentFormat.pdf => pdf,
    DocumentFormat.txt => txt,
    DocumentFormat.markdown => markdown,
    DocumentFormat.html => html,
    DocumentFormat.fb2 => fb2,
  };

  @override
  BandColors copyWith({
    Color? epub,
    Color? pdf,
    Color? txt,
    Color? markdown,
    Color? html,
    Color? fb2,
    Color? onBand,
    Color? label,
    Color? onLabel,
  }) {
    return BandColors(
      epub: epub ?? this.epub,
      pdf: pdf ?? this.pdf,
      txt: txt ?? this.txt,
      markdown: markdown ?? this.markdown,
      html: html ?? this.html,
      fb2: fb2 ?? this.fb2,
      onBand: onBand ?? this.onBand,
      label: label ?? this.label,
      onLabel: onLabel ?? this.onLabel,
    );
  }

  @override
  BandColors lerp(covariant ThemeExtension<BandColors>? other, double t) {
    if (other is! BandColors) return this;
    return BandColors(
      epub: Color.lerp(epub, other.epub, t)!,
      pdf: Color.lerp(pdf, other.pdf, t)!,
      txt: Color.lerp(txt, other.txt, t)!,
      markdown: Color.lerp(markdown, other.markdown, t)!,
      html: Color.lerp(html, other.html, t)!,
      fb2: Color.lerp(fb2, other.fb2, t)!,
      onBand: Color.lerp(onBand, other.onBand, t)!,
      label: Color.lerp(label, other.label, t)!,
      onLabel: Color.lerp(onLabel, other.onLabel, t)!,
    );
  }
}
