import 'package:caliber_storage_sync/src/crypto/database_key_manager.dart';
import 'package:caliber_storage_sync/src/crypto/database_key_vault.dart';
import 'package:caliber_storage_sync/src/testing/fakes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates stable separate keys for each logical database', () async {
    final vault = MemoryDatabaseKeyVault();
    final manager = DatabaseKeyManager(
      vault: vault,
      generator: FixedDatabaseKeyGenerator(7),
    );

    final user = await manager.getOrCreate(LogicalDatabaseKind.user);
    final corpus = await manager.getOrCreate(LogicalDatabaseKind.corpus);
    final cache = await manager.getOrCreate(LogicalDatabaseKind.cache);

    expect(user.hexValue, isNot(corpus.hexValue));
    expect(user.hexValue, isNot(cache.hexValue));
    expect(corpus.hexValue, isNot(cache.hexValue));

    final userAgain = await manager.getOrCreate(LogicalDatabaseKind.user);
    expect(userAgain.hexValue, user.hexValue);

    expect(
      await vault.read(manager.vaultKeyFor(LogicalDatabaseKind.user)),
      isNotNull,
    );
    expect(
      await vault.read(manager.vaultKeyFor(LogicalDatabaseKind.corpus)),
      isNotNull,
    );
    expect(
      await vault.read(manager.vaultKeyFor(LogicalDatabaseKind.cache)),
      isNotNull,
    );
  });
}
