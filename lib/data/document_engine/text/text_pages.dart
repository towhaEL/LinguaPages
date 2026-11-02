/// Pages of about [size] characters over reflowable text.
///
/// Each page edge sits on the 2400-character grid, moved forward to the next
/// word start, so a word is never split and page `i` still begins within a
/// word of `i * size`. Saved text offsets therefore keep their page.
class TextPages {
  TextPages(this.text, {this.size = 2400}) : _starts = _pageStarts(text, size);

  /// Longest run moved past before a page is cut mid-word (a URL, say).
  static const _maxWordLength = 48;

  final String text;
  final int size;
  final List<int> _starts;

  int get count => _starts.length;

  int start(int page) => _starts[page];

  int end(int page) =>
      page + 1 < _starts.length ? _starts[page + 1] : text.length;

  String pageText(int page) => text.substring(start(page), end(page));

  /// The page holding [offset], clamped to the document.
  int pageOf(int offset) {
    final page = (offset ~/ size).clamp(0, count - 1);
    return offset < _starts[page] ? page - 1 : page;
  }

  static List<int> _pageStarts(String text, int size) {
    final starts = [0];
    for (var grid = size; grid < text.length; grid += size) {
      final limit = (grid + _maxWordLength).clamp(0, text.length);
      var start = grid;
      // Finish the word, then the space after it, so the page opens on a word.
      while (start < limit &&
          (_insideWord(text, start) || _isSpace(text.codeUnitAt(start)))) {
        start++;
      }
      if (start == limit && limit < text.length) {
        // No break nearby: cut on the grid, but not inside a surrogate pair.
        start = _isLowSurrogate(text.codeUnitAt(grid)) ? grid + 1 : grid;
      }
      if (start < text.length) starts.add(start);
    }
    return starts;
  }

  static bool _insideWord(String text, int index) =>
      !_isSpace(text.codeUnitAt(index - 1)) &&
      !_isSpace(text.codeUnitAt(index));

  static bool _isSpace(int unit) =>
      unit == 0x20 ||
      unit == 0x0A ||
      unit == 0x09 ||
      unit == 0x0D ||
      unit == 0xA0 ||
      unit == 0x3000;

  static bool _isLowSurrogate(int unit) => unit >= 0xDC00 && unit <= 0xDFFF;
}
