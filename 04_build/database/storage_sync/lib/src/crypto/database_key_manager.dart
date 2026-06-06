import 'database_key_vault.dart';

final class DatabaseKeyManager {
  DatabaseKeyManager({
    required this._vault,
    this._generator = const SecureRandomDatabaseKeyGenerator(),
    this._namespace = 'caliber.storage',
  });

  final DatabaseKeyVault _vault;
  final DatabaseKeyGenerator _generator;
  final String _namespace;

  Future<DatabaseKey> getOrCreate(LogicalDatabaseKind kind) async {
    final keyName = vaultKeyFor(kind);
    final stored = await _vault.read(keyName);
    if (stored != null) {
      return DatabaseKey.fromBase64(stored);
    }

    final generated = _generator.generate();
    await _vault.write(keyName, generated.base64Value);
    return generated;
  }

  String vaultKeyFor(LogicalDatabaseKind kind) {
    return '$_namespace.${kind.storageName}.sqlite3mc.key.v1';
  }
}
