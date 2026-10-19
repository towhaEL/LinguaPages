import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_state.dart';

void main() {
  test('library state defaults to grid and can switch to list mode', () {
    const initial = LibraryState();

    expect(initial.viewMode, LibraryViewMode.grid);
    expect(
      initial.copyWith(viewMode: LibraryViewMode.list).viewMode,
      LibraryViewMode.list,
    );
    expect(initial.sort, LibrarySort.recent);
    expect(
      initial.copyWith(sort: LibrarySort.progress).sort,
      LibrarySort.progress,
    );
  });
}
