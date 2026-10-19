import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_pages/data/repository_impl/translation/local_language_pack_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalLanguagePackRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = LocalLanguagePackRepository(
      await SharedPreferences.getInstance(),
    );
  });

  test('persists install and delete state for the bundled pack', () async {
    final before = await repository.getAvailablePacks();
    expect(before, hasLength(1));
    expect(before.single.isInstalled, isFalse);

    await repository.install('en-es');
    expect((await repository.getAvailablePacks()).single.isInstalled, isTrue);

    await repository.delete('en-es');
    expect((await repository.getAvailablePacks()).single.isInstalled, isFalse);
  });

  test('rejects unknown pack ids', () async {
    await expectLater(repository.install('fr-de'), throwsArgumentError);
  });
}
