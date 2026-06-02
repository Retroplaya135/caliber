// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transcript_contracts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TranscriptSegment {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'segment_id') String get segmentId;@JsonKey(name: 'speaker_label') String get speakerLabel;@JsonKey(name: 'start_ms') int get startMs;@JsonKey(name: 'end_ms') int get endMs; String get text; double? get confidence;@JsonKey(name: 'word_ids') List<String> get wordIds;@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans;
/// Create a copy of TranscriptSegment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranscriptSegmentCopyWith<TranscriptSegment> get copyWith => _$TranscriptSegmentCopyWithImpl<TranscriptSegment>(this as TranscriptSegment, _$identity);

  /// Serializes this TranscriptSegment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranscriptSegment&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.segmentId, segmentId) || other.segmentId == segmentId)&&(identical(other.speakerLabel, speakerLabel) || other.speakerLabel == speakerLabel)&&(identical(other.startMs, startMs) || other.startMs == startMs)&&(identical(other.endMs, endMs) || other.endMs == endMs)&&(identical(other.text, text) || other.text == text)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other.wordIds, wordIds)&&const DeepCollectionEquality().equals(other.evidenceSpans, evidenceSpans));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,segmentId,speakerLabel,startMs,endMs,text,confidence,const DeepCollectionEquality().hash(wordIds),const DeepCollectionEquality().hash(evidenceSpans));

@override
String toString() {
  return 'TranscriptSegment(schemaVersion: $schemaVersion, segmentId: $segmentId, speakerLabel: $speakerLabel, startMs: $startMs, endMs: $endMs, text: $text, confidence: $confidence, wordIds: $wordIds, evidenceSpans: $evidenceSpans)';
}


}

/// @nodoc
abstract mixin class $TranscriptSegmentCopyWith<$Res>  {
  factory $TranscriptSegmentCopyWith(TranscriptSegment value, $Res Function(TranscriptSegment) _then) = _$TranscriptSegmentCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'segment_id') String segmentId,@JsonKey(name: 'speaker_label') String speakerLabel,@JsonKey(name: 'start_ms') int startMs,@JsonKey(name: 'end_ms') int endMs, String text, double? confidence,@JsonKey(name: 'word_ids') List<String> wordIds,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans
});




}
/// @nodoc
class _$TranscriptSegmentCopyWithImpl<$Res>
    implements $TranscriptSegmentCopyWith<$Res> {
  _$TranscriptSegmentCopyWithImpl(this._self, this._then);

  final TranscriptSegment _self;
  final $Res Function(TranscriptSegment) _then;

/// Create a copy of TranscriptSegment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? segmentId = null,Object? speakerLabel = null,Object? startMs = null,Object? endMs = null,Object? text = null,Object? confidence = freezed,Object? wordIds = null,Object? evidenceSpans = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,segmentId: null == segmentId ? _self.segmentId : segmentId // ignore: cast_nullable_to_non_nullable
as String,speakerLabel: null == speakerLabel ? _self.speakerLabel : speakerLabel // ignore: cast_nullable_to_non_nullable
as String,startMs: null == startMs ? _self.startMs : startMs // ignore: cast_nullable_to_non_nullable
as int,endMs: null == endMs ? _self.endMs : endMs // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,wordIds: null == wordIds ? _self.wordIds : wordIds // ignore: cast_nullable_to_non_nullable
as List<String>,evidenceSpans: null == evidenceSpans ? _self.evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,
  ));
}

}


