// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lingua_page_database.dart';

// ignore_for_file: type=lint
class $LibraryBooksTable extends LibraryBooks
    with TableInfo<$LibraryBooksTable, LibraryBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _documentFormatMeta = const VerificationMeta(
    'documentFormat',
  );
  @override
  late final GeneratedColumn<String> documentFormat = GeneratedColumn<String>(
    'document_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUriMeta = const VerificationMeta(
    'sourceUri',
  );
  @override
  late final GeneratedColumn<String> sourceUri = GeneratedColumn<String>(
    'source_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceFileNameMeta = const VerificationMeta(
    'sourceFileName',
  );
  @override
  late final GeneratedColumn<String> sourceFileName = GeneratedColumn<String>(
    'source_file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentFingerprintMeta =
      const VerificationMeta('contentFingerprint');
  @override
  late final GeneratedColumn<String> contentFingerprint =
      GeneratedColumn<String>(
        'content_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
      );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tableOfContentsJsonMeta =
      const VerificationMeta('tableOfContentsJson');
  @override
  late final GeneratedColumn<String> tableOfContentsJson =
      GeneratedColumn<String>(
        'table_of_contents_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _readingLocatorJsonMeta =
      const VerificationMeta('readingLocatorJson');
  @override
  late final GeneratedColumn<String> readingLocatorJson =
      GeneratedColumn<String>(
        'reading_locator_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReadAtMeta = const VerificationMeta(
    'lastReadAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReadAt = GeneratedColumn<DateTime>(
    'last_read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    author,
    documentFormat,
    sourceUri,
    sourceFileName,
    contentFingerprint,
    coverPath,
    languageCode,
    tableOfContentsJson,
    fileSizeBytes,
    progress,
    readingLocatorJson,
    addedAt,
    lastReadAt,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_books';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryBook> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('document_format')) {
      context.handle(
        _documentFormatMeta,
        documentFormat.isAcceptableOrUnknown(
          data['document_format']!,
          _documentFormatMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentFormatMeta);
    }
    if (data.containsKey('source_uri')) {
      context.handle(
        _sourceUriMeta,
        sourceUri.isAcceptableOrUnknown(data['source_uri']!, _sourceUriMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUriMeta);
    }
    if (data.containsKey('source_file_name')) {
      context.handle(
        _sourceFileNameMeta,
        sourceFileName.isAcceptableOrUnknown(
          data['source_file_name']!,
          _sourceFileNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceFileNameMeta);
    }
    if (data.containsKey('content_fingerprint')) {
      context.handle(
        _contentFingerprintMeta,
        contentFingerprint.isAcceptableOrUnknown(
          data['content_fingerprint']!,
          _contentFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentFingerprintMeta);
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    }
    if (data.containsKey('table_of_contents_json')) {
      context.handle(
        _tableOfContentsJsonMeta,
        tableOfContentsJson.isAcceptableOrUnknown(
          data['table_of_contents_json']!,
          _tableOfContentsJsonMeta,
        ),
      );
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fileSizeBytesMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('reading_locator_json')) {
      context.handle(
        _readingLocatorJsonMeta,
        readingLocatorJson.isAcceptableOrUnknown(
          data['reading_locator_json']!,
          _readingLocatorJsonMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('last_read_at')) {
      context.handle(
        _lastReadAtMeta,
        lastReadAt.isAcceptableOrUnknown(
          data['last_read_at']!,
          _lastReadAtMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryBook(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      documentFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_format'],
      )!,
      sourceUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_uri'],
      )!,
      sourceFileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_file_name'],
      )!,
      contentFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_fingerprint'],
      )!,
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_code'],
      ),
      tableOfContentsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_of_contents_json'],
      ),
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      readingLocatorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading_locator_json'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      lastReadAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_read_at'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $LibraryBooksTable createAlias(String alias) {
    return $LibraryBooksTable(attachedDatabase, alias);
  }
}

class LibraryBook extends DataClass implements Insertable<LibraryBook> {
  final String id;
  final String title;
  final String? author;
  final String documentFormat;
  final String sourceUri;
  final String sourceFileName;
  final String contentFingerprint;
  final String? coverPath;
  final String? languageCode;
  final String? tableOfContentsJson;
  final int fileSizeBytes;
  final double progress;
  final String? readingLocatorJson;
  final DateTime addedAt;
  final DateTime? lastReadAt;
  final bool isDeleted;
  const LibraryBook({
    required this.id,
    required this.title,
    this.author,
    required this.documentFormat,
    required this.sourceUri,
    required this.sourceFileName,
    required this.contentFingerprint,
    this.coverPath,
    this.languageCode,
    this.tableOfContentsJson,
    required this.fileSizeBytes,
    required this.progress,
    this.readingLocatorJson,
    required this.addedAt,
    this.lastReadAt,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    map['document_format'] = Variable<String>(documentFormat);
    map['source_uri'] = Variable<String>(sourceUri);
    map['source_file_name'] = Variable<String>(sourceFileName);
    map['content_fingerprint'] = Variable<String>(contentFingerprint);
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    if (!nullToAbsent || languageCode != null) {
      map['language_code'] = Variable<String>(languageCode);
    }
    if (!nullToAbsent || tableOfContentsJson != null) {
      map['table_of_contents_json'] = Variable<String>(tableOfContentsJson);
    }
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || readingLocatorJson != null) {
      map['reading_locator_json'] = Variable<String>(readingLocatorJson);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    if (!nullToAbsent || lastReadAt != null) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  LibraryBooksCompanion toCompanion(bool nullToAbsent) {
    return LibraryBooksCompanion(
      id: Value(id),
      title: Value(title),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      documentFormat: Value(documentFormat),
      sourceUri: Value(sourceUri),
      sourceFileName: Value(sourceFileName),
      contentFingerprint: Value(contentFingerprint),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      languageCode: languageCode == null && nullToAbsent
          ? const Value.absent()
          : Value(languageCode),
      tableOfContentsJson: tableOfContentsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(tableOfContentsJson),
      fileSizeBytes: Value(fileSizeBytes),
      progress: Value(progress),
      readingLocatorJson: readingLocatorJson == null && nullToAbsent
          ? const Value.absent()
          : Value(readingLocatorJson),
      addedAt: Value(addedAt),
      lastReadAt: lastReadAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadAt),
      isDeleted: Value(isDeleted),
    );
  }

  factory LibraryBook.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryBook(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      documentFormat: serializer.fromJson<String>(json['documentFormat']),
      sourceUri: serializer.fromJson<String>(json['sourceUri']),
      sourceFileName: serializer.fromJson<String>(json['sourceFileName']),
      contentFingerprint: serializer.fromJson<String>(
        json['contentFingerprint'],
      ),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      languageCode: serializer.fromJson<String?>(json['languageCode']),
      tableOfContentsJson: serializer.fromJson<String?>(
        json['tableOfContentsJson'],
      ),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      progress: serializer.fromJson<double>(json['progress']),
      readingLocatorJson: serializer.fromJson<String?>(
        json['readingLocatorJson'],
      ),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      lastReadAt: serializer.fromJson<DateTime?>(json['lastReadAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'documentFormat': serializer.toJson<String>(documentFormat),
      'sourceUri': serializer.toJson<String>(sourceUri),
      'sourceFileName': serializer.toJson<String>(sourceFileName),
      'contentFingerprint': serializer.toJson<String>(contentFingerprint),
      'coverPath': serializer.toJson<String?>(coverPath),
      'languageCode': serializer.toJson<String?>(languageCode),
      'tableOfContentsJson': serializer.toJson<String?>(tableOfContentsJson),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'progress': serializer.toJson<double>(progress),
      'readingLocatorJson': serializer.toJson<String?>(readingLocatorJson),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'lastReadAt': serializer.toJson<DateTime?>(lastReadAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  LibraryBook copyWith({
    String? id,
    String? title,
    Value<String?> author = const Value.absent(),
    String? documentFormat,
    String? sourceUri,
    String? sourceFileName,
    String? contentFingerprint,
    Value<String?> coverPath = const Value.absent(),
    Value<String?> languageCode = const Value.absent(),
    Value<String?> tableOfContentsJson = const Value.absent(),
    int? fileSizeBytes,
    double? progress,
    Value<String?> readingLocatorJson = const Value.absent(),
    DateTime? addedAt,
    Value<DateTime?> lastReadAt = const Value.absent(),
    bool? isDeleted,
  }) => LibraryBook(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author.present ? author.value : this.author,
    documentFormat: documentFormat ?? this.documentFormat,
    sourceUri: sourceUri ?? this.sourceUri,
    sourceFileName: sourceFileName ?? this.sourceFileName,
    contentFingerprint: contentFingerprint ?? this.contentFingerprint,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    languageCode: languageCode.present ? languageCode.value : this.languageCode,
    tableOfContentsJson: tableOfContentsJson.present
        ? tableOfContentsJson.value
        : this.tableOfContentsJson,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    progress: progress ?? this.progress,
    readingLocatorJson: readingLocatorJson.present
        ? readingLocatorJson.value
        : this.readingLocatorJson,
    addedAt: addedAt ?? this.addedAt,
    lastReadAt: lastReadAt.present ? lastReadAt.value : this.lastReadAt,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  LibraryBook copyWithCompanion(LibraryBooksCompanion data) {
    return LibraryBook(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      documentFormat: data.documentFormat.present
          ? data.documentFormat.value
          : this.documentFormat,
      sourceUri: data.sourceUri.present ? data.sourceUri.value : this.sourceUri,
      sourceFileName: data.sourceFileName.present
          ? data.sourceFileName.value
          : this.sourceFileName,
      contentFingerprint: data.contentFingerprint.present
          ? data.contentFingerprint.value
          : this.contentFingerprint,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      tableOfContentsJson: data.tableOfContentsJson.present
          ? data.tableOfContentsJson.value
          : this.tableOfContentsJson,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      progress: data.progress.present ? data.progress.value : this.progress,
      readingLocatorJson: data.readingLocatorJson.present
          ? data.readingLocatorJson.value
          : this.readingLocatorJson,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      lastReadAt: data.lastReadAt.present
          ? data.lastReadAt.value
          : this.lastReadAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryBook(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('documentFormat: $documentFormat, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('sourceFileName: $sourceFileName, ')
          ..write('contentFingerprint: $contentFingerprint, ')
          ..write('coverPath: $coverPath, ')
          ..write('languageCode: $languageCode, ')
          ..write('tableOfContentsJson: $tableOfContentsJson, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('progress: $progress, ')
          ..write('readingLocatorJson: $readingLocatorJson, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    author,
    documentFormat,
    sourceUri,
    sourceFileName,
    contentFingerprint,
    coverPath,
    languageCode,
    tableOfContentsJson,
    fileSizeBytes,
    progress,
    readingLocatorJson,
    addedAt,
    lastReadAt,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryBook &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.documentFormat == this.documentFormat &&
          other.sourceUri == this.sourceUri &&
          other.sourceFileName == this.sourceFileName &&
          other.contentFingerprint == this.contentFingerprint &&
          other.coverPath == this.coverPath &&
          other.languageCode == this.languageCode &&
          other.tableOfContentsJson == this.tableOfContentsJson &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.progress == this.progress &&
          other.readingLocatorJson == this.readingLocatorJson &&
          other.addedAt == this.addedAt &&
          other.lastReadAt == this.lastReadAt &&
          other.isDeleted == this.isDeleted);
}

class LibraryBooksCompanion extends UpdateCompanion<LibraryBook> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> author;
  final Value<String> documentFormat;
  final Value<String> sourceUri;
  final Value<String> sourceFileName;
  final Value<String> contentFingerprint;
  final Value<String?> coverPath;
  final Value<String?> languageCode;
  final Value<String?> tableOfContentsJson;
  final Value<int> fileSizeBytes;
  final Value<double> progress;
  final Value<String?> readingLocatorJson;
  final Value<DateTime> addedAt;
  final Value<DateTime?> lastReadAt;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const LibraryBooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.documentFormat = const Value.absent(),
    this.sourceUri = const Value.absent(),
    this.sourceFileName = const Value.absent(),
    this.contentFingerprint = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.tableOfContentsJson = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.progress = const Value.absent(),
    this.readingLocatorJson = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryBooksCompanion.insert({
    required String id,
    required String title,
    this.author = const Value.absent(),
    required String documentFormat,
    required String sourceUri,
    required String sourceFileName,
    required String contentFingerprint,
    this.coverPath = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.tableOfContentsJson = const Value.absent(),
    required int fileSizeBytes,
    this.progress = const Value.absent(),
    this.readingLocatorJson = const Value.absent(),
    required DateTime addedAt,
    this.lastReadAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       documentFormat = Value(documentFormat),
       sourceUri = Value(sourceUri),
       sourceFileName = Value(sourceFileName),
       contentFingerprint = Value(contentFingerprint),
       fileSizeBytes = Value(fileSizeBytes),
       addedAt = Value(addedAt);
  static Insertable<LibraryBook> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? documentFormat,
    Expression<String>? sourceUri,
    Expression<String>? sourceFileName,
    Expression<String>? contentFingerprint,
    Expression<String>? coverPath,
    Expression<String>? languageCode,
    Expression<String>? tableOfContentsJson,
    Expression<int>? fileSizeBytes,
    Expression<double>? progress,
    Expression<String>? readingLocatorJson,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? lastReadAt,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (documentFormat != null) 'document_format': documentFormat,
      if (sourceUri != null) 'source_uri': sourceUri,
      if (sourceFileName != null) 'source_file_name': sourceFileName,
      if (contentFingerprint != null) 'content_fingerprint': contentFingerprint,
      if (coverPath != null) 'cover_path': coverPath,
      if (languageCode != null) 'language_code': languageCode,
      if (tableOfContentsJson != null)
        'table_of_contents_json': tableOfContentsJson,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (progress != null) 'progress': progress,
      if (readingLocatorJson != null)
        'reading_locator_json': readingLocatorJson,
      if (addedAt != null) 'added_at': addedAt,
      if (lastReadAt != null) 'last_read_at': lastReadAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryBooksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? author,
    Value<String>? documentFormat,
    Value<String>? sourceUri,
    Value<String>? sourceFileName,
    Value<String>? contentFingerprint,
    Value<String?>? coverPath,
    Value<String?>? languageCode,
    Value<String?>? tableOfContentsJson,
    Value<int>? fileSizeBytes,
    Value<double>? progress,
    Value<String?>? readingLocatorJson,
    Value<DateTime>? addedAt,
    Value<DateTime?>? lastReadAt,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return LibraryBooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      documentFormat: documentFormat ?? this.documentFormat,
      sourceUri: sourceUri ?? this.sourceUri,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      contentFingerprint: contentFingerprint ?? this.contentFingerprint,
      coverPath: coverPath ?? this.coverPath,
      languageCode: languageCode ?? this.languageCode,
      tableOfContentsJson: tableOfContentsJson ?? this.tableOfContentsJson,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      progress: progress ?? this.progress,
      readingLocatorJson: readingLocatorJson ?? this.readingLocatorJson,
      addedAt: addedAt ?? this.addedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (documentFormat.present) {
      map['document_format'] = Variable<String>(documentFormat.value);
    }
    if (sourceUri.present) {
      map['source_uri'] = Variable<String>(sourceUri.value);
    }
    if (sourceFileName.present) {
      map['source_file_name'] = Variable<String>(sourceFileName.value);
    }
    if (contentFingerprint.present) {
      map['content_fingerprint'] = Variable<String>(contentFingerprint.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (tableOfContentsJson.present) {
      map['table_of_contents_json'] = Variable<String>(
        tableOfContentsJson.value,
      );
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (readingLocatorJson.present) {
      map['reading_locator_json'] = Variable<String>(readingLocatorJson.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (lastReadAt.present) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryBooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('documentFormat: $documentFormat, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('sourceFileName: $sourceFileName, ')
          ..write('contentFingerprint: $contentFingerprint, ')
          ..write('coverPath: $coverPath, ')
          ..write('languageCode: $languageCode, ')
          ..write('tableOfContentsJson: $tableOfContentsJson, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('progress: $progress, ')
          ..write('readingLocatorJson: $readingLocatorJson, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HighlightsTable extends Highlights
    with TableInfo<$HighlightsTable, Highlight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HighlightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES library_books (id)',
    ),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selectedTextMeta = const VerificationMeta(
    'selectedText',
  );
  @override
  late final GeneratedColumn<String> selectedText = GeneratedColumn<String>(
    'selected_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locatorJsonMeta = const VerificationMeta(
    'locatorJson',
  );
  @override
  late final GeneratedColumn<String> locatorJson = GeneratedColumn<String>(
    'locator_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    color,
    selectedText,
    locatorJson,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'highlights';
  @override
  VerificationContext validateIntegrity(
    Insertable<Highlight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('selected_text')) {
      context.handle(
        _selectedTextMeta,
        selectedText.isAcceptableOrUnknown(
          data['selected_text']!,
          _selectedTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selectedTextMeta);
    }
    if (data.containsKey('locator_json')) {
      context.handle(
        _locatorJsonMeta,
        locatorJson.isAcceptableOrUnknown(
          data['locator_json']!,
          _locatorJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locatorJsonMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Highlight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Highlight(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      selectedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_text'],
      )!,
      locatorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locator_json'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $HighlightsTable createAlias(String alias) {
    return $HighlightsTable(attachedDatabase, alias);
  }
}

class Highlight extends DataClass implements Insertable<Highlight> {
  final String id;
  final String bookId;
  final String color;
  final String selectedText;
  final String locatorJson;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const Highlight({
    required this.id,
    required this.bookId,
    required this.color,
    required this.selectedText,
    required this.locatorJson,
    this.note,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['color'] = Variable<String>(color);
    map['selected_text'] = Variable<String>(selectedText);
    map['locator_json'] = Variable<String>(locatorJson);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  HighlightsCompanion toCompanion(bool nullToAbsent) {
    return HighlightsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      color: Value(color),
      selectedText: Value(selectedText),
      locatorJson: Value(locatorJson),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Highlight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Highlight(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      color: serializer.fromJson<String>(json['color']),
      selectedText: serializer.fromJson<String>(json['selectedText']),
      locatorJson: serializer.fromJson<String>(json['locatorJson']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'color': serializer.toJson<String>(color),
      'selectedText': serializer.toJson<String>(selectedText),
      'locatorJson': serializer.toJson<String>(locatorJson),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Highlight copyWith({
    String? id,
    String? bookId,
    String? color,
    String? selectedText,
    String? locatorJson,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => Highlight(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    color: color ?? this.color,
    selectedText: selectedText ?? this.selectedText,
    locatorJson: locatorJson ?? this.locatorJson,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Highlight copyWithCompanion(HighlightsCompanion data) {
    return Highlight(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      color: data.color.present ? data.color.value : this.color,
      selectedText: data.selectedText.present
          ? data.selectedText.value
          : this.selectedText,
      locatorJson: data.locatorJson.present
          ? data.locatorJson.value
          : this.locatorJson,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Highlight(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('color: $color, ')
          ..write('selectedText: $selectedText, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    color,
    selectedText,
    locatorJson,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Highlight &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.color == this.color &&
          other.selectedText == this.selectedText &&
          other.locatorJson == this.locatorJson &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HighlightsCompanion extends UpdateCompanion<Highlight> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String> color;
  final Value<String> selectedText;
  final Value<String> locatorJson;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const HighlightsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.color = const Value.absent(),
    this.selectedText = const Value.absent(),
    this.locatorJson = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HighlightsCompanion.insert({
    required String id,
    required String bookId,
    required String color,
    required String selectedText,
    required String locatorJson,
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       color = Value(color),
       selectedText = Value(selectedText),
       locatorJson = Value(locatorJson),
       createdAt = Value(createdAt);
  static Insertable<Highlight> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? color,
    Expression<String>? selectedText,
    Expression<String>? locatorJson,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (color != null) 'color': color,
      if (selectedText != null) 'selected_text': selectedText,
      if (locatorJson != null) 'locator_json': locatorJson,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HighlightsCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<String>? color,
    Value<String>? selectedText,
    Value<String>? locatorJson,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return HighlightsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      color: color ?? this.color,
      selectedText: selectedText ?? this.selectedText,
      locatorJson: locatorJson ?? this.locatorJson,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (selectedText.present) {
      map['selected_text'] = Variable<String>(selectedText.value);
    }
    if (locatorJson.present) {
      map['locator_json'] = Variable<String>(locatorJson.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HighlightsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('color: $color, ')
          ..write('selectedText: $selectedText, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES library_books (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locatorJsonMeta = const VerificationMeta(
    'locatorJson',
  );
  @override
  late final GeneratedColumn<String> locatorJson = GeneratedColumn<String>(
    'locator_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    title,
    locatorJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('locator_json')) {
      context.handle(
        _locatorJsonMeta,
        locatorJson.isAcceptableOrUnknown(
          data['locator_json']!,
          _locatorJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locatorJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      locatorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locator_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final String id;
  final String bookId;
  final String title;
  final String locatorJson;
  final DateTime createdAt;
  const Bookmark({
    required this.id,
    required this.bookId,
    required this.title,
    required this.locatorJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['title'] = Variable<String>(title);
    map['locator_json'] = Variable<String>(locatorJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      bookId: Value(bookId),
      title: Value(title),
      locatorJson: Value(locatorJson),
      createdAt: Value(createdAt),
    );
  }

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      title: serializer.fromJson<String>(json['title']),
      locatorJson: serializer.fromJson<String>(json['locatorJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'title': serializer.toJson<String>(title),
      'locatorJson': serializer.toJson<String>(locatorJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Bookmark copyWith({
    String? id,
    String? bookId,
    String? title,
    String? locatorJson,
    DateTime? createdAt,
  }) => Bookmark(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    title: title ?? this.title,
    locatorJson: locatorJson ?? this.locatorJson,
    createdAt: createdAt ?? this.createdAt,
  );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      title: data.title.present ? data.title.value : this.title,
      locatorJson: data.locatorJson.present
          ? data.locatorJson.value
          : this.locatorJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('title: $title, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, title, locatorJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.title == this.title &&
          other.locatorJson == this.locatorJson &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String> title;
  final Value<String> locatorJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.title = const Value.absent(),
    this.locatorJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required String id,
    required String bookId,
    required String title,
    required String locatorJson,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       title = Value(title),
       locatorJson = Value(locatorJson),
       createdAt = Value(createdAt);
  static Insertable<Bookmark> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? title,
    Expression<String>? locatorJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (title != null) 'title': title,
      if (locatorJson != null) 'locator_json': locatorJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<String>? title,
    Value<String>? locatorJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BookmarksCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      locatorJson: locatorJson ?? this.locatorJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (locatorJson.present) {
      map['locator_json'] = Variable<String>(locatorJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('title: $title, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingSessionsTable extends ReadingSessions
    with TableInfo<$ReadingSessionsTable, ReadingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES library_books (id)',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startProgressMeta = const VerificationMeta(
    'startProgress',
  );
  @override
  late final GeneratedColumn<double> startProgress = GeneratedColumn<double>(
    'start_progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endProgressMeta = const VerificationMeta(
    'endProgress',
  );
  @override
  late final GeneratedColumn<double> endProgress = GeneratedColumn<double>(
    'end_progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    startedAt,
    endedAt,
    startProgress,
    endProgress,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('start_progress')) {
      context.handle(
        _startProgressMeta,
        startProgress.isAcceptableOrUnknown(
          data['start_progress']!,
          _startProgressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startProgressMeta);
    }
    if (data.containsKey('end_progress')) {
      context.handle(
        _endProgressMeta,
        endProgress.isAcceptableOrUnknown(
          data['end_progress']!,
          _endProgressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endProgressMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      )!,
      startProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_progress'],
      )!,
      endProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_progress'],
      )!,
    );
  }

  @override
  $ReadingSessionsTable createAlias(String alias) {
    return $ReadingSessionsTable(attachedDatabase, alias);
  }
}

class ReadingSession extends DataClass implements Insertable<ReadingSession> {
  final String id;
  final String bookId;
  final DateTime startedAt;
  final DateTime endedAt;
  final double startProgress;
  final double endProgress;
  const ReadingSession({
    required this.id,
    required this.bookId,
    required this.startedAt,
    required this.endedAt,
    required this.startProgress,
    required this.endProgress,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['ended_at'] = Variable<DateTime>(endedAt);
    map['start_progress'] = Variable<double>(startProgress);
    map['end_progress'] = Variable<double>(endProgress);
    return map;
  }

  ReadingSessionsCompanion toCompanion(bool nullToAbsent) {
    return ReadingSessionsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      startProgress: Value(startProgress),
      endProgress: Value(endProgress),
    );
  }

  factory ReadingSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingSession(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      startProgress: serializer.fromJson<double>(json['startProgress']),
      endProgress: serializer.fromJson<double>(json['endProgress']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'startProgress': serializer.toJson<double>(startProgress),
      'endProgress': serializer.toJson<double>(endProgress),
    };
  }

  ReadingSession copyWith({
    String? id,
    String? bookId,
    DateTime? startedAt,
    DateTime? endedAt,
    double? startProgress,
    double? endProgress,
  }) => ReadingSession(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    startProgress: startProgress ?? this.startProgress,
    endProgress: endProgress ?? this.endProgress,
  );
  ReadingSession copyWithCompanion(ReadingSessionsCompanion data) {
    return ReadingSession(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      startProgress: data.startProgress.present
          ? data.startProgress.value
          : this.startProgress,
      endProgress: data.endProgress.present
          ? data.endProgress.value
          : this.endProgress,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSession(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('startProgress: $startProgress, ')
          ..write('endProgress: $endProgress')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookId, startedAt, endedAt, startProgress, endProgress);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingSession &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.startProgress == this.startProgress &&
          other.endProgress == this.endProgress);
}

class ReadingSessionsCompanion extends UpdateCompanion<ReadingSession> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<DateTime> startedAt;
  final Value<DateTime> endedAt;
  final Value<double> startProgress;
  final Value<double> endProgress;
  final Value<int> rowid;
  const ReadingSessionsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.startProgress = const Value.absent(),
    this.endProgress = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingSessionsCompanion.insert({
    required String id,
    required String bookId,
    required DateTime startedAt,
    required DateTime endedAt,
    required double startProgress,
    required double endProgress,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       startProgress = Value(startProgress),
       endProgress = Value(endProgress);
  static Insertable<ReadingSession> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? startProgress,
    Expression<double>? endProgress,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (startProgress != null) 'start_progress': startProgress,
      if (endProgress != null) 'end_progress': endProgress,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<DateTime>? startedAt,
    Value<DateTime>? endedAt,
    Value<double>? startProgress,
    Value<double>? endProgress,
    Value<int>? rowid,
  }) {
    return ReadingSessionsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      startProgress: startProgress ?? this.startProgress,
      endProgress: endProgress ?? this.endProgress,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (startProgress.present) {
      map['start_progress'] = Variable<double>(startProgress.value);
    }
    if (endProgress.present) {
      map['end_progress'] = Variable<double>(endProgress.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('startProgress: $startProgress, ')
          ..write('endProgress: $endProgress, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VocabItemsTable extends VocabItems
    with TableInfo<$VocabItemsTable, VocabItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VocabItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lemmaMeta = const VerificationMeta('lemma');
  @override
  late final GeneratedColumn<String> lemma = GeneratedColumn<String>(
    'lemma',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceSentenceMeta = const VerificationMeta(
    'sourceSentence',
  );
  @override
  late final GeneratedColumn<String> sourceSentence = GeneratedColumn<String>(
    'source_sentence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES library_books (id)',
    ),
  );
  static const VerificationMeta _locatorJsonMeta = const VerificationMeta(
    'locatorJson',
  );
  @override
  late final GeneratedColumn<String> locatorJson = GeneratedColumn<String>(
    'locator_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceLanguageMeta = const VerificationMeta(
    'sourceLanguage',
  );
  @override
  late final GeneratedColumn<String> sourceLanguage = GeneratedColumn<String>(
    'source_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetLanguageMeta = const VerificationMeta(
    'targetLanguage',
  );
  @override
  late final GeneratedColumn<String> targetLanguage = GeneratedColumn<String>(
    'target_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    word,
    lemma,
    sourceSentence,
    translation,
    bookId,
    locatorJson,
    sourceLanguage,
    targetLanguage,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vocab_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<VocabItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('lemma')) {
      context.handle(
        _lemmaMeta,
        lemma.isAcceptableOrUnknown(data['lemma']!, _lemmaMeta),
      );
    } else if (isInserting) {
      context.missing(_lemmaMeta);
    }
    if (data.containsKey('source_sentence')) {
      context.handle(
        _sourceSentenceMeta,
        sourceSentence.isAcceptableOrUnknown(
          data['source_sentence']!,
          _sourceSentenceMeta,
        ),
      );
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    }
    if (data.containsKey('locator_json')) {
      context.handle(
        _locatorJsonMeta,
        locatorJson.isAcceptableOrUnknown(
          data['locator_json']!,
          _locatorJsonMeta,
        ),
      );
    }
    if (data.containsKey('source_language')) {
      context.handle(
        _sourceLanguageMeta,
        sourceLanguage.isAcceptableOrUnknown(
          data['source_language']!,
          _sourceLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceLanguageMeta);
    }
    if (data.containsKey('target_language')) {
      context.handle(
        _targetLanguageMeta,
        targetLanguage.isAcceptableOrUnknown(
          data['target_language']!,
          _targetLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetLanguageMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VocabItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VocabItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      lemma: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lemma'],
      )!,
      sourceSentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_sentence'],
      )!,
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      ),
      locatorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locator_json'],
      ),
      sourceLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_language'],
      )!,
      targetLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_language'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VocabItemsTable createAlias(String alias) {
    return $VocabItemsTable(attachedDatabase, alias);
  }
}

class VocabItem extends DataClass implements Insertable<VocabItem> {
  final String id;
  final String word;
  final String lemma;
  final String sourceSentence;
  final String translation;
  final String? bookId;
  final String? locatorJson;
  final String sourceLanguage;
  final String targetLanguage;
  final String? notes;
  final DateTime createdAt;
  const VocabItem({
    required this.id,
    required this.word,
    required this.lemma,
    required this.sourceSentence,
    required this.translation,
    this.bookId,
    this.locatorJson,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['word'] = Variable<String>(word);
    map['lemma'] = Variable<String>(lemma);
    map['source_sentence'] = Variable<String>(sourceSentence);
    map['translation'] = Variable<String>(translation);
    if (!nullToAbsent || bookId != null) {
      map['book_id'] = Variable<String>(bookId);
    }
    if (!nullToAbsent || locatorJson != null) {
      map['locator_json'] = Variable<String>(locatorJson);
    }
    map['source_language'] = Variable<String>(sourceLanguage);
    map['target_language'] = Variable<String>(targetLanguage);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VocabItemsCompanion toCompanion(bool nullToAbsent) {
    return VocabItemsCompanion(
      id: Value(id),
      word: Value(word),
      lemma: Value(lemma),
      sourceSentence: Value(sourceSentence),
      translation: Value(translation),
      bookId: bookId == null && nullToAbsent
          ? const Value.absent()
          : Value(bookId),
      locatorJson: locatorJson == null && nullToAbsent
          ? const Value.absent()
          : Value(locatorJson),
      sourceLanguage: Value(sourceLanguage),
      targetLanguage: Value(targetLanguage),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory VocabItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VocabItem(
      id: serializer.fromJson<String>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      lemma: serializer.fromJson<String>(json['lemma']),
      sourceSentence: serializer.fromJson<String>(json['sourceSentence']),
      translation: serializer.fromJson<String>(json['translation']),
      bookId: serializer.fromJson<String?>(json['bookId']),
      locatorJson: serializer.fromJson<String?>(json['locatorJson']),
      sourceLanguage: serializer.fromJson<String>(json['sourceLanguage']),
      targetLanguage: serializer.fromJson<String>(json['targetLanguage']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'word': serializer.toJson<String>(word),
      'lemma': serializer.toJson<String>(lemma),
      'sourceSentence': serializer.toJson<String>(sourceSentence),
      'translation': serializer.toJson<String>(translation),
      'bookId': serializer.toJson<String?>(bookId),
      'locatorJson': serializer.toJson<String?>(locatorJson),
      'sourceLanguage': serializer.toJson<String>(sourceLanguage),
      'targetLanguage': serializer.toJson<String>(targetLanguage),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VocabItem copyWith({
    String? id,
    String? word,
    String? lemma,
    String? sourceSentence,
    String? translation,
    Value<String?> bookId = const Value.absent(),
    Value<String?> locatorJson = const Value.absent(),
    String? sourceLanguage,
    String? targetLanguage,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => VocabItem(
    id: id ?? this.id,
    word: word ?? this.word,
    lemma: lemma ?? this.lemma,
    sourceSentence: sourceSentence ?? this.sourceSentence,
    translation: translation ?? this.translation,
    bookId: bookId.present ? bookId.value : this.bookId,
    locatorJson: locatorJson.present ? locatorJson.value : this.locatorJson,
    sourceLanguage: sourceLanguage ?? this.sourceLanguage,
    targetLanguage: targetLanguage ?? this.targetLanguage,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  VocabItem copyWithCompanion(VocabItemsCompanion data) {
    return VocabItem(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      lemma: data.lemma.present ? data.lemma.value : this.lemma,
      sourceSentence: data.sourceSentence.present
          ? data.sourceSentence.value
          : this.sourceSentence,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      locatorJson: data.locatorJson.present
          ? data.locatorJson.value
          : this.locatorJson,
      sourceLanguage: data.sourceLanguage.present
          ? data.sourceLanguage.value
          : this.sourceLanguage,
      targetLanguage: data.targetLanguage.present
          ? data.targetLanguage.value
          : this.targetLanguage,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VocabItem(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('lemma: $lemma, ')
          ..write('sourceSentence: $sourceSentence, ')
          ..write('translation: $translation, ')
          ..write('bookId: $bookId, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('sourceLanguage: $sourceLanguage, ')
          ..write('targetLanguage: $targetLanguage, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    word,
    lemma,
    sourceSentence,
    translation,
    bookId,
    locatorJson,
    sourceLanguage,
    targetLanguage,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VocabItem &&
          other.id == this.id &&
          other.word == this.word &&
          other.lemma == this.lemma &&
          other.sourceSentence == this.sourceSentence &&
          other.translation == this.translation &&
          other.bookId == this.bookId &&
          other.locatorJson == this.locatorJson &&
          other.sourceLanguage == this.sourceLanguage &&
          other.targetLanguage == this.targetLanguage &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class VocabItemsCompanion extends UpdateCompanion<VocabItem> {
  final Value<String> id;
  final Value<String> word;
  final Value<String> lemma;
  final Value<String> sourceSentence;
  final Value<String> translation;
  final Value<String?> bookId;
  final Value<String?> locatorJson;
  final Value<String> sourceLanguage;
  final Value<String> targetLanguage;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VocabItemsCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.lemma = const Value.absent(),
    this.sourceSentence = const Value.absent(),
    this.translation = const Value.absent(),
    this.bookId = const Value.absent(),
    this.locatorJson = const Value.absent(),
    this.sourceLanguage = const Value.absent(),
    this.targetLanguage = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VocabItemsCompanion.insert({
    required String id,
    required String word,
    required String lemma,
    this.sourceSentence = const Value.absent(),
    required String translation,
    this.bookId = const Value.absent(),
    this.locatorJson = const Value.absent(),
    required String sourceLanguage,
    required String targetLanguage,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       word = Value(word),
       lemma = Value(lemma),
       translation = Value(translation),
       sourceLanguage = Value(sourceLanguage),
       targetLanguage = Value(targetLanguage),
       createdAt = Value(createdAt);
  static Insertable<VocabItem> custom({
    Expression<String>? id,
    Expression<String>? word,
    Expression<String>? lemma,
    Expression<String>? sourceSentence,
    Expression<String>? translation,
    Expression<String>? bookId,
    Expression<String>? locatorJson,
    Expression<String>? sourceLanguage,
    Expression<String>? targetLanguage,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (lemma != null) 'lemma': lemma,
      if (sourceSentence != null) 'source_sentence': sourceSentence,
      if (translation != null) 'translation': translation,
      if (bookId != null) 'book_id': bookId,
      if (locatorJson != null) 'locator_json': locatorJson,
      if (sourceLanguage != null) 'source_language': sourceLanguage,
      if (targetLanguage != null) 'target_language': targetLanguage,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VocabItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? word,
    Value<String>? lemma,
    Value<String>? sourceSentence,
    Value<String>? translation,
    Value<String?>? bookId,
    Value<String?>? locatorJson,
    Value<String>? sourceLanguage,
    Value<String>? targetLanguage,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VocabItemsCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      lemma: lemma ?? this.lemma,
      sourceSentence: sourceSentence ?? this.sourceSentence,
      translation: translation ?? this.translation,
      bookId: bookId ?? this.bookId,
      locatorJson: locatorJson ?? this.locatorJson,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (lemma.present) {
      map['lemma'] = Variable<String>(lemma.value);
    }
    if (sourceSentence.present) {
      map['source_sentence'] = Variable<String>(sourceSentence.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (locatorJson.present) {
      map['locator_json'] = Variable<String>(locatorJson.value);
    }
    if (sourceLanguage.present) {
      map['source_language'] = Variable<String>(sourceLanguage.value);
    }
    if (targetLanguage.present) {
      map['target_language'] = Variable<String>(targetLanguage.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VocabItemsCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('lemma: $lemma, ')
          ..write('sourceSentence: $sourceSentence, ')
          ..write('translation: $translation, ')
          ..write('bookId: $bookId, ')
          ..write('locatorJson: $locatorJson, ')
          ..write('sourceLanguage: $sourceLanguage, ')
          ..write('targetLanguage: $targetLanguage, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewCardsTable extends ReviewCards
    with TableInfo<$ReviewCardsTable, ReviewCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vocabItemIdMeta = const VerificationMeta(
    'vocabItemId',
  );
  @override
  late final GeneratedColumn<String> vocabItemId = GeneratedColumn<String>(
    'vocab_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vocab_items (id)',
    ),
  );
  static const VerificationMeta _intervalMeta = const VerificationMeta(
    'interval',
  );
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextReviewDateMeta = const VerificationMeta(
    'nextReviewDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextReviewDate =
      GeneratedColumn<DateTime>(
        'next_review_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>(
        'last_reviewed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('newCard'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vocabItemId,
    interval,
    easeFactor,
    repetitions,
    nextReviewDate,
    lastReviewedAt,
    state,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vocab_item_id')) {
      context.handle(
        _vocabItemIdMeta,
        vocabItemId.isAcceptableOrUnknown(
          data['vocab_item_id']!,
          _vocabItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vocabItemIdMeta);
    }
    if (data.containsKey('interval')) {
      context.handle(
        _intervalMeta,
        interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta),
      );
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('next_review_date')) {
      context.handle(
        _nextReviewDateMeta,
        nextReviewDate.isAcceptableOrUnknown(
          data['next_review_date']!,
          _nextReviewDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextReviewDateMeta);
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vocabItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vocab_item_id'],
      )!,
      interval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval'],
      )!,
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
      nextReviewDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_review_date'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReviewCardsTable createAlias(String alias) {
    return $ReviewCardsTable(attachedDatabase, alias);
  }
}

class ReviewCard extends DataClass implements Insertable<ReviewCard> {
  final String id;
  final String vocabItemId;
  final int interval;
  final double easeFactor;
  final int repetitions;
  final DateTime nextReviewDate;
  final DateTime? lastReviewedAt;
  final String state;
  final DateTime createdAt;
  const ReviewCard({
    required this.id,
    required this.vocabItemId,
    required this.interval,
    required this.easeFactor,
    required this.repetitions,
    required this.nextReviewDate,
    this.lastReviewedAt,
    required this.state,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vocab_item_id'] = Variable<String>(vocabItemId);
    map['interval'] = Variable<int>(interval);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['repetitions'] = Variable<int>(repetitions);
    map['next_review_date'] = Variable<DateTime>(nextReviewDate);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    map['state'] = Variable<String>(state);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReviewCardsCompanion toCompanion(bool nullToAbsent) {
    return ReviewCardsCompanion(
      id: Value(id),
      vocabItemId: Value(vocabItemId),
      interval: Value(interval),
      easeFactor: Value(easeFactor),
      repetitions: Value(repetitions),
      nextReviewDate: Value(nextReviewDate),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      state: Value(state),
      createdAt: Value(createdAt),
    );
  }

  factory ReviewCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewCard(
      id: serializer.fromJson<String>(json['id']),
      vocabItemId: serializer.fromJson<String>(json['vocabItemId']),
      interval: serializer.fromJson<int>(json['interval']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      nextReviewDate: serializer.fromJson<DateTime>(json['nextReviewDate']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      state: serializer.fromJson<String>(json['state']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vocabItemId': serializer.toJson<String>(vocabItemId),
      'interval': serializer.toJson<int>(interval),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'repetitions': serializer.toJson<int>(repetitions),
      'nextReviewDate': serializer.toJson<DateTime>(nextReviewDate),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'state': serializer.toJson<String>(state),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReviewCard copyWith({
    String? id,
    String? vocabItemId,
    int? interval,
    double? easeFactor,
    int? repetitions,
    DateTime? nextReviewDate,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    String? state,
    DateTime? createdAt,
  }) => ReviewCard(
    id: id ?? this.id,
    vocabItemId: vocabItemId ?? this.vocabItemId,
    interval: interval ?? this.interval,
    easeFactor: easeFactor ?? this.easeFactor,
    repetitions: repetitions ?? this.repetitions,
    nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    state: state ?? this.state,
    createdAt: createdAt ?? this.createdAt,
  );
  ReviewCard copyWithCompanion(ReviewCardsCompanion data) {
    return ReviewCard(
      id: data.id.present ? data.id.value : this.id,
      vocabItemId: data.vocabItemId.present
          ? data.vocabItemId.value
          : this.vocabItemId,
      interval: data.interval.present ? data.interval.value : this.interval,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      nextReviewDate: data.nextReviewDate.present
          ? data.nextReviewDate.value
          : this.nextReviewDate,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      state: data.state.present ? data.state.value : this.state,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewCard(')
          ..write('id: $id, ')
          ..write('vocabItemId: $vocabItemId, ')
          ..write('interval: $interval, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('repetitions: $repetitions, ')
          ..write('nextReviewDate: $nextReviewDate, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vocabItemId,
    interval,
    easeFactor,
    repetitions,
    nextReviewDate,
    lastReviewedAt,
    state,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewCard &&
          other.id == this.id &&
          other.vocabItemId == this.vocabItemId &&
          other.interval == this.interval &&
          other.easeFactor == this.easeFactor &&
          other.repetitions == this.repetitions &&
          other.nextReviewDate == this.nextReviewDate &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.state == this.state &&
          other.createdAt == this.createdAt);
}

class ReviewCardsCompanion extends UpdateCompanion<ReviewCard> {
  final Value<String> id;
  final Value<String> vocabItemId;
  final Value<int> interval;
  final Value<double> easeFactor;
  final Value<int> repetitions;
  final Value<DateTime> nextReviewDate;
  final Value<DateTime?> lastReviewedAt;
  final Value<String> state;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReviewCardsCompanion({
    this.id = const Value.absent(),
    this.vocabItemId = const Value.absent(),
    this.interval = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.nextReviewDate = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.state = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewCardsCompanion.insert({
    required String id,
    required String vocabItemId,
    this.interval = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.repetitions = const Value.absent(),
    required DateTime nextReviewDate,
    this.lastReviewedAt = const Value.absent(),
    this.state = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vocabItemId = Value(vocabItemId),
       nextReviewDate = Value(nextReviewDate),
       createdAt = Value(createdAt);
  static Insertable<ReviewCard> custom({
    Expression<String>? id,
    Expression<String>? vocabItemId,
    Expression<int>? interval,
    Expression<double>? easeFactor,
    Expression<int>? repetitions,
    Expression<DateTime>? nextReviewDate,
    Expression<DateTime>? lastReviewedAt,
    Expression<String>? state,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vocabItemId != null) 'vocab_item_id': vocabItemId,
      if (interval != null) 'interval': interval,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (repetitions != null) 'repetitions': repetitions,
      if (nextReviewDate != null) 'next_review_date': nextReviewDate,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (state != null) 'state': state,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewCardsCompanion copyWith({
    Value<String>? id,
    Value<String>? vocabItemId,
    Value<int>? interval,
    Value<double>? easeFactor,
    Value<int>? repetitions,
    Value<DateTime>? nextReviewDate,
    Value<DateTime?>? lastReviewedAt,
    Value<String>? state,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ReviewCardsCompanion(
      id: id ?? this.id,
      vocabItemId: vocabItemId ?? this.vocabItemId,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vocabItemId.present) {
      map['vocab_item_id'] = Variable<String>(vocabItemId.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (nextReviewDate.present) {
      map['next_review_date'] = Variable<DateTime>(nextReviewDate.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewCardsCompanion(')
          ..write('id: $id, ')
          ..write('vocabItemId: $vocabItemId, ')
          ..write('interval: $interval, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('repetitions: $repetitions, ')
          ..write('nextReviewDate: $nextReviewDate, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LinguaPageDatabase extends GeneratedDatabase {
  _$LinguaPageDatabase(QueryExecutor e) : super(e);
  $LinguaPageDatabaseManager get managers => $LinguaPageDatabaseManager(this);
  late final $LibraryBooksTable libraryBooks = $LibraryBooksTable(this);
  late final $HighlightsTable highlights = $HighlightsTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $ReadingSessionsTable readingSessions = $ReadingSessionsTable(
    this,
  );
  late final $VocabItemsTable vocabItems = $VocabItemsTable(this);
  late final $ReviewCardsTable reviewCards = $ReviewCardsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    libraryBooks,
    highlights,
    bookmarks,
    readingSessions,
    vocabItems,
    reviewCards,
    appSettings,
  ];
}

typedef $$LibraryBooksTableCreateCompanionBuilder =
    LibraryBooksCompanion Function({
      required String id,
      required String title,
      Value<String?> author,
      required String documentFormat,
      required String sourceUri,
      required String sourceFileName,
      required String contentFingerprint,
      Value<String?> coverPath,
      Value<String?> languageCode,
      Value<String?> tableOfContentsJson,
      required int fileSizeBytes,
      Value<double> progress,
      Value<String?> readingLocatorJson,
      required DateTime addedAt,
      Value<DateTime?> lastReadAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$LibraryBooksTableUpdateCompanionBuilder =
    LibraryBooksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> author,
      Value<String> documentFormat,
      Value<String> sourceUri,
      Value<String> sourceFileName,
      Value<String> contentFingerprint,
      Value<String?> coverPath,
      Value<String?> languageCode,
      Value<String?> tableOfContentsJson,
      Value<int> fileSizeBytes,
      Value<double> progress,
      Value<String?> readingLocatorJson,
      Value<DateTime> addedAt,
      Value<DateTime?> lastReadAt,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

final class $$LibraryBooksTableReferences
    extends
        BaseReferences<_$LinguaPageDatabase, $LibraryBooksTable, LibraryBook> {
  $$LibraryBooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HighlightsTable, List<Highlight>>
  _highlightsRefsTable(_$LinguaPageDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.highlights,
        aliasName: 'library_books__id__highlights__book_id',
      );

  $$HighlightsTableProcessedTableManager get highlightsRefs {
    final manager = $$HighlightsTableTableManager(
      $_db,
      $_db.highlights,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_highlightsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookmarksTable, List<Bookmark>>
  _bookmarksRefsTable(_$LinguaPageDatabase db) => MultiTypedResultKey.fromTable(
    db.bookmarks,
    aliasName: 'library_books__id__bookmarks__book_id',
  );

  $$BookmarksTableProcessedTableManager get bookmarksRefs {
    final manager = $$BookmarksTableTableManager(
      $_db,
      $_db.bookmarks,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookmarksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadingSessionsTable, List<ReadingSession>>
  _readingSessionsRefsTable(_$LinguaPageDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.readingSessions,
        aliasName: 'library_books__id__reading_sessions__book_id',
      );

  $$ReadingSessionsTableProcessedTableManager get readingSessionsRefs {
    final manager = $$ReadingSessionsTableTableManager(
      $_db,
      $_db.readingSessions,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _readingSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VocabItemsTable, List<VocabItem>>
  _vocabItemsRefsTable(_$LinguaPageDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.vocabItems,
        aliasName: 'library_books__id__vocab_items__book_id',
      );

  $$VocabItemsTableProcessedTableManager get vocabItemsRefs {
    final manager = $$VocabItemsTableTableManager(
      $_db,
      $_db.vocabItems,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vocabItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LibraryBooksTableFilterComposer
    extends Composer<_$LinguaPageDatabase, $LibraryBooksTable> {
  $$LibraryBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentFormat => $composableBuilder(
    column: $table.documentFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUri => $composableBuilder(
    column: $table.sourceUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFileName => $composableBuilder(
    column: $table.sourceFileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentFingerprint => $composableBuilder(
    column: $table.contentFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tableOfContentsJson => $composableBuilder(
    column: $table.tableOfContentsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readingLocatorJson => $composableBuilder(
    column: $table.readingLocatorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> highlightsRefs(
    Expression<bool> Function($$HighlightsTableFilterComposer f) f,
  ) {
    final $$HighlightsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.highlights,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HighlightsTableFilterComposer(
            $db: $db,
            $table: $db.highlights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookmarksRefs(
    Expression<bool> Function($$BookmarksTableFilterComposer f) f,
  ) {
    final $$BookmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableFilterComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingSessionsRefs(
    Expression<bool> Function($$ReadingSessionsTableFilterComposer f) f,
  ) {
    final $$ReadingSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingSessions,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingSessionsTableFilterComposer(
            $db: $db,
            $table: $db.readingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vocabItemsRefs(
    Expression<bool> Function($$VocabItemsTableFilterComposer f) f,
  ) {
    final $$VocabItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vocabItems,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabItemsTableFilterComposer(
            $db: $db,
            $table: $db.vocabItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibraryBooksTableOrderingComposer
    extends Composer<_$LinguaPageDatabase, $LibraryBooksTable> {
  $$LibraryBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentFormat => $composableBuilder(
    column: $table.documentFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUri => $composableBuilder(
    column: $table.sourceUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFileName => $composableBuilder(
    column: $table.sourceFileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentFingerprint => $composableBuilder(
    column: $table.contentFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tableOfContentsJson => $composableBuilder(
    column: $table.tableOfContentsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readingLocatorJson => $composableBuilder(
    column: $table.readingLocatorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryBooksTableAnnotationComposer
    extends Composer<_$LinguaPageDatabase, $LibraryBooksTable> {
  $$LibraryBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get documentFormat => $composableBuilder(
    column: $table.documentFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUri =>
      $composableBuilder(column: $table.sourceUri, builder: (column) => column);

  GeneratedColumn<String> get sourceFileName => $composableBuilder(
    column: $table.sourceFileName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentFingerprint => $composableBuilder(
    column: $table.contentFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tableOfContentsJson => $composableBuilder(
    column: $table.tableOfContentsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get readingLocatorJson => $composableBuilder(
    column: $table.readingLocatorJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReadAt => $composableBuilder(
    column: $table.lastReadAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  Expression<T> highlightsRefs<T extends Object>(
    Expression<T> Function($$HighlightsTableAnnotationComposer a) f,
  ) {
    final $$HighlightsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.highlights,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HighlightsTableAnnotationComposer(
            $db: $db,
            $table: $db.highlights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookmarksRefs<T extends Object>(
    Expression<T> Function($$BookmarksTableAnnotationComposer a) f,
  ) {
    final $$BookmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readingSessionsRefs<T extends Object>(
    Expression<T> Function($$ReadingSessionsTableAnnotationComposer a) f,
  ) {
    final $$ReadingSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingSessions,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.readingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vocabItemsRefs<T extends Object>(
    Expression<T> Function($$VocabItemsTableAnnotationComposer a) f,
  ) {
    final $$VocabItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vocabItems,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.vocabItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LibraryBooksTableTableManager
    extends
        RootTableManager<
          _$LinguaPageDatabase,
          $LibraryBooksTable,
          LibraryBook,
          $$LibraryBooksTableFilterComposer,
          $$LibraryBooksTableOrderingComposer,
          $$LibraryBooksTableAnnotationComposer,
          $$LibraryBooksTableCreateCompanionBuilder,
          $$LibraryBooksTableUpdateCompanionBuilder,
          (LibraryBook, $$LibraryBooksTableReferences),
          LibraryBook,
          PrefetchHooks Function({
            bool highlightsRefs,
            bool bookmarksRefs,
            bool readingSessionsRefs,
            bool vocabItemsRefs,
          })
        > {
  $$LibraryBooksTableTableManager(
    _$LinguaPageDatabase db,
    $LibraryBooksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String> documentFormat = const Value.absent(),
                Value<String> sourceUri = const Value.absent(),
                Value<String> sourceFileName = const Value.absent(),
                Value<String> contentFingerprint = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<String?> languageCode = const Value.absent(),
                Value<String?> tableOfContentsJson = const Value.absent(),
                Value<int> fileSizeBytes = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<String?> readingLocatorJson = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime?> lastReadAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryBooksCompanion(
                id: id,
                title: title,
                author: author,
                documentFormat: documentFormat,
                sourceUri: sourceUri,
                sourceFileName: sourceFileName,
                contentFingerprint: contentFingerprint,
                coverPath: coverPath,
                languageCode: languageCode,
                tableOfContentsJson: tableOfContentsJson,
                fileSizeBytes: fileSizeBytes,
                progress: progress,
                readingLocatorJson: readingLocatorJson,
                addedAt: addedAt,
                lastReadAt: lastReadAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> author = const Value.absent(),
                required String documentFormat,
                required String sourceUri,
                required String sourceFileName,
                required String contentFingerprint,
                Value<String?> coverPath = const Value.absent(),
                Value<String?> languageCode = const Value.absent(),
                Value<String?> tableOfContentsJson = const Value.absent(),
                required int fileSizeBytes,
                Value<double> progress = const Value.absent(),
                Value<String?> readingLocatorJson = const Value.absent(),
                required DateTime addedAt,
                Value<DateTime?> lastReadAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryBooksCompanion.insert(
                id: id,
                title: title,
                author: author,
                documentFormat: documentFormat,
                sourceUri: sourceUri,
                sourceFileName: sourceFileName,
                contentFingerprint: contentFingerprint,
                coverPath: coverPath,
                languageCode: languageCode,
                tableOfContentsJson: tableOfContentsJson,
                fileSizeBytes: fileSizeBytes,
                progress: progress,
                readingLocatorJson: readingLocatorJson,
                addedAt: addedAt,
                lastReadAt: lastReadAt,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LibraryBooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                highlightsRefs = false,
                bookmarksRefs = false,
                readingSessionsRefs = false,
                vocabItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (highlightsRefs) db.highlights,
                    if (bookmarksRefs) db.bookmarks,
                    if (readingSessionsRefs) db.readingSessions,
                    if (vocabItemsRefs) db.vocabItems,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (highlightsRefs)
                        await $_getPrefetchedData<
                          LibraryBook,
                          $LibraryBooksTable,
                          Highlight
                        >(
                          currentTable: table,
                          referencedTable: $$LibraryBooksTableReferences
                              ._highlightsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LibraryBooksTableReferences(
                                db,
                                table,
                                p0,
                              ).highlightsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bookmarksRefs)
                        await $_getPrefetchedData<
                          LibraryBook,
                          $LibraryBooksTable,
                          Bookmark
                        >(
                          currentTable: table,
                          referencedTable: $$LibraryBooksTableReferences
                              ._bookmarksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LibraryBooksTableReferences(
                                db,
                                table,
                                p0,
                              ).bookmarksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readingSessionsRefs)
                        await $_getPrefetchedData<
                          LibraryBook,
                          $LibraryBooksTable,
                          ReadingSession
                        >(
                          currentTable: table,
                          referencedTable: $$LibraryBooksTableReferences
                              ._readingSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LibraryBooksTableReferences(
                                db,
                                table,
                                p0,
                              ).readingSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (vocabItemsRefs)
                        await $_getPrefetchedData<
                          LibraryBook,
                          $LibraryBooksTable,
                          VocabItem
                        >(
                          currentTable: table,
                          referencedTable: $$LibraryBooksTableReferences
                              ._vocabItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LibraryBooksTableReferences(
                                db,
                                table,
                                p0,
                              ).vocabItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LibraryBooksTableProcessedTableManager =
    ProcessedTableManager<
      _$LinguaPageDatabase,
      $LibraryBooksTable,
      LibraryBook,
      $$LibraryBooksTableFilterComposer,
      $$LibraryBooksTableOrderingComposer,
      $$LibraryBooksTableAnnotationComposer,
      $$LibraryBooksTableCreateCompanionBuilder,
      $$LibraryBooksTableUpdateCompanionBuilder,
      (LibraryBook, $$LibraryBooksTableReferences),
      LibraryBook,
      PrefetchHooks Function({
        bool highlightsRefs,
        bool bookmarksRefs,
        bool readingSessionsRefs,
        bool vocabItemsRefs,
      })
    >;
typedef $$HighlightsTableCreateCompanionBuilder =
    HighlightsCompanion Function({
      required String id,
      required String bookId,
      required String color,
      required String selectedText,
      required String locatorJson,
      Value<String?> note,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$HighlightsTableUpdateCompanionBuilder =
    HighlightsCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<String> color,
      Value<String> selectedText,
      Value<String> locatorJson,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

final class $$HighlightsTableReferences
    extends BaseReferences<_$LinguaPageDatabase, $HighlightsTable, Highlight> {
  $$HighlightsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LibraryBooksTable _bookIdTable(_$LinguaPageDatabase db) =>
      db.libraryBooks.createAlias('highlights__book_id__library_books__id');

  $$LibraryBooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$LibraryBooksTableTableManager(
      $_db,
      $_db.libraryBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HighlightsTableFilterComposer
    extends Composer<_$LinguaPageDatabase, $HighlightsTable> {
  $$HighlightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedText => $composableBuilder(
    column: $table.selectedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locatorJson => $composableBuilder(
    column: $table.locatorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LibraryBooksTableFilterComposer get bookId {
    final $$LibraryBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.libraryBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryBooksTableFilterComposer(
            $db: $db,
            $table: $db.libraryBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HighlightsTableOrderingComposer
    extends Composer<_$LinguaPageDatabase, $HighlightsTable> {
  $$HighlightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedText => $composableBuilder(
    column: $table.selectedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locatorJson => $composableBuilder(
    column: $table.locatorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LibraryBooksTableOrderingComposer get bookId {
    final $$LibraryBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.libraryBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryBooksTableOrderingComposer(
            $db: $db,
            $table: $db.libraryBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HighlightsTableAnnotationComposer
    extends Composer<_$LinguaPageDatabase, $HighlightsTable> {
  $$HighlightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get selectedText => $composableBuilder(
    column: $table.selectedText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locatorJson => $composableBuilder(
    column: $table.locatorJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LibraryBooksTableAnnotationComposer get bookId {
    final $$LibraryBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.libraryBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.libraryBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HighlightsTableTableManager
    extends
        RootTableManager<
          _$LinguaPageDatabase,
          $HighlightsTable,
          Highlight,
          $$HighlightsTableFilterComposer,
          $$HighlightsTableOrderingComposer,
          $$HighlightsTableAnnotationComposer,
          $$HighlightsTableCreateCompanionBuilder,
          $$HighlightsTableUpdateCompanionBuilder,
          (Highlight, $$HighlightsTableReferences),
          Highlight,
          PrefetchHooks Function({bool bookId})
        > {
  $$HighlightsTableTableManager(_$LinguaPageDatabase db, $HighlightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HighlightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HighlightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HighlightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> selectedText = const Value.absent(),
                Value<String> locatorJson = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HighlightsCompanion(
                id: id,
                bookId: bookId,
                color: color,
                selectedText: selectedText,
                locatorJson: locatorJson,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required String color,
                required String selectedText,
                required String locatorJson,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HighlightsCompanion.insert(
                id: id,
                bookId: bookId,
                color: color,
                selectedText: selectedText,
                locatorJson: locatorJson,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HighlightsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$HighlightsTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$HighlightsTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HighlightsTableProcessedTableManager =
    ProcessedTableManager<
      _$LinguaPageDatabase,
      $HighlightsTable,
      Highlight,
      $$HighlightsTableFilterComposer,
      $$HighlightsTableOrderingComposer,
      $$HighlightsTableAnnotationComposer,
      $$HighlightsTableCreateCompanionBuilder,
      $$HighlightsTableUpdateCompanionBuilder,
      (Highlight, $$HighlightsTableReferences),
      Highlight,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({
      required String id,
      required String bookId,
      required String title,
      required String locatorJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<String> title,
      Value<String> locatorJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$BookmarksTableReferences
    extends BaseReferences<_$LinguaPageDatabase, $BookmarksTable, Bookmark> {
  $$BookmarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LibraryBooksTable _bookIdTable(_$LinguaPageDatabase db) =>
      db.libraryBooks.createAlias('bookmarks__book_id__library_books__id');

  $$LibraryBooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$LibraryBooksTableTableManager(
      $_db,
      $_db.libraryBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookmarksTableFilterComposer
    extends Composer<_$LinguaPageDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locatorJson => $composableBuilder(
    column: $table.locatorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LibraryBooksTableFilterComposer get bookId {
    final $$LibraryBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.libraryBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryBooksTableFilterComposer(
            $db: $db,
            $table: $db.libraryBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$LinguaPageDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locatorJson => $composableBuilder(
    column: $table.locatorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LibraryBooksTableOrderingComposer get bookId {
    final $$LibraryBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.libraryBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryBooksTableOrderingComposer(
            $db: $db,
            $table: $db.libraryBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$LinguaPageDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get locatorJson => $composableBuilder(
    column: $table.locatorJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$LibraryBooksTableAnnotationComposer get bookId {
    final $$LibraryBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.libraryBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.libraryBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$LinguaPageDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, $$BookmarksTableReferences),
          Bookmark,
          PrefetchHooks Function({bool bookId})
        > {
  $$BookmarksTableTableManager(_$LinguaPageDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> locatorJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion(
                id: id,
                bookId: bookId,
                title: title,
                locatorJson: locatorJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required String title,
                required String locatorJson,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion.insert(
                id: id,
                bookId: bookId,
                title: title,
                locatorJson: locatorJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookmarksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$BookmarksTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$BookmarksTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$LinguaPageDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, $$BookmarksTableReferences),
      Bookmark,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$ReadingSessionsTableCreateCompanionBuilder =
    ReadingSessionsCompanion Function({
      required String id,
      required String bookId,
      required DateTime startedAt,
      required DateTime endedAt,
      required double startProgress,
      required double endProgress,
      Value<int> rowid,
    });
typedef $$ReadingSessionsTableUpdateCompanionBuilder =
    ReadingSessionsCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<DateTime> startedAt,
      Value<DateTime> endedAt,
      Value<double> startProgress,
      Value<double> endProgress,
      Value<int> rowid,
    });

final class $$ReadingSessionsTableReferences
    extends
        BaseReferences<
          _$LinguaPageDatabase,
          $ReadingSessionsTable,
          ReadingSession
        > {
  $$ReadingSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LibraryBooksTable _bookIdTable(_$LinguaPageDatabase db) => db
      .libraryBooks
      .createAlias('reading_sessions__book_id__library_books__id');

  $$LibraryBooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$LibraryBooksTableTableManager(
      $_db,
      $_db.libraryBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingSessionsTableFilterComposer
    extends Composer<_$LinguaPageDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startProgress => $composableBuilder(
    column: $table.startProgress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endProgress => $composableBuilder(
    column: $table.endProgress,
    builder: (column) => ColumnFilters(column),
  );

  $$LibraryBooksTableFilterComposer get bookId {
    final $$LibraryBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.libraryBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryBooksTableFilterComposer(
            $db: $db,
            $table: $db.libraryBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingSessionsTableOrderingComposer
    extends Composer<_$LinguaPageDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startProgress => $composableBuilder(
    column: $table.startProgress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endProgress => $composableBuilder(
    column: $table.endProgress,
    builder: (column) => ColumnOrderings(column),
  );

  $$LibraryBooksTableOrderingComposer get bookId {
    final $$LibraryBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.libraryBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryBooksTableOrderingComposer(
            $db: $db,
            $table: $db.libraryBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingSessionsTableAnnotationComposer
    extends Composer<_$LinguaPageDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get startProgress => $composableBuilder(
    column: $table.startProgress,
    builder: (column) => column,
  );

  GeneratedColumn<double> get endProgress => $composableBuilder(
    column: $table.endProgress,
    builder: (column) => column,
  );

  $$LibraryBooksTableAnnotationComposer get bookId {
    final $$LibraryBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.libraryBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.libraryBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingSessionsTableTableManager
    extends
        RootTableManager<
          _$LinguaPageDatabase,
          $ReadingSessionsTable,
          ReadingSession,
          $$ReadingSessionsTableFilterComposer,
          $$ReadingSessionsTableOrderingComposer,
          $$ReadingSessionsTableAnnotationComposer,
          $$ReadingSessionsTableCreateCompanionBuilder,
          $$ReadingSessionsTableUpdateCompanionBuilder,
          (ReadingSession, $$ReadingSessionsTableReferences),
          ReadingSession,
          PrefetchHooks Function({bool bookId})
        > {
  $$ReadingSessionsTableTableManager(
    _$LinguaPageDatabase db,
    $ReadingSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<double> startProgress = const Value.absent(),
                Value<double> endProgress = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingSessionsCompanion(
                id: id,
                bookId: bookId,
                startedAt: startedAt,
                endedAt: endedAt,
                startProgress: startProgress,
                endProgress: endProgress,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required DateTime startedAt,
                required DateTime endedAt,
                required double startProgress,
                required double endProgress,
                Value<int> rowid = const Value.absent(),
              }) => ReadingSessionsCompanion.insert(
                id: id,
                bookId: bookId,
                startedAt: startedAt,
                endedAt: endedAt,
                startProgress: startProgress,
                endProgress: endProgress,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReadingSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable:
                                    $$ReadingSessionsTableReferences
                                        ._bookIdTable(db),
                                referencedColumn:
                                    $$ReadingSessionsTableReferences
                                        ._bookIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LinguaPageDatabase,
      $ReadingSessionsTable,
      ReadingSession,
      $$ReadingSessionsTableFilterComposer,
      $$ReadingSessionsTableOrderingComposer,
      $$ReadingSessionsTableAnnotationComposer,
      $$ReadingSessionsTableCreateCompanionBuilder,
      $$ReadingSessionsTableUpdateCompanionBuilder,
      (ReadingSession, $$ReadingSessionsTableReferences),
      ReadingSession,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$VocabItemsTableCreateCompanionBuilder =
    VocabItemsCompanion Function({
      required String id,
      required String word,
      required String lemma,
      Value<String> sourceSentence,
      required String translation,
      Value<String?> bookId,
      Value<String?> locatorJson,
      required String sourceLanguage,
      required String targetLanguage,
      Value<String?> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$VocabItemsTableUpdateCompanionBuilder =
    VocabItemsCompanion Function({
      Value<String> id,
      Value<String> word,
      Value<String> lemma,
      Value<String> sourceSentence,
      Value<String> translation,
      Value<String?> bookId,
      Value<String?> locatorJson,
      Value<String> sourceLanguage,
      Value<String> targetLanguage,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$VocabItemsTableReferences
    extends BaseReferences<_$LinguaPageDatabase, $VocabItemsTable, VocabItem> {
  $$VocabItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LibraryBooksTable _bookIdTable(_$LinguaPageDatabase db) =>
      db.libraryBooks.createAlias('vocab_items__book_id__library_books__id');

  $$LibraryBooksTableProcessedTableManager? get bookId {
    final $_column = $_itemColumn<String>('book_id');
    if ($_column == null) return null;
    final manager = $$LibraryBooksTableTableManager(
      $_db,
      $_db.libraryBooks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReviewCardsTable, List<ReviewCard>>
  _reviewCardsRefsTable(_$LinguaPageDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.reviewCards,
        aliasName: 'vocab_items__id__review_cards__vocab_item_id',
      );

  $$ReviewCardsTableProcessedTableManager get reviewCardsRefs {
    final manager = $$ReviewCardsTableTableManager(
      $_db,
      $_db.reviewCards,
    ).filter((f) => f.vocabItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VocabItemsTableFilterComposer
    extends Composer<_$LinguaPageDatabase, $VocabItemsTable> {
  $$VocabItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceSentence => $composableBuilder(
    column: $table.sourceSentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locatorJson => $composableBuilder(
    column: $table.locatorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLanguage => $composableBuilder(
    column: $table.sourceLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetLanguage => $composableBuilder(
    column: $table.targetLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LibraryBooksTableFilterComposer get bookId {
    final $$LibraryBooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.libraryBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryBooksTableFilterComposer(
            $db: $db,
            $table: $db.libraryBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> reviewCardsRefs(
    Expression<bool> Function($$ReviewCardsTableFilterComposer f) f,
  ) {
    final $$ReviewCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewCards,
      getReferencedColumn: (t) => t.vocabItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewCardsTableFilterComposer(
            $db: $db,
            $table: $db.reviewCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VocabItemsTableOrderingComposer
    extends Composer<_$LinguaPageDatabase, $VocabItemsTable> {
  $$VocabItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lemma => $composableBuilder(
    column: $table.lemma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceSentence => $composableBuilder(
    column: $table.sourceSentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locatorJson => $composableBuilder(
    column: $table.locatorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLanguage => $composableBuilder(
    column: $table.sourceLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetLanguage => $composableBuilder(
    column: $table.targetLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LibraryBooksTableOrderingComposer get bookId {
    final $$LibraryBooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.libraryBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryBooksTableOrderingComposer(
            $db: $db,
            $table: $db.libraryBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VocabItemsTableAnnotationComposer
    extends Composer<_$LinguaPageDatabase, $VocabItemsTable> {
  $$VocabItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get lemma =>
      $composableBuilder(column: $table.lemma, builder: (column) => column);

  GeneratedColumn<String> get sourceSentence => $composableBuilder(
    column: $table.sourceSentence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locatorJson => $composableBuilder(
    column: $table.locatorJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceLanguage => $composableBuilder(
    column: $table.sourceLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetLanguage => $composableBuilder(
    column: $table.targetLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$LibraryBooksTableAnnotationComposer get bookId {
    final $$LibraryBooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.libraryBooks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryBooksTableAnnotationComposer(
            $db: $db,
            $table: $db.libraryBooks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> reviewCardsRefs<T extends Object>(
    Expression<T> Function($$ReviewCardsTableAnnotationComposer a) f,
  ) {
    final $$ReviewCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewCards,
      getReferencedColumn: (t) => t.vocabItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VocabItemsTableTableManager
    extends
        RootTableManager<
          _$LinguaPageDatabase,
          $VocabItemsTable,
          VocabItem,
          $$VocabItemsTableFilterComposer,
          $$VocabItemsTableOrderingComposer,
          $$VocabItemsTableAnnotationComposer,
          $$VocabItemsTableCreateCompanionBuilder,
          $$VocabItemsTableUpdateCompanionBuilder,
          (VocabItem, $$VocabItemsTableReferences),
          VocabItem,
          PrefetchHooks Function({bool bookId, bool reviewCardsRefs})
        > {
  $$VocabItemsTableTableManager(_$LinguaPageDatabase db, $VocabItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VocabItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VocabItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VocabItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> lemma = const Value.absent(),
                Value<String> sourceSentence = const Value.absent(),
                Value<String> translation = const Value.absent(),
                Value<String?> bookId = const Value.absent(),
                Value<String?> locatorJson = const Value.absent(),
                Value<String> sourceLanguage = const Value.absent(),
                Value<String> targetLanguage = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VocabItemsCompanion(
                id: id,
                word: word,
                lemma: lemma,
                sourceSentence: sourceSentence,
                translation: translation,
                bookId: bookId,
                locatorJson: locatorJson,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String word,
                required String lemma,
                Value<String> sourceSentence = const Value.absent(),
                required String translation,
                Value<String?> bookId = const Value.absent(),
                Value<String?> locatorJson = const Value.absent(),
                required String sourceLanguage,
                required String targetLanguage,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => VocabItemsCompanion.insert(
                id: id,
                word: word,
                lemma: lemma,
                sourceSentence: sourceSentence,
                translation: translation,
                bookId: bookId,
                locatorJson: locatorJson,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VocabItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, reviewCardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (reviewCardsRefs) db.reviewCards],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$VocabItemsTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$VocabItemsTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reviewCardsRefs)
                    await $_getPrefetchedData<
                      VocabItem,
                      $VocabItemsTable,
                      ReviewCard
                    >(
                      currentTable: table,
                      referencedTable: $$VocabItemsTableReferences
                          ._reviewCardsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$VocabItemsTableReferences(
                            db,
                            table,
                            p0,
                          ).reviewCardsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.vocabItemId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VocabItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$LinguaPageDatabase,
      $VocabItemsTable,
      VocabItem,
      $$VocabItemsTableFilterComposer,
      $$VocabItemsTableOrderingComposer,
      $$VocabItemsTableAnnotationComposer,
      $$VocabItemsTableCreateCompanionBuilder,
      $$VocabItemsTableUpdateCompanionBuilder,
      (VocabItem, $$VocabItemsTableReferences),
      VocabItem,
      PrefetchHooks Function({bool bookId, bool reviewCardsRefs})
    >;
typedef $$ReviewCardsTableCreateCompanionBuilder =
    ReviewCardsCompanion Function({
      required String id,
      required String vocabItemId,
      Value<int> interval,
      Value<double> easeFactor,
      Value<int> repetitions,
      required DateTime nextReviewDate,
      Value<DateTime?> lastReviewedAt,
      Value<String> state,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ReviewCardsTableUpdateCompanionBuilder =
    ReviewCardsCompanion Function({
      Value<String> id,
      Value<String> vocabItemId,
      Value<int> interval,
      Value<double> easeFactor,
      Value<int> repetitions,
      Value<DateTime> nextReviewDate,
      Value<DateTime?> lastReviewedAt,
      Value<String> state,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ReviewCardsTableReferences
    extends
        BaseReferences<_$LinguaPageDatabase, $ReviewCardsTable, ReviewCard> {
  $$ReviewCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VocabItemsTable _vocabItemIdTable(_$LinguaPageDatabase db) =>
      db.vocabItems.createAlias('review_cards__vocab_item_id__vocab_items__id');

  $$VocabItemsTableProcessedTableManager get vocabItemId {
    final $_column = $_itemColumn<String>('vocab_item_id')!;

    final manager = $$VocabItemsTableTableManager(
      $_db,
      $_db.vocabItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vocabItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewCardsTableFilterComposer
    extends Composer<_$LinguaPageDatabase, $ReviewCardsTable> {
  $$ReviewCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextReviewDate => $composableBuilder(
    column: $table.nextReviewDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VocabItemsTableFilterComposer get vocabItemId {
    final $$VocabItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabItemId,
      referencedTable: $db.vocabItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabItemsTableFilterComposer(
            $db: $db,
            $table: $db.vocabItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewCardsTableOrderingComposer
    extends Composer<_$LinguaPageDatabase, $ReviewCardsTable> {
  $$ReviewCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextReviewDate => $composableBuilder(
    column: $table.nextReviewDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VocabItemsTableOrderingComposer get vocabItemId {
    final $$VocabItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabItemId,
      referencedTable: $db.vocabItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabItemsTableOrderingComposer(
            $db: $db,
            $table: $db.vocabItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewCardsTableAnnotationComposer
    extends Composer<_$LinguaPageDatabase, $ReviewCardsTable> {
  $$ReviewCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextReviewDate => $composableBuilder(
    column: $table.nextReviewDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$VocabItemsTableAnnotationComposer get vocabItemId {
    final $$VocabItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vocabItemId,
      referencedTable: $db.vocabItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VocabItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.vocabItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewCardsTableTableManager
    extends
        RootTableManager<
          _$LinguaPageDatabase,
          $ReviewCardsTable,
          ReviewCard,
          $$ReviewCardsTableFilterComposer,
          $$ReviewCardsTableOrderingComposer,
          $$ReviewCardsTableAnnotationComposer,
          $$ReviewCardsTableCreateCompanionBuilder,
          $$ReviewCardsTableUpdateCompanionBuilder,
          (ReviewCard, $$ReviewCardsTableReferences),
          ReviewCard,
          PrefetchHooks Function({bool vocabItemId})
        > {
  $$ReviewCardsTableTableManager(
    _$LinguaPageDatabase db,
    $ReviewCardsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vocabItemId = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<DateTime> nextReviewDate = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewCardsCompanion(
                id: id,
                vocabItemId: vocabItemId,
                interval: interval,
                easeFactor: easeFactor,
                repetitions: repetitions,
                nextReviewDate: nextReviewDate,
                lastReviewedAt: lastReviewedAt,
                state: state,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vocabItemId,
                Value<int> interval = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                required DateTime nextReviewDate,
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<String> state = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ReviewCardsCompanion.insert(
                id: id,
                vocabItemId: vocabItemId,
                interval: interval,
                easeFactor: easeFactor,
                repetitions: repetitions,
                nextReviewDate: nextReviewDate,
                lastReviewedAt: lastReviewedAt,
                state: state,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReviewCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vocabItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vocabItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vocabItemId,
                                referencedTable: $$ReviewCardsTableReferences
                                    ._vocabItemIdTable(db),
                                referencedColumn: $$ReviewCardsTableReferences
                                    ._vocabItemIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReviewCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$LinguaPageDatabase,
      $ReviewCardsTable,
      ReviewCard,
      $$ReviewCardsTableFilterComposer,
      $$ReviewCardsTableOrderingComposer,
      $$ReviewCardsTableAnnotationComposer,
      $$ReviewCardsTableCreateCompanionBuilder,
      $$ReviewCardsTableUpdateCompanionBuilder,
      (ReviewCard, $$ReviewCardsTableReferences),
      ReviewCard,
      PrefetchHooks Function({bool vocabItemId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$LinguaPageDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$LinguaPageDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$LinguaPageDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$LinguaPageDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$LinguaPageDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(
    _$LinguaPageDatabase db,
    $AppSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$LinguaPageDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$LinguaPageDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $LinguaPageDatabaseManager {
  final _$LinguaPageDatabase _db;
  $LinguaPageDatabaseManager(this._db);
  $$LibraryBooksTableTableManager get libraryBooks =>
      $$LibraryBooksTableTableManager(_db, _db.libraryBooks);
  $$HighlightsTableTableManager get highlights =>
      $$HighlightsTableTableManager(_db, _db.highlights);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$ReadingSessionsTableTableManager get readingSessions =>
      $$ReadingSessionsTableTableManager(_db, _db.readingSessions);
  $$VocabItemsTableTableManager get vocabItems =>
      $$VocabItemsTableTableManager(_db, _db.vocabItems);
  $$ReviewCardsTableTableManager get reviewCards =>
      $$ReviewCardsTableTableManager(_db, _db.reviewCards);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
