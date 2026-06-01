import 'package:freezed_annotation/freezed_annotation.dart';

import '../schema_versions.dart';

part 'common_contracts.freezed.dart';
part 'common_contracts.g.dart';

@freezed
abstract class EvidenceSpan with _$EvidenceSpan {
  @Assert('startOffset >= 0', 'startOffset must be non-negative')
  @Assert('endOffset >= startOffset', 'endOffset must be >= startOffset')
  @JsonSerializable(explicitToJson: true)
  const factory EvidenceSpan({
    @JsonKey(name: 'schema_version')
    @Default(kEvidenceSpanSchemaVersion)
    String schemaVersion,
    @JsonKey(name: 'source_id') required String sourceId,
    @JsonKey(name: 'source_type') required String sourceType,
    @JsonKey(name: 'start_offset') required int startOffset,
    @JsonKey(name: 'end_offset') required int endOffset,
    String? quote,
    @Default(<String, Object?>{}) Map<String, Object?> metadata,
  }) = _EvidenceSpan;

  factory EvidenceSpan.fromJson(Map<String, Object?> json) =>
      _$EvidenceSpanFromJson(json);
}

bool hasSchemaVersion(Map<String, Object?> json, String expected) =>
    json['schema_version'] == expected;

bool hasEvidenceSpans(List<EvidenceSpan> spans) => spans.isNotEmpty;