/// Adds pattern-matching-related methods to [TranscriptSegment].
extension TranscriptSegmentPatterns on TranscriptSegment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranscriptSegment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranscriptSegment() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranscriptSegment value)  $default,){
final _that = this;
switch (_that) {
case _TranscriptSegment():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranscriptSegment value)?  $default,){
final _that = this;
switch (_that) {
case _TranscriptSegment() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'segment_id')  String segmentId, @JsonKey(name: 'speaker_label')  String speakerLabel, @JsonKey(name: 'start_ms')  int startMs, @JsonKey(name: 'end_ms')  int endMs,  String text,  double? confidence, @JsonKey(name: 'word_ids')  List<String> wordIds, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranscriptSegment() when $default != null:
return $default(_that.schemaVersion,_that.segmentId,_that.speakerLabel,_that.startMs,_that.endMs,_that.text,_that.confidence,_that.wordIds,_that.evidenceSpans);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'segment_id')  String segmentId, @JsonKey(name: 'speaker_label')  String speakerLabel, @JsonKey(name: 'start_ms')  int startMs, @JsonKey(name: 'end_ms')  int endMs,  String text,  double? confidence, @JsonKey(name: 'word_ids')  List<String> wordIds, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans)  $default,) {final _that = this;
switch (_that) {
case _TranscriptSegment():
return $default(_that.schemaVersion,_that.segmentId,_that.speakerLabel,_that.startMs,_that.endMs,_that.text,_that.confidence,_that.wordIds,_that.evidenceSpans);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'segment_id')  String segmentId, @JsonKey(name: 'speaker_label')  String speakerLabel, @JsonKey(name: 'start_ms')  int startMs, @JsonKey(name: 'end_ms')  int endMs,  String text,  double? confidence, @JsonKey(name: 'word_ids')  List<String> wordIds, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans)?  $default,) {final _that = this;
switch (_that) {
case _TranscriptSegment() when $default != null:
return $default(_that.schemaVersion,_that.segmentId,_that.speakerLabel,_that.startMs,_that.endMs,_that.text,_that.confidence,_that.wordIds,_that.evidenceSpans);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _TranscriptSegment implements TranscriptSegment {
  const _TranscriptSegment({@JsonKey(name: 'schema_version') this.schemaVersion = kTranscriptSegmentSchemaVersion, @JsonKey(name: 'segment_id') required this.segmentId, @JsonKey(name: 'speaker_label') required this.speakerLabel, @JsonKey(name: 'start_ms') required this.startMs, @JsonKey(name: 'end_ms') required this.endMs, required this.text, this.confidence, @JsonKey(name: 'word_ids') final  List<String> wordIds = const <String>[], @JsonKey(name: 'evidence_spans') final  List<EvidenceSpan> evidenceSpans = const <EvidenceSpan>[]}): assert(startMs >= 0, 'startMs must be non-negative'),assert(endMs >= startMs, 'endMs must be >= startMs'),assert(confidence == null || (confidence >= 0 && confidence <= 1), 'confidence must be null or between 0 and 1'),_wordIds = wordIds,_evidenceSpans = evidenceSpans;
  factory _TranscriptSegment.fromJson(Map<String, dynamic> json) => _$TranscriptSegmentFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'segment_id') final  String segmentId;
@override@JsonKey(name: 'speaker_label') final  String speakerLabel;
@override@JsonKey(name: 'start_ms') final  int startMs;
@override@JsonKey(name: 'end_ms') final  int endMs;
@override final  String text;
@override final  double? confidence;
 final  List<String> _wordIds;
@override@JsonKey(name: 'word_ids') List<String> get wordIds {
  if (_wordIds is EqualUnmodifiableListView) return _wordIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wordIds);
}

 final  List<EvidenceSpan> _evidenceSpans;
@override@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans {
  if (_evidenceSpans is EqualUnmodifiableListView) return _evidenceSpans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidenceSpans);
}


/// Create a copy of TranscriptSegment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranscriptSegmentCopyWith<_TranscriptSegment> get copyWith => __$TranscriptSegmentCopyWithImpl<_TranscriptSegment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranscriptSegmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranscriptSegment&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.segmentId, segmentId) || other.segmentId == segmentId)&&(identical(other.speakerLabel, speakerLabel) || other.speakerLabel == speakerLabel)&&(identical(other.startMs, startMs) || other.startMs == startMs)&&(identical(other.endMs, endMs) || other.endMs == endMs)&&(identical(other.text, text) || other.text == text)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other._wordIds, _wordIds)&&const DeepCollectionEquality().equals(other._evidenceSpans, _evidenceSpans));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,segmentId,speakerLabel,startMs,endMs,text,confidence,const DeepCollectionEquality().hash(_wordIds),const DeepCollectionEquality().hash(_evidenceSpans));

@override
String toString() {
  return 'TranscriptSegment(schemaVersion: $schemaVersion, segmentId: $segmentId, speakerLabel: $speakerLabel, startMs: $startMs, endMs: $endMs, text: $text, confidence: $confidence, wordIds: $wordIds, evidenceSpans: $evidenceSpans)';
}


}

/// @nodoc
abstract mixin class _$TranscriptSegmentCopyWith<$Res> implements $TranscriptSegmentCopyWith<$Res> {
  factory _$TranscriptSegmentCopyWith(_TranscriptSegment value, $Res Function(_TranscriptSegment) _then) = __$TranscriptSegmentCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'segment_id') String segmentId,@JsonKey(name: 'speaker_label') String speakerLabel,@JsonKey(name: 'start_ms') int startMs,@JsonKey(name: 'end_ms') int endMs, String text, double? confidence,@JsonKey(name: 'word_ids') List<String> wordIds,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans
});




}
/// @nodoc
class __$TranscriptSegmentCopyWithImpl<$Res>
    implements _$TranscriptSegmentCopyWith<$Res> {
  __$TranscriptSegmentCopyWithImpl(this._self, this._then);

  final _TranscriptSegment _self;
  final $Res Function(_TranscriptSegment) _then;

/// Create a copy of TranscriptSegment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? segmentId = null,Object? speakerLabel = null,Object? startMs = null,Object? endMs = null,Object? text = null,Object? confidence = freezed,Object? wordIds = null,Object? evidenceSpans = null,}) {
  return _then(_TranscriptSegment(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,segmentId: null == segmentId ? _self.segmentId : segmentId // ignore: cast_nullable_to_non_nullable
as String,speakerLabel: null == speakerLabel ? _self.speakerLabel : speakerLabel // ignore: cast_nullable_to_non_nullable
as String,startMs: null == startMs ? _self.startMs : startMs // ignore: cast_nullable_to_non_nullable
as int,endMs: null == endMs ? _self.endMs : endMs // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,wordIds: null == wordIds ? _self._wordIds : wordIds // ignore: cast_nullable_to_non_nullable
as List<String>,evidenceSpans: null == evidenceSpans ? _self._evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,
  ));
}


}


