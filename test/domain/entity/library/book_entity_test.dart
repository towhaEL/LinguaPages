import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';

void main() {
  test('BookEntity exposes started state from progress', () {
    final unread = _book('unread');
    final started = unread.copyWith(progress: 0.25);

    expect(unread.isStarted, isFalse);
    expect(started.isStarted, isTrue);
  });

  test('BookEntity.copyWith preserves identity and updates reading fields', () {
    final original = _book('book-1', title: 'Original');
    final updated = original.copyWith(
      title: 'Updated',
      progress: 0.75,
      readingLocatorJson: '{"type":"epub"}',
    );

    expect(updated.id, original.id);
    expect(updated.title, 'Updated');
    expect(updated.sourceUri, original.sourceUri);
    expect(updated.progress, 0.75);
    expect(updated.readingLocatorJson, '{"type":"epub"}');
  });

  test('BookEntity reads the chapter title from the saved locator', () {
    final book = _book('chapter');

    expect(book.currentChapterTitle, isNull);
    expect(
      book
          .copyWith(readingLocatorJson: '{"href":"c1.xhtml","title":" Ch 1 "}')
          .currentChapterTitle,
      'Ch 1',
    );
    expect(
      book.copyWith(readingLocatorJson: '{"title":"  "}').currentChapterTitle,
      isNull,
    );
    expect(
      book.copyWith(readingLocatorJson: 'not json').currentChapterTitle,
      isNull,
    );
  });

  test('BookEntity derives its shelf from progress unless chosen', () {
    final book = _book('shelf');

    expect(book.readingShelf, isNull);
    expect(book.copyWith(progress: .3).readingShelf, BookShelf.reading);
    expect(book.copyWith(progress: 1).readingShelf, BookShelf.finished);
    expect(
      BookEntity(
        id: 'manual',
        title: 'Manual',
        format: DocumentFormat.epub,
        sourceUri: 'file:///m.epub',
        sourceFileName: 'm.epub',
        contentFingerprint: 'm',
        addedAt: DateTime(2026),
        progress: 1,
        shelf: BookShelf.toRead,
      ).readingShelf,
      BookShelf.toRead,
    );
  });

  test('BookEntity splits its author field into names', () {
    expect(_book('a').authors, isEmpty);
    expect(_book('a').copyWith(author: 'Anna Lind, Ben Ek & Cy Ro').authors, [
      'Anna Lind',
      'Ben Ek',
      'Cy Ro',
    ]);
    expect(_book('a').copyWith(author: 'Ann and Bo').authors, ['Ann', 'Bo']);
  });

  test('BookEntity rejects progress outside the valid range', () {
    expect(
      () => BookEntity(
        id: 'invalid',
        title: 'Invalid',
        format: DocumentFormat.epub,
        sourceUri: 'file:///invalid.epub',
        sourceFileName: 'invalid.epub',
        contentFingerprint: 'invalid',
        addedAt: DateTime(2026),
        progress: 1.1,
      ),
      throwsA(isA<AssertionError>()),
    );
  });
}

BookEntity _book(String id, {String title = 'Book'}) {
  return BookEntity(
    id: id,
    title: title,
    format: DocumentFormat.epub,
    sourceUri: 'file:///$id.epub',
    sourceFileName: '$id.epub',
    contentFingerprint: 'fingerprint-$id',
    addedAt: DateTime(2026),
  );
}
