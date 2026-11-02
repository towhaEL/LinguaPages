/// A user-named shelf; a book can be in several.
class CollectionEntity {
  const CollectionEntity({
    required this.id,
    required this.name,
    this.bookIds = const {},
  });

  final String id;
  final String name;
  final Set<String> bookIds;
}