/// @nodoc
mixin _$TranscriptWord {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'word_id') String get wordId;@JsonKey(name: 'segment_id') String get segmentId; String get text;@JsonKey(name: 'start_ms') int get startMs;@JsonKey(name: 'end_ms') int get endMs; double? get confidence;
/// Create a copy of TranscriptWord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranscriptWordCopyWith<TranscriptWord> get copyWith => _$TranscriptWordCopyWithImpl<TranscriptWord>(this as TranscriptWord, _$identity);

  /// Serializes this TranscriptWord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranscriptWord&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.segmentId, segmentId) || other.segmentId == segmentId)&&(identical(other.text, text) || other.text == text)&&(identical(other.startMs, startMs) || other.startMs == startMs)&&(identical(other.endMs, endMs) || other.endMs == endMs)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,wordId,segmentId,text,startMs,endMs,confidence);

@override
String toString() {
  return 'TranscriptWord(schemaVersion: $schemaVersion, wordId: $wordId, segmentId: $segmentId, text: $text, startMs: $startMs, endMs: $endMs, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $TranscriptWordCopyWith<$Res>  {
  factory $TranscriptWordCopyWith(TranscriptWord value, $Res Function(TranscriptWord) _then) = _$TranscriptWordCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'word_id') String wordId,@JsonKey(name: 'segment_id') String segmentId, String text,@JsonKey(name: 'start_ms') int startMs,@JsonKey(name: 'end_ms') int endMs, double? confidence
});




}
/// @nodoc
class _$TranscriptWordCopyWithImpl<$Res>
    implements $TranscriptWordCopyWith<$Res> {
  _$TranscriptWordCopyWithImpl(this._self, this._then);

  final TranscriptWord _self;
  final $Res Function(TranscriptWord) _then;

/// Create a copy of TranscriptWord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? wordId = null,Object? segmentId = null,Object? text = null,Object? startMs = null,Object? endMs = null,Object? confidence = freezed,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,segmentId: null == segmentId ? _self.segmentId : segmentId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,startMs: null == startMs ? _self.startMs : startMs // ignore: cast_nullable_to_non_nullable
as int,endMs: null == endMs ? _self.endMs : endMs // ignore: cast_nullable_to_non_nullable
as int,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [TranscriptWord].
extension TranscriptWordPatterns on TranscriptWord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranscriptWord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranscriptWord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranscriptWord value)  $default,){
final _that = this;
switch (_that) {
case _TranscriptWord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranscriptWord value)?  $default,){
final _that = this;
switch (_that) {
case _TranscriptWord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'word_id')  String wordId, @JsonKey(name: 'segment_id')  String segmentId,  String text, @JsonKey(name: 'start_ms')  int startMs, @JsonKey(name: 'end_ms')  int endMs,  double? confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranscriptWord() when $default != null:
return $default(_that.schemaVersion,_that.wordId,_that.segmentId,_that.text,_that.startMs,_that.endMs,_that.confidence);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'word_id')  String wordId, @JsonKey(name: 'segment_id')  String segmentId,  String text, @JsonKey(name: 'start_ms')  int startMs, @JsonKey(name: 'end_ms')  int endMs,  double? confidence)  $default,) {final _that = this;
switch (_that) {
case _TranscriptWord():
return $default(_that.schemaVersion,_that.wordId,_that.segmentId,_that.text,_that.startMs,_that.endMs,_that.confidence);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'word_id')  String wordId, @JsonKey(name: 'segment_id')  String segmentId,  String text, @JsonKey(name: 'start_ms')  int startMs, @JsonKey(name: 'end_ms')  int endMs,  double? confidence)?  $default,) {final _that = this;
switch (_that) {
case _TranscriptWord() when $default != null:
return $default(_that.schemaVersion,_that.wordId,_that.segmentId,_that.text,_that.startMs,_that.endMs,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _TranscriptWord implements TranscriptWord {
  const _TranscriptWord({@JsonKey(name: 'schema_version') this.schemaVersion = kTranscriptWordSchemaVersion, @JsonKey(name: 'word_id') required this.wordId, @JsonKey(name: 'segment_id') required this.segmentId, required this.text, @JsonKey(name: 'start_ms') required this.startMs, @JsonKey(name: 'end_ms') required this.endMs, this.confidence}): assert(startMs >= 0, 'startMs must be non-negative'),assert(endMs >= startMs, 'endMs must be >= startMs'),assert(confidence == null || (confidence >= 0 && confidence <= 1), 'confidence must be null or between 0 and 1');
  factory _TranscriptWord.fromJson(Map<String, dynamic> json) => _$TranscriptWordFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'word_id') final  String wordId;
@override@JsonKey(name: 'segment_id') final  String segmentId;
@override final  String text;
@override@JsonKey(name: 'start_ms') final  int startMs;
@override@JsonKey(name: 'end_ms') final  int endMs;
@override final  double? confidence;

/// Create a copy of TranscriptWord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranscriptWordCopyWith<_TranscriptWord> get copyWith => __$TranscriptWordCopyWithImpl<_TranscriptWord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranscriptWordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranscriptWord&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.wordId, wordId) || other.wordId == wordId)&&(identical(other.segmentId, segmentId) || other.segmentId == segmentId)&&(identical(other.text, text) || other.text == text)&&(identical(other.startMs, startMs) || other.startMs == startMs)&&(identical(other.endMs, endMs) || other.endMs == endMs)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,wordId,segmentId,text,startMs,endMs,confidence);

@override
String toString() {
  return 'TranscriptWord(schemaVersion: $schemaVersion, wordId: $wordId, segmentId: $segmentId, text: $text, startMs: $startMs, endMs: $endMs, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$TranscriptWordCopyWith<$Res> implements $TranscriptWordCopyWith<$Res> {
  factory _$TranscriptWordCopyWith(_TranscriptWord value, $Res Function(_TranscriptWord) _then) = __$TranscriptWordCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'word_id') String wordId,@JsonKey(name: 'segment_id') String segmentId, String text,@JsonKey(name: 'start_ms') int startMs,@JsonKey(name: 'end_ms') int endMs, double? confidence
});




}
/// @nodoc
class __$TranscriptWordCopyWithImpl<$Res>
    implements _$TranscriptWordCopyWith<$Res> {
  __$TranscriptWordCopyWithImpl(this._self, this._then);

  final _TranscriptWord _self;
  final $Res Function(_TranscriptWord) _then;

/// Create a copy of TranscriptWord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? wordId = null,Object? segmentId = null,Object? text = null,Object? startMs = null,Object? endMs = null,Object? confidence = freezed,}) {
  return _then(_TranscriptWord(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,wordId: null == wordId ? _self.wordId : wordId // ignore: cast_nullable_to_non_nullable
as String,segmentId: null == segmentId ? _self.segmentId : segmentId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,startMs: null == startMs ? _self.startMs : startMs // ignore: cast_nullable_to_non_nullable
as int,endMs: null == endMs ? _self.endMs : endMs // ignore: cast_nullable_to_non_nullable
as int,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$GlossaryHit {

@JsonKey(name: 'schema_version') String get schemaVersion; String get term;@JsonKey(name: 'normalized_term') String get normalizedTerm;@JsonKey(name: 'word_ids') List<String> get wordIds; double? get confidence; String? get source;
/// Create a copy of GlossaryHit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GlossaryHitCopyWith<GlossaryHit> get copyWith => _$GlossaryHitCopyWithImpl<GlossaryHit>(this as GlossaryHit, _$identity);

  /// Serializes this GlossaryHit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GlossaryHit&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.term, term) || other.term == term)&&(identical(other.normalizedTerm, normalizedTerm) || other.normalizedTerm == normalizedTerm)&&const DeepCollectionEquality().equals(other.wordIds, wordIds)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,term,normalizedTerm,const DeepCollectionEquality().hash(wordIds),confidence,source);

@override
String toString() {
  return 'GlossaryHit(schemaVersion: $schemaVersion, term: $term, normalizedTerm: $normalizedTerm, wordIds: $wordIds, confidence: $confidence, source: $source)';
}


}

/// @nodoc
abstract mixin class $GlossaryHitCopyWith<$Res>  {
  factory $GlossaryHitCopyWith(GlossaryHit value, $Res Function(GlossaryHit) _then) = _$GlossaryHitCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion, String term,@JsonKey(name: 'normalized_term') String normalizedTerm,@JsonKey(name: 'word_ids') List<String> wordIds, double? confidence, String? source
});




}
/// @nodoc
class _$GlossaryHitCopyWithImpl<$Res>
    implements $GlossaryHitCopyWith<$Res> {
  _$GlossaryHitCopyWithImpl(this._self, this._then);

  final GlossaryHit _self;
  final $Res Function(GlossaryHit) _then;

/// Create a copy of GlossaryHit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? term = null,Object? normalizedTerm = null,Object? wordIds = null,Object? confidence = freezed,Object? source = freezed,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,normalizedTerm: null == normalizedTerm ? _self.normalizedTerm : normalizedTerm // ignore: cast_nullable_to_non_nullable
as String,wordIds: null == wordIds ? _self.wordIds : wordIds // ignore: cast_nullable_to_non_nullable
as List<String>,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GlossaryHit].
extension GlossaryHitPatterns on GlossaryHit {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GlossaryHit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GlossaryHit() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GlossaryHit value)  $default,){
final _that = this;
switch (_that) {
case _GlossaryHit():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GlossaryHit value)?  $default,){
final _that = this;
switch (_that) {
case _GlossaryHit() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion,  String term, @JsonKey(name: 'normalized_term')  String normalizedTerm, @JsonKey(name: 'word_ids')  List<String> wordIds,  double? confidence,  String? source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GlossaryHit() when $default != null:
return $default(_that.schemaVersion,_that.term,_that.normalizedTerm,_that.wordIds,_that.confidence,_that.source);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion,  String term, @JsonKey(name: 'normalized_term')  String normalizedTerm, @JsonKey(name: 'word_ids')  List<String> wordIds,  double? confidence,  String? source)  $default,) {final _that = this;
switch (_that) {
case _GlossaryHit():
return $default(_that.schemaVersion,_that.term,_that.normalizedTerm,_that.wordIds,_that.confidence,_that.source);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion,  String term, @JsonKey(name: 'normalized_term')  String normalizedTerm, @JsonKey(name: 'word_ids')  List<String> wordIds,  double? confidence,  String? source)?  $default,) {final _that = this;
switch (_that) {
case _GlossaryHit() when $default != null:
return $default(_that.schemaVersion,_that.term,_that.normalizedTerm,_that.wordIds,_that.confidence,_that.source);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _GlossaryHit implements GlossaryHit {
  const _GlossaryHit({@JsonKey(name: 'schema_version') this.schemaVersion = kGlossaryHitSchemaVersion, required this.term, @JsonKey(name: 'normalized_term') required this.normalizedTerm, @JsonKey(name: 'word_ids') final  List<String> wordIds = const <String>[], this.confidence, this.source}): assert(confidence == null || (confidence >= 0 && confidence <= 1), 'confidence must be null or between 0 and 1'),_wordIds = wordIds;
  factory _GlossaryHit.fromJson(Map<String, dynamic> json) => _$GlossaryHitFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override final  String term;
@override@JsonKey(name: 'normalized_term') final  String normalizedTerm;
 final  List<String> _wordIds;
@override@JsonKey(name: 'word_ids') List<String> get wordIds {
  if (_wordIds is EqualUnmodifiableListView) return _wordIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wordIds);
}

@override final  double? confidence;
@override final  String? source;

/// Create a copy of GlossaryHit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GlossaryHitCopyWith<_GlossaryHit> get copyWith => __$GlossaryHitCopyWithImpl<_GlossaryHit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GlossaryHitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GlossaryHit&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.term, term) || other.term == term)&&(identical(other.normalizedTerm, normalizedTerm) || other.normalizedTerm == normalizedTerm)&&const DeepCollectionEquality().equals(other._wordIds, _wordIds)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.source, source) || other.source == source));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,term,normalizedTerm,const DeepCollectionEquality().hash(_wordIds),confidence,source);

@override
String toString() {
  return 'GlossaryHit(schemaVersion: $schemaVersion, term: $term, normalizedTerm: $normalizedTerm, wordIds: $wordIds, confidence: $confidence, source: $source)';
}


}

/// @nodoc
abstract mixin class _$GlossaryHitCopyWith<$Res> implements $GlossaryHitCopyWith<$Res> {
  factory _$GlossaryHitCopyWith(_GlossaryHit value, $Res Function(_GlossaryHit) _then) = __$GlossaryHitCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion, String term,@JsonKey(name: 'normalized_term') String normalizedTerm,@JsonKey(name: 'word_ids') List<String> wordIds, double? confidence, String? source
});




}
/// @nodoc
class __$GlossaryHitCopyWithImpl<$Res>
    implements _$GlossaryHitCopyWith<$Res> {
  __$GlossaryHitCopyWithImpl(this._self, this._then);

  final _GlossaryHit _self;
  final $Res Function(_GlossaryHit) _then;

/// Create a copy of GlossaryHit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? term = null,Object? normalizedTerm = null,Object? wordIds = null,Object? confidence = freezed,Object? source = freezed,}) {
  return _then(_GlossaryHit(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,term: null == term ? _self.term : term // ignore: cast_nullable_to_non_nullable
as String,normalizedTerm: null == normalizedTerm ? _self.normalizedTerm : normalizedTerm // ignore: cast_nullable_to_non_nullable
as String,wordIds: null == wordIds ? _self._wordIds : wordIds // ignore: cast_nullable_to_non_nullable
as List<String>,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Transcript {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'transcript_id') String get transcriptId; List<TranscriptSegment> get segments; List<TranscriptWord> get words;@JsonKey(name: 'engine_id') String get engineId;@JsonKey(name: 'engine_version') String get engineVersion;@JsonKey(name: 'glossary_hits') List<GlossaryHit> get glossaryHits;@JsonKey(name: 'transcript_policy_version') String get transcriptPolicyVersion; String get locale;@JsonKey(name: 'recorded_at') DateTime get recordedAt;@JsonKey(name: 'source_uri') String get sourceUri;@JsonKey(name: 'duration_ms') int get durationMs;
/// Create a copy of Transcript
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranscriptCopyWith<Transcript> get copyWith => _$TranscriptCopyWithImpl<Transcript>(this as Transcript, _$identity);

  /// Serializes this Transcript to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transcript&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.transcriptId, transcriptId) || other.transcriptId == transcriptId)&&const DeepCollectionEquality().equals(other.segments, segments)&&const DeepCollectionEquality().equals(other.words, words)&&(identical(other.engineId, engineId) || other.engineId == engineId)&&(identical(other.engineVersion, engineVersion) || other.engineVersion == engineVersion)&&const DeepCollectionEquality().equals(other.glossaryHits, glossaryHits)&&(identical(other.transcriptPolicyVersion, transcriptPolicyVersion) || other.transcriptPolicyVersion == transcriptPolicyVersion)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt)&&(identical(other.sourceUri, sourceUri) || other.sourceUri == sourceUri)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,transcriptId,const DeepCollectionEquality().hash(segments),const DeepCollectionEquality().hash(words),engineId,engineVersion,const DeepCollectionEquality().hash(glossaryHits),transcriptPolicyVersion,locale,recordedAt,sourceUri,durationMs);

@override
String toString() {
  return 'Transcript(schemaVersion: $schemaVersion, transcriptId: $transcriptId, segments: $segments, words: $words, engineId: $engineId, engineVersion: $engineVersion, glossaryHits: $glossaryHits, transcriptPolicyVersion: $transcriptPolicyVersion, locale: $locale, recordedAt: $recordedAt, sourceUri: $sourceUri, durationMs: $durationMs)';
}


}

/// @nodoc
abstract mixin class $TranscriptCopyWith<$Res>  {
  factory $TranscriptCopyWith(Transcript value, $Res Function(Transcript) _then) = _$TranscriptCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'transcript_id') String transcriptId, List<TranscriptSegment> segments, List<TranscriptWord> words,@JsonKey(name: 'engine_id') String engineId,@JsonKey(name: 'engine_version') String engineVersion,@JsonKey(name: 'glossary_hits') List<GlossaryHit> glossaryHits,@JsonKey(name: 'transcript_policy_version') String transcriptPolicyVersion, String locale,@JsonKey(name: 'recorded_at') DateTime recordedAt,@JsonKey(name: 'source_uri') String sourceUri,@JsonKey(name: 'duration_ms') int durationMs
});




}
/// @nodoc
class _$TranscriptCopyWithImpl<$Res>
    implements $TranscriptCopyWith<$Res> {
  _$TranscriptCopyWithImpl(this._self, this._then);

  final Transcript _self;
  final $Res Function(Transcript) _then;

/// Create a copy of Transcript
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? transcriptId = null,Object? segments = null,Object? words = null,Object? engineId = null,Object? engineVersion = null,Object? glossaryHits = null,Object? transcriptPolicyVersion = null,Object? locale = null,Object? recordedAt = null,Object? sourceUri = null,Object? durationMs = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,transcriptId: null == transcriptId ? _self.transcriptId : transcriptId // ignore: cast_nullable_to_non_nullable
as String,segments: null == segments ? _self.segments : segments // ignore: cast_nullable_to_non_nullable
as List<TranscriptSegment>,words: null == words ? _self.words : words // ignore: cast_nullable_to_non_nullable
as List<TranscriptWord>,engineId: null == engineId ? _self.engineId : engineId // ignore: cast_nullable_to_non_nullable
as String,engineVersion: null == engineVersion ? _self.engineVersion : engineVersion // ignore: cast_nullable_to_non_nullable
as String,glossaryHits: null == glossaryHits ? _self.glossaryHits : glossaryHits // ignore: cast_nullable_to_non_nullable
as List<GlossaryHit>,transcriptPolicyVersion: null == transcriptPolicyVersion ? _self.transcriptPolicyVersion : transcriptPolicyVersion // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceUri: null == sourceUri ? _self.sourceUri : sourceUri // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Transcript].
extension TranscriptPatterns on Transcript {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transcript value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transcript() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transcript value)  $default,){
final _that = this;
switch (_that) {
case _Transcript():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transcript value)?  $default,){
final _that = this;
switch (_that) {
case _Transcript() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'transcript_id')  String transcriptId,  List<TranscriptSegment> segments,  List<TranscriptWord> words, @JsonKey(name: 'engine_id')  String engineId, @JsonKey(name: 'engine_version')  String engineVersion, @JsonKey(name: 'glossary_hits')  List<GlossaryHit> glossaryHits, @JsonKey(name: 'transcript_policy_version')  String transcriptPolicyVersion,  String locale, @JsonKey(name: 'recorded_at')  DateTime recordedAt, @JsonKey(name: 'source_uri')  String sourceUri, @JsonKey(name: 'duration_ms')  int durationMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transcript() when $default != null:
return $default(_that.schemaVersion,_that.transcriptId,_that.segments,_that.words,_that.engineId,_that.engineVersion,_that.glossaryHits,_that.transcriptPolicyVersion,_that.locale,_that.recordedAt,_that.sourceUri,_that.durationMs);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'transcript_id')  String transcriptId,  List<TranscriptSegment> segments,  List<TranscriptWord> words, @JsonKey(name: 'engine_id')  String engineId, @JsonKey(name: 'engine_version')  String engineVersion, @JsonKey(name: 'glossary_hits')  List<GlossaryHit> glossaryHits, @JsonKey(name: 'transcript_policy_version')  String transcriptPolicyVersion,  String locale, @JsonKey(name: 'recorded_at')  DateTime recordedAt, @JsonKey(name: 'source_uri')  String sourceUri, @JsonKey(name: 'duration_ms')  int durationMs)  $default,) {final _that = this;
switch (_that) {
case _Transcript():
return $default(_that.schemaVersion,_that.transcriptId,_that.segments,_that.words,_that.engineId,_that.engineVersion,_that.glossaryHits,_that.transcriptPolicyVersion,_that.locale,_that.recordedAt,_that.sourceUri,_that.durationMs);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'transcript_id')  String transcriptId,  List<TranscriptSegment> segments,  List<TranscriptWord> words, @JsonKey(name: 'engine_id')  String engineId, @JsonKey(name: 'engine_version')  String engineVersion, @JsonKey(name: 'glossary_hits')  List<GlossaryHit> glossaryHits, @JsonKey(name: 'transcript_policy_version')  String transcriptPolicyVersion,  String locale, @JsonKey(name: 'recorded_at')  DateTime recordedAt, @JsonKey(name: 'source_uri')  String sourceUri, @JsonKey(name: 'duration_ms')  int durationMs)?  $default,) {final _that = this;
switch (_that) {
case _Transcript() when $default != null:
return $default(_that.schemaVersion,_that.transcriptId,_that.segments,_that.words,_that.engineId,_that.engineVersion,_that.glossaryHits,_that.transcriptPolicyVersion,_that.locale,_that.recordedAt,_that.sourceUri,_that.durationMs);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Transcript implements Transcript {
  const _Transcript({@JsonKey(name: 'schema_version') this.schemaVersion = kTranscriptSchemaVersion, @JsonKey(name: 'transcript_id') required this.transcriptId, required final  List<TranscriptSegment> segments, required final  List<TranscriptWord> words, @JsonKey(name: 'engine_id') required this.engineId, @JsonKey(name: 'engine_version') required this.engineVersion, @JsonKey(name: 'glossary_hits') required final  List<GlossaryHit> glossaryHits, @JsonKey(name: 'transcript_policy_version') required this.transcriptPolicyVersion, required this.locale, @JsonKey(name: 'recorded_at') required this.recordedAt, @JsonKey(name: 'source_uri') required this.sourceUri, @JsonKey(name: 'duration_ms') required this.durationMs}): assert(durationMs >= 0, 'durationMs must be non-negative'),_segments = segments,_words = words,_glossaryHits = glossaryHits;
  factory _Transcript.fromJson(Map<String, dynamic> json) => _$TranscriptFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'transcript_id') final  String transcriptId;
 final  List<TranscriptSegment> _segments;
@override List<TranscriptSegment> get segments {
  if (_segments is EqualUnmodifiableListView) return _segments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_segments);
}

 final  List<TranscriptWord> _words;
@override List<TranscriptWord> get words {
  if (_words is EqualUnmodifiableListView) return _words;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_words);
}

