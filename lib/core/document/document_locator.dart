/// A format-neutral position inside an imported document.
sealed class DocumentLocator {
  const DocumentLocator();

  factory DocumentLocator.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'epub' => EpubLocator(
        cfi: json['cfi'] as String,
        locatorJson: json['locatorJson'] as String?,
      ),
      'pdf' => PdfLocator(
        page: json['page'] as int,
        textOffset: json['textOffset'] as int?,
        locatorJson: json['locatorJson'] as String?,
      ),
      'text' => TextLocator(offset: json['offset'] as int),
      _ => throw FormatException('Unsupported document locator: $json'),
    };
  }

  Map<String, dynamic> toJson();
}

final class EpubLocator extends DocumentLocator {
  const EpubLocator({required this.cfi, this.locatorJson});

  final String cfi;

  /// The complete native Readium locator when this position originated from
  /// the platform reader. Keeping it optional preserves the format-neutral
  /// contract for fallback EPUB adapters.
  final String? locatorJson;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'epub',
    'cfi': cfi,
    if (locatorJson != null) 'locatorJson': locatorJson,
  };
}

final class PdfLocator extends DocumentLocator {
  const PdfLocator({required this.page, this.textOffset, this.locatorJson});

  final int page;
  final int? textOffset;
  final String? locatorJson;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'pdf',
    'page': page,
    if (textOffset != null) 'textOffset': textOffset,
    if (locatorJson != null) 'locatorJson': locatorJson,
  };
}

final class TextLocator extends DocumentLocator {
  const TextLocator({required this.offset});

  final int offset;

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'offset': offset};
}
