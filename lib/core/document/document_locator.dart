/// A format-neutral position inside an imported document.
sealed class DocumentLocator {
  const DocumentLocator();

  factory DocumentLocator.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'epub' => EpubLocator(cfi: json['cfi'] as String),
      'pdf' => PdfLocator(
        page: json['page'] as int,
        textOffset: json['textOffset'] as int?,
      ),
      'text' => TextLocator(offset: json['offset'] as int),
      _ => throw FormatException('Unsupported document locator: $json'),
    };
  }

  Map<String, dynamic> toJson();
}

final class EpubLocator extends DocumentLocator {
  const EpubLocator({required this.cfi});

  final String cfi;

  @override
  Map<String, dynamic> toJson() => {'type': 'epub', 'cfi': cfi};
}

final class PdfLocator extends DocumentLocator {
  const PdfLocator({required this.page, this.textOffset});

  final int page;
  final int? textOffset;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'pdf',
    'page': page,
    if (textOffset != null) 'textOffset': textOffset,
  };
}

final class TextLocator extends DocumentLocator {
  const TextLocator({required this.offset});

  final int offset;

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'offset': offset};
}
