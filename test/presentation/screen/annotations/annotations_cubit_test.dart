import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/entity/reader/bookmark_entity.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/domain/repository/library/library_repository.dart';
import 'package:lingua_pages/domain/repository/reader/bookmark_repository.dart';
import 'package:lingua_pages/domain/repository/reader/highlight_repository.dart';
import 'package:lingua_pages/presentation/screen/annotations/cubit/annotations_cubit.dart';
import 'package:lingua_pages/presentation/screen/annotations/cubit/annotations_state.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

class _Library extends Mock implements LibraryRepository {}

class _Highlights extends Mock implements HighlightRepository {}

class _Bookmarks extends Mock implements BookmarkRepository {}

void main() {
  late AnnotationsCubit cubit;
  final sea = _book('sea', 'Sea Stories');
  final hills = _book('hills', 'Hill Songs');
  final yellow = _highlight(
    'h1',
    sea.id,
    'Waves at dawn',
    HighlightColor.yellow,
  );
  final noted = _highlight(
    'h2',
    hills.id,
    'Wind over grass',
    HighlightColor.green,
    note: 'Lovely line',
  );
  final gone = _highlight('h3', 'trashed', 'Lost', HighlightColor.pink);
  final mark = BookmarkEntity(
    id: 'b1',
    bookId: sea.id,
    title: 'Chapter 2',
    locator: const TextLocator(offset: 10),
    createdAt: DateTime(2026, 3),
  );

  setUp(() async {
    final library = _Library();
    final highlights = _Highlights();
    final bookmarks = _Bookmarks();
    when(library.getAll).thenAnswer((_) async => [sea, hills]);
    when(highlights.getAll).thenAnswer((_) async => [yellow, noted, gone]);
    when(bookmarks.getAll).thenAnswer((_) async => [mark]);
    cubit = AnnotationsCubit(
      library,
      highlights,
      bookmarks,
      Logger(level: Level.off),
    );
    await cubit.load();
  });

  tearDown(() => cubit.close());

  test('loads annotations of library books only, newest first', () {
    expect(cubit.state.status, AnnotationsStatus.success);
    expect(cubit.state.items.map((item) => item.note.id), ['b1', 'h2', 'h1']);
    expect(cubit.state.books.map((book) => book.title), [
      'Hill Songs',
      'Sea Stories',
    ]);
  });

  test('filters by type, colour, book and search', () {
    cubit.setType(AnnotationType.notes);
    expect(cubit.state.visible.map((item) => item.note.id), ['h2']);

    cubit
      ..setType(AnnotationType.all)
      ..setColor(HighlightColor.yellow);
    expect(cubit.state.visible.map((item) => item.note.id), ['h1']);

    cubit
      ..setColor(null)
      ..setBook(sea.id);
    expect(cubit.state.visible.map((item) => item.note.id), ['b1', 'h1']);

    cubit
      ..setBook(null)
      ..search('LOVELY');
    expect(cubit.state.visible.map((item) => item.note.id), ['h2']);
  });

  test('exports what is shown as Markdown, one section per book', () {
    cubit.setType(AnnotationType.highlights);

    final markdown = cubit.state.toMarkdown();

    expect(markdown, contains('# Hill Songs'));
    expect(markdown, contains('# Sea Stories'));
    expect(markdown, contains('"Wind over grass"'));
    expect(markdown, contains('Note: Lovely line'));
    expect(markdown, isNot(contains('Chapter 2')));
    expect(
      markdown.indexOf('# Hill Songs'),
      lessThan(markdown.indexOf('# Sea Stories')),
    );
  });
}

BookEntity _book(String id, String title) => BookEntity(
  id: id,
  title: title,
  format: DocumentFormat.txt,
  sourceUri: '/$id.txt',
  sourceFileName: '$id.txt',
  contentFingerprint: id,
  addedAt: DateTime(2026),
);

HighlightEntity _highlight(
  String id,
  String bookId,
  String text,
  HighlightColor color, {
  String? note,
}) => HighlightEntity(
  id: id,
  bookId: bookId,
  selectedText: text,
  locator: const TextLocator(offset: 0),
  color: color,
  note: note,
  createdAt: DateTime(2026, 1, id == 'h1' ? 1 : 2),
);
