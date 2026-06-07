import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';

import 'corpus_bundle.dart';

final class CorpusBundleVerificationException implements Exception {
  const CorpusBundleVerificationException(this.message);

  final String message;

  @override
  String toString() {
    return 'CorpusBundleVerificationException: $message';
  }
}

final class CorpusBundleVerifier {
  CorpusBundleVerifier({Ed25519? signatureAlgorithm})
    : _signatureAlgorithm = signatureAlgorithm ?? Ed25519();

  final Ed25519 _signatureAlgorithm;

  Future<void> verify(SignedCorpusBundle bundle) async {
    final manifest = bundle.manifest;
    if (manifest.corpusBundleVersion <= 0) {
      throw const CorpusBundleVerificationException(
        'corpus_bundle_version must be positive.',
      );
    }

    final actualHash = sha256.convert(bundle.payload).toString();
    if (actualHash != manifest.payloadSha256) {
      throw CorpusBundleVerificationException(
        'payload sha256 mismatch: expected ${manifest.payloadSha256}, got $actualHash.',
      );
    }

    if (bundle.payload.length != manifest.payloadSizeBytes) {
      throw CorpusBundleVerificationException(
        'payload size mismatch: expected ${manifest.payloadSizeBytes}, got ${bundle.payload.length}.',
      );
    }

    final signature = Signature(
      bundle.signature,
      publicKey: SimplePublicKey(bundle.publicKey, type: KeyPairType.ed25519),
    );

    final verified = await _signatureAlgorithm.verify(
      manifest.signedBytes,
      signature: signature,
    );

    if (!verified) {
      throw const CorpusBundleVerificationException(
        'Ed25519 signature rejected for corpus bundle manifest.',
      );
    }
  }
}
