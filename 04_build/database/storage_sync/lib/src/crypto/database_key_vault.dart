import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

enum LogicalDatabaseKind {
  user,
  corpus,
  cache;

  String get storageName => name;
}

final class DatabaseKey {
  DatabaseKey(List<int> bytes)
    : bytes = Uint8List.fromList(List<int>.unmodifiable(bytes)) {
    if (bytes.length != lengthBytes) {
      throw ArgumentError.value(bytes.length, 'bytes.length', 'must be 32');
    }
  }

  factory DatabaseKey.fromBase64(String encoded) {
    return DatabaseKey(base64Decode(encoded));
  }

  static const lengthBytes = 32;

  final Uint8List bytes;

  String get base64Value => base64Encode(bytes);

  String get hexValue {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}

abstract interface class DatabaseKeyVault {
  Future<String?> read(String key);

  Future<void> write(String key, String value);
}

abstract interface class DatabaseKeyGenerator {
  DatabaseKey generate();
}

final class SecureRandomDatabaseKeyGenerator implements DatabaseKeyGenerator {
  const SecureRandomDatabaseKeyGenerator();

  @override
  DatabaseKey generate() {
    final random = Random.secure();
    return DatabaseKey(
      List<int>.generate(DatabaseKey.lengthBytes, (_) => random.nextInt(256)),
    );
  }
}