@override@JsonKey(name: 'engine_id') final  String engineId;
@override@JsonKey(name: 'engine_version') final  String engineVersion;
 final  List<GlossaryHit> _glossaryHits;
@override@JsonKey(name: 'glossary_hits') List<GlossaryHit> get glossaryHits {
  if (_glossaryHits is EqualUnmodifiableListView) return _glossaryHits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_glossaryHits);
}

@override@JsonKey(name: 'transcript_policy_version') final  String transcriptPolicyVersion;
@override final  String locale;
@override@JsonKey(name: 'recorded_at') final  DateTime recordedAt;
@override@JsonKey(name: 'source_uri') final  String sourceUri;
@override@JsonKey(name: 'duration_ms') final  int durationMs;

/// Create a copy of Transcript
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranscriptCopyWith<_Transcript> get copyWith => __$TranscriptCopyWithImpl<_Transcript>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranscriptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transcript&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.transcriptId, transcriptId) || other.transcriptId == transcriptId)&&const DeepCollectionEquality().equals(other._segments, _segments)&&const DeepCollectionEquality().equals(other._words, _words)&&(identical(other.engineId, engineId) || other.engineId == engineId)&&(identical(other.engineVersion, engineVersion) || other.engineVersion == engineVersion)&&const DeepCollectionEquality().equals(other._glossaryHits, _glossaryHits)&&(identical(other.transcriptPolicyVersion, transcriptPolicyVersion) || other.transcriptPolicyVersion == transcriptPolicyVersion)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt)&&(identical(other.sourceUri, sourceUri) || other.sourceUri == sourceUri)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,transcriptId,const DeepCollectionEquality().hash(_segments),const DeepCollectionEquality().hash(_words),engineId,engineVersion,const DeepCollectionEquality().hash(_glossaryHits),transcriptPolicyVersion,locale,recordedAt,sourceUri,durationMs);

