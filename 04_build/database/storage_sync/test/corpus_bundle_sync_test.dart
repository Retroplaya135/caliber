import 'dart:convert';

import 'package:caliber_storage_sync/src/drift/corpus_database.dart';
import 'package:caliber_storage_sync/src/sync/corpus_bundle.dart';
import 'package:caliber_storage_sync/src/sync/corpus_bundle_sync_service.dart';
import 'package:caliber_storage_sync/src/sync/corpus_bundle_verifier.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('verifies signed bundle before insert-only adoption', () async {
    final db = CorpusStorageDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1 AS ready;').get();

    final algorithm = Ed25519();
    final SimpleKeyPair keyPair = await algorithm.newKeyPair();
    final source = _FakeCorpusBundleSource(
      await _signedBundle(
        algorithm: algorithm,
        keyPair: keyPair,
        version: 2,
        payload: utf8.encode('verified corpus payload v0.2 with 30 scenarios'),
        metadata: const {
          'source': 'unit-test',
          'corpus_bundle_version': 'backend_depth_corpus_seed.v0.2',
          'scenario_count': '30',
        },
      ),
    );
    final service = CorpusBundleSyncService(corpusDatabase: db, source: source);

    final result = await service.sync(
      Uri.parse('https://corpus.local/v2.bundle'),
    );
    expect(result.adoptedVersion, 2);
    expect(await db.latestBundleVersion(), 2);
    expect(source.bundle.manifest.metadata['scenario_count'], '30');
    expect(await db.watchCorpusBundles().first, hasLength(1));
  });

  test('rejects tampered payloads and older bundle versions', () async {
    final db = CorpusStorageDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customSelect('SELECT 1 AS ready;').get();

    final algorithm = Ed25519();
    final SimpleKeyPair keyPair = await algorithm.newKeyPair();
    final accepted = await _signedBundle(
      algorithm: algorithm,
      keyPair: keyPair,
      version: 2,
      payload: utf8.encode('accepted payload'),
    );
    await CorpusBundleSyncService(
      corpusDatabase: db,
      source: _FakeCorpusBundleSource(accepted),
    ).sync(Uri.parse('https://corpus.local/v2.bundle'));

    final tampered = SignedCorpusBundle(
      manifest: accepted.manifest,
      payload: utf8.encode('tampered payload'),
      signature: accepted.signature,
      publicKey: accepted.publicKey,
    );
    await expectLater(
      CorpusBundleSyncService(
        corpusDatabase: db,
        source: _FakeCorpusBundleSource(tampered),
      ).sync(Uri.parse('https://corpus.local/tampered.bundle')),
      throwsA(isA<CorpusBundleVerificationException>()),
    );

    final older = await _signedBundle(
      algorithm: algorithm,
      keyPair: keyPair,
      version: 1,
      payload: utf8.encode('older payload'),
    );
    await expectLater(
      CorpusBundleSyncService(
        corpusDatabase: db,
        source: _FakeCorpusBundleSource(older),
      ).sync(Uri.parse('https://corpus.local/v1.bundle')),
      throwsA(isA<CorpusBundleRejectedException>()),
    );
  });

  test('personal data sync is explicitly disabled in v1', () {
    expect(PersonalDataSyncDisabled().reject, throwsA(isA<UnsupportedError>()));
  });
}

Future<SignedCorpusBundle> _signedBundle({
  required Ed25519 algorithm,
  required SimpleKeyPair keyPair,
  required int version,
  required List<int> payload,
  Map<String, String> metadata = const {'source': 'unit-test'},
}) async {
  final publicKey = await keyPair.extractPublicKey();
  final manifest = CorpusBundleManifest(
    bundleId: 'bundle-$version',
    corpusBundleVersion: version,
    payloadSha256: sha256.convert(payload).toString(),
    payloadSizeBytes: payload.length,
    publishedAtUtc: DateTime.utc(2026, 5, 31, 12, version),
    metadata: metadata,
  );
  final signature = await algorithm.sign(
    manifest.signedBytes,
    keyPair: keyPair,
  );
  return SignedCorpusBundle(
    manifest: manifest,
    payload: payload,
    signature: signature.bytes,
    publicKey: publicKey.bytes,
  );
}

final class _FakeCorpusBundleSource implements CorpusBundleSource {
  const _FakeCorpusBundleSource(this.bundle);

  final SignedCorpusBundle bundle;

  @override
  Future<SignedCorpusBundle> download(Uri uri) async => bundle;
}
