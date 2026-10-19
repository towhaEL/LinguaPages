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