@override
String toString() {
  return 'Transcript(schemaVersion: $schemaVersion, transcriptId: $transcriptId, segments: $segments, words: $words, engineId: $engineId, engineVersion: $engineVersion, glossaryHits: $glossaryHits, transcriptPolicyVersion: $transcriptPolicyVersion, locale: $locale, recordedAt: $recordedAt, sourceUri: $sourceUri, durationMs: $durationMs)';
}


}

/// @nodoc
abstract mixin class _$TranscriptCopyWith<$Res> implements $TranscriptCopyWith<$Res> {
  factory _$TranscriptCopyWith(_Transcript value, $Res Function(_Transcript) _then) = __$TranscriptCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'transcript_id') String transcriptId, List<TranscriptSegment> segments, List<TranscriptWord> words,@JsonKey(name: 'engine_id') String engineId,@JsonKey(name: 'engine_version') String engineVersion,@JsonKey(name: 'glossary_hits') List<GlossaryHit> glossaryHits,@JsonKey(name: 'transcript_policy_version') String transcriptPolicyVersion, String locale,@JsonKey(name: 'recorded_at') DateTime recordedAt,@JsonKey(name: 'source_uri') String sourceUri,@JsonKey(name: 'duration_ms') int durationMs
});




}
/// @nodoc
class __$TranscriptCopyWithImpl<$Res>
    implements _$TranscriptCopyWith<$Res> {
  __$TranscriptCopyWithImpl(this._self, this._then);

  final _Transcript _self;
  final $Res Function(_Transcript) _then;

/// Create a copy of Transcript
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? transcriptId = null,Object? segments = null,Object? words = null,Object? engineId = null,Object? engineVersion = null,Object? glossaryHits = null,Object? transcriptPolicyVersion = null,Object? locale = null,Object? recordedAt = null,Object? sourceUri = null,Object? durationMs = null,}) {
  return _then(_Transcript(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,transcriptId: null == transcriptId ? _self.transcriptId : transcriptId // ignore: cast_nullable_to_non_nullable
as String,segments: null == segments ? _self._segments : segments // ignore: cast_nullable_to_non_nullable
as List<TranscriptSegment>,words: null == words ? _self._words : words // ignore: cast_nullable_to_non_nullable
as List<TranscriptWord>,engineId: null == engineId ? _self.engineId : engineId // ignore: cast_nullable_to_non_nullable
as String,engineVersion: null == engineVersion ? _self.engineVersion : engineVersion // ignore: cast_nullable_to_non_nullable
as String,glossaryHits: null == glossaryHits ? _self._glossaryHits : glossaryHits // ignore: cast_nullable_to_non_nullable
as List<GlossaryHit>,transcriptPolicyVersion: null == transcriptPolicyVersion ? _self.transcriptPolicyVersion : transcriptPolicyVersion // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceUri: null == sourceUri ? _self.sourceUri : sourceUri // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
