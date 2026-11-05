import 'package:lingua_pages/core/document/document_locator.dart';
import 'package:lingua_pages/domain/entity/dictionary/dictionary_entry.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/domain/entity/reader/bookmark_entity.dart';
import 'package:lingua_pages/domain/entity/reader/highlight_entity.dart';
import 'package:lingua_pages/presentation/screen/reader/widgets/notes_sheet.dart';

abstract final class MockDataFixtures {
  static final sampleEpubBook = BookEntity(
    id: 'book-shadow-wind',
    title: 'The Shadow of the Wind',
    author: 'Carlos Ruiz Zafón',
    format: DocumentFormat.epub,
    sourceUri: 'file:///books/shadow_of_the_wind.epub',
    sourceFileName: 'shadow_of_the_wind.epub',
    contentFingerprint: 'fp-shadow-wind',
    addedAt: DateTime(2026, 10, 14),
    progress: 0.64,
    readingLocatorJson: '{"title":"Chapter 7","href":"ch7.xhtml"}',
  );

  static final sampleDuneBook = BookEntity(
    id: 'book-dune',
    title: 'Dune',
    author: 'Frank Herbert',
    format: DocumentFormat.epub,
    sourceUri: 'file:///books/dune.epub',
    sourceFileName: 'dune.epub',
    contentFingerprint: 'fp-dune',
    addedAt: DateTime(2026, 10, 15),
    progress: 0.48,
    readingLocatorJson: '{"title":"Chapter 12","href":"ch12.xhtml"}',
  );

  static final sampleFinishedBook = BookEntity(
    id: 'book-ficciones',
    title: 'Ficciones',
    author: 'Jorge Luis Borges',
    format: DocumentFormat.pdf,
    sourceUri: 'file:///books/ficciones.pdf',
    sourceFileName: 'ficciones.pdf',
    contentFingerprint: 'fp-ficciones',
    addedAt: DateTime(2026, 9, 20),
    progress: 1.0,
    readingLocatorJson: '{"title":"The Library of Babel","page":42}',
  );

  static final sampleTxtBook = BookEntity(
    id: 'book-essays',
    title: 'Essays',
    author: 'Michel de Montaigne',
    format: DocumentFormat.txt,
    sourceUri: 'file:///books/essays.txt',
    sourceFileName: 'essays.txt',
    contentFingerprint: 'fp-essays',
    addedAt: DateTime(2026, 10, 1),
    progress: 0.18,
    readingLocatorJson: '{"title":"Book 1","offset":4800}',
  );

  static final sampleBookWithoutCover = BookEntity(
    id: 'book-no-cover',
    title: 'A Journey Through Quiet Shelves',
    author: 'Anonymous Scholar',
    format: DocumentFormat.epub,
    sourceUri: 'file:///books/quiet_shelves.epub',
    sourceFileName: 'quiet_shelves.epub',
    contentFingerprint: 'fp-no-cover',
    addedAt: DateTime(2026, 11, 1),
    coverPath: null,
  );

  static final sampleBookWithExtremeTitle = BookEntity(
    id: 'book-extreme-title',
    title:
        'The Extremely Elaborate and Exceptionally Long Chronicles of the Undiscovered Library of Ancient Manuscripts ' *
        5,
    author:
        'Professor Bartholomew Alexander Montgomery-Fitzgerald III of the Royal Archival Society',
    format: DocumentFormat.epub,
    sourceUri: 'file:///books/extreme.epub',
    sourceFileName: 'extreme.epub',
    contentFingerprint: 'fp-extreme',
    addedAt: DateTime(2026, 11, 2),
  );

  static List<BookEntity> get sampleLibrary => [
        sampleEpubBook,
        sampleDuneBook,
        sampleFinishedBook,
        sampleTxtBook,
        sampleBookWithoutCover,
      ];

  // Dictionary Fixtures
  static const sampleDictionaryEntryLittoral = DictionaryEntry(
    word: 'littoral',
    phonetic: '/ˈlɪt(ə)rəl/',
    meanings: [
      DictionaryMeaning(
        partOfSpeech: 'adjective',
        definitions: [
          DictionaryDefinition(
            definition:
                'Relating to, or situated on the shore of the sea or a lake.',
            example:
                'The littoral zone teemed with ancient kelp and brine-crusted stones.',
          ),
          DictionaryDefinition(
            definition:
                'Of or pertaining to the biogeographic region between high and low tide marks.',
            example:
                'A delicate littoral ecosystem vulnerable to maritime surges.',
          ),
        ],
        synonyms: ['coastal', 'marine', 'shoreline'],
      ),
      DictionaryMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DictionaryDefinition(
            definition: 'A coastal region; shore zone.',
          ),
        ],
      ),
    ],
    sourceUrls: ['https://en.wiktionary.org/wiki/littoral'],
    license: DictionaryLicense(
      name: 'CC BY-SA 3.0',
      url: 'https://creativecommons.org/licenses/by-sa/3.0/',
    ),
  );

  // Annotations Fixtures
  static final sampleHighlight1 = HighlightEntity(
    id: 'hl-1',
    bookId: 'book-shadow-wind',
    selectedText: 'A secret is only as good as the keeper who guards it.',
    note: 'Echoes the prologue theme of stewardship',
    color: HighlightColor.blue,
    createdAt: DateTime(2026, 10, 18, 14, 30),
    locator: const EpubLocator(
      cfi: '/6/4[ch4]!/4/2',
      locatorJson: '{"locations":{"totalProgression":0.37}}',
    ),
  );

  static final sampleHighlight2 = HighlightEntity(
    id: 'hl-2',
    bookId: 'book-shadow-wind',
    selectedText: 'The mist rose slowly over the silent cobblestones.',
    note: 'Atmospheric sensory description',
    color: HighlightColor.yellow,
    createdAt: DateTime(2026, 10, 17, 19, 15),
    locator: const EpubLocator(
      cfi: '/6/4[ch4]!/4/2',
      locatorJson: '{"locations":{"totalProgression":0.36}}',
    ),
  );

  static final sampleBookmark1 = BookmarkEntity(
    id: 'bm-1',
    bookId: 'book-shadow-wind',
    title: 'Chapter 4: The Silent Harbour',
    createdAt: DateTime(2026, 10, 16, 22, 10),
    locator: const EpubLocator(
      cfi: '/6/4[ch4]!/4/2',
      locatorJson: '{"locations":{"totalProgression":0.35}}',
    ),
  );

  static List<ReaderNote> get sampleReaderNotes => [
        ReaderNote.highlight(sampleHighlight1),
        ReaderNote.highlight(sampleHighlight2),
        ReaderNote.bookmark(sampleBookmark1),
      ];
}
