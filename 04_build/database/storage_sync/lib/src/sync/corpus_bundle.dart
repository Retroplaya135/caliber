import 'dart:convert';

import 'canonical_json.dart';

final class CorpusBundleManifest {
  CorpusBundleManifest({
    required this.bundleId,
    required this.corpusBundleVersion,
    required this.payloadSha256,
    required this.payloadSizeBytes,
    required this.publishedAtUtc,
    this.schemaVersion = 1,
    Map<String, Object?> metadata = const {},
  }) : metadata = Map.unmodifiable(metadata);

  factory CorpusBundleManifest.fromJson(Map<String, Object?> json) {
    return CorpusBundleManifest(
      bundleId: json['bundle_id']! as String,
      corpusBundleVersion: json['corpus_bundle_version']! as int,
      payloadSha256: json['payload_sha256']! as String,
      payloadSizeBytes: json['payload_size_bytes']! as int,
      publishedAtUtc: DateTime.parse(
        json['published_at_utc']! as String,
      ).toUtc(),
      schemaVersion: json['schema_version']! as int,
      metadata: (json['metadata'] as Map?)?.cast<String, Object?>() ?? const {},
    );
  }

  final String bundleId;
  final int corpusBundleVersion;
  final String payloadSha256;
  final int payloadSizeBytes;
  final DateTime publishedAtUtc;
  final int schemaVersion;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() {
    return {
      'bundle_id': bundleId,
      'corpus_bundle_version': corpusBundleVersion,
      'metadata': metadata,
      'payload_sha256': payloadSha256,
      'payload_size_bytes': payloadSizeBytes,
      'published_at_utc': publishedAtUtc.toUtc().toIso8601String(),
      'schema_version': schemaVersion,
    };
  }

  String get canonicalJson => CanonicalJson.encode(toJson());

  List<int> get signedBytes => utf8.encode(canonicalJson);
}

final class SignedCorpusBundle {
  SignedCorpusBundle({
    required this.manifest,
    required List<int> payload,
    required List<int> signature,
    required List<int> publicKey,
  }) : payload = List<int>.unmodifiable(payload),
       signature = List<int>.unmodifiable(signature),
       publicKey = List<int>.unmodifiable(publicKey);

  final CorpusBundleManifest manifest;
  final List<int> payload;
  final List<int> signature;
  final List<int> publicKey;
}
