import '../drift/corpus_database.dart';
import 'corpus_bundle.dart';
import 'corpus_bundle_verifier.dart';

abstract interface class CorpusBundleSource {
  Future<SignedCorpusBundle> download(Uri uri);
}

final class CorpusBundleSyncResult {
  const CorpusBundleSyncResult({
    required this.adoptedVersion,
    required this.bundleId,
  });

  final int adoptedVersion;
  final String bundleId;
}

final class CorpusBundleRejectedException implements Exception {
  const CorpusBundleRejectedException(this.message);

  final String message;

  @override
  String toString() {
    return 'CorpusBundleRejectedException: $message';
  }
}

final class CorpusBundleSyncService {
  CorpusBundleSyncService({
    required this._corpusDatabase,
    required this._source,
    CorpusBundleVerifier? verifier,
  }) : _verifier = verifier ?? CorpusBundleVerifier();

  final CorpusStorageDatabase _corpusDatabase;
  final CorpusBundleSource _source;
  final CorpusBundleVerifier _verifier;

  Future<CorpusBundleSyncResult> sync(Uri uri) async {
    final bundle = await _source.download(uri);
    await _verifier.verify(bundle);

    final latest = await _corpusDatabase.latestBundleVersion();
    final incoming = bundle.manifest.corpusBundleVersion;
    if (latest != null && incoming <= latest) {
      throw CorpusBundleRejectedException(
        'Rejected corpus bundle $incoming because active version is $latest.',
      );
    }

    await _corpusDatabase.adoptVerifiedBundle(bundle);
    return CorpusBundleSyncResult(
      adoptedVersion: incoming,
      bundleId: bundle.manifest.bundleId,
    );
  }
}

final class PersonalDataSyncDisabled {
  Never reject() {
    throw UnsupportedError(
      'Personal data sync is disabled in v1. Only signed corpus bundles may sync.',
    );
  }
}
