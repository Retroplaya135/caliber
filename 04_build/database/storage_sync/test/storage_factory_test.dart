import 'dart:convert';
import 'dart:io';

import 'package:caliber_storage_sync/src/crypto/database_key_manager.dart';
import 'package:caliber_storage_sync/src/crypto/sqlite_encryption.dart';
import 'package:caliber_storage_sync/src/storage/caliber_storage_factory.dart';
import 'package:caliber_storage_sync/src/testing/fakes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'opens isolated physical databases for user, corpus, and cache',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'caliber-storage-factory-',
      );
      addTearDown(() => root.delete(recursive: true));

      final factory = CaliberStorageFactory(
        pathResolver: FixedStoragePathResolver(root),
        keyManager: DatabaseKeyManager(
          vault: MemoryDatabaseKeyVault(),
          generator: FixedDatabaseKeyGenerator(19),
        ),
        encryption: const SqliteEncryption(
          config: SqliteEncryptionConfig(requireCipherPragma: false),
        ),
      );

      final storage = await factory.open();
      addTearDown(storage.close);

      const marker = 'user-ledger-marker-never-plaintext';
      await storage.user.putMetadata('eval_cluster_contract', marker);
      await storage.corpus.putMetadata('corpus_only', 'bundle-index');
      await storage.cache.putEntry(
        cacheKey: 'http-cache-entry',
        scope: 'http',
        payload: utf8.encode('cache payload'),
      );

      expect(storage.physicalFiles.values.toSet().length, 3);
      for (final file in storage.physicalFiles.values) {
        expect(file.existsSync(), isTrue);
      }

      expect(await storage.user.readMetadata('eval_cluster_contract'), marker);
      expect(
        await storage.corpus.readMetadata('eval_cluster_contract'),
        isNull,
      );
      expect(await storage.corpus.readMetadata('corpus_only'), 'bundle-index');

      await storage.close();
    },
  );
}
