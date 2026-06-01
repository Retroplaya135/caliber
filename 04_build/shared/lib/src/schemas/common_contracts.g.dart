// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_contracts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EvidenceSpan _$EvidenceSpanFromJson(Map<String, dynamic> json) =>
    _EvidenceSpan(
      schemaVersion:
          json['schema_version'] as String? ?? kEvidenceSpanSchemaVersion,
      sourceId: json['source_id'] as String,
      sourceType: json['source_type'] as String,
      startOffset: (json['start_offset'] as num).toInt(),
      endOffset: (json['end_offset'] as num).toInt(),
      quote: json['quote'] as String?,
      metadata:
          json['metadata'] as Map<String, dynamic>? ??
          const <String, Object?>{},
    );

Map<String, dynamic> _$EvidenceSpanToJson(_EvidenceSpan instance) =>
    <String, dynamic>{
      'schema_version': instance.schemaVersion,
      'source_id': instance.sourceId,
      'source_type': instance.sourceType,
      'start_offset': instance.startOffset,
      'end_offset': instance.endOffset,
      'quote': instance.quote,
      'metadata': instance.metadata,
    };
