import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'database_key_vault.dart';

final class SecureStorageDatabaseKeyVault implements DatabaseKeyVault {
  SecureStorageDatabaseKeyVault({
    this._storage = const FlutterSecureStorage(),
  });

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  @override
  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }
}
