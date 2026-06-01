// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'common_contracts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EvidenceSpan {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'source_id') String get sourceId;@JsonKey(name: 'source_type') String get sourceType;@JsonKey(name: 'start_offset') int get startOffset;@JsonKey(name: 'end_offset') int get endOffset; String? get quote; Map<String, Object?> get metadata;
/// Create a copy of EvidenceSpan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvidenceSpanCopyWith<EvidenceSpan> get copyWith => _$EvidenceSpanCopyWithImpl<EvidenceSpan>(this as EvidenceSpan, _$identity);

  /// Serializes this EvidenceSpan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EvidenceSpan&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.startOffset, startOffset) || other.startOffset == startOffset)&&(identical(other.endOffset, endOffset) || other.endOffset == endOffset)&&(identical(other.quote, quote) || other.quote == quote)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,sourceId,sourceType,startOffset,endOffset,quote,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'EvidenceSpan(schemaVersion: $schemaVersion, sourceId: $sourceId, sourceType: $sourceType, startOffset: $startOffset, endOffset: $endOffset, quote: $quote, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $EvidenceSpanCopyWith<$Res>  {
  factory $EvidenceSpanCopyWith(EvidenceSpan value, $Res Function(EvidenceSpan) _then) = _$EvidenceSpanCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'source_id') String sourceId,@JsonKey(name: 'source_type') String sourceType,@JsonKey(name: 'start_offset') int startOffset,@JsonKey(name: 'end_offset') int endOffset, String? quote, Map<String, Object?> metadata
});




}
/// @nodoc
class _$EvidenceSpanCopyWithImpl<$Res>
    implements $EvidenceSpanCopyWith<$Res> {
  _$EvidenceSpanCopyWithImpl(this._self, this._then);

  final EvidenceSpan _self;
  final $Res Function(EvidenceSpan) _then;

/// Create a copy of EvidenceSpan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? sourceId = null,Object? sourceType = null,Object? startOffset = null,Object? endOffset = null,Object? quote = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,startOffset: null == startOffset ? _self.startOffset : startOffset // ignore: cast_nullable_to_non_nullable
as int,endOffset: null == endOffset ? _self.endOffset : endOffset // ignore: cast_nullable_to_non_nullable
as int,quote: freezed == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [EvidenceSpan].
extension EvidenceSpanPatterns on EvidenceSpan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EvidenceSpan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EvidenceSpan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EvidenceSpan value)  $default,){
final _that = this;
switch (_that) {
case _EvidenceSpan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EvidenceSpan value)?  $default,){
final _that = this;
switch (_that) {
case _EvidenceSpan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'source_id')  String sourceId, @JsonKey(name: 'source_type')  String sourceType, @JsonKey(name: 'start_offset')  int startOffset, @JsonKey(name: 'end_offset')  int endOffset,  String? quote,  Map<String, Object?> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EvidenceSpan() when $default != null:
return $default(_that.schemaVersion,_that.sourceId,_that.sourceType,_that.startOffset,_that.endOffset,_that.quote,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'source_id')  String sourceId, @JsonKey(name: 'source_type')  String sourceType, @JsonKey(name: 'start_offset')  int startOffset, @JsonKey(name: 'end_offset')  int endOffset,  String? quote,  Map<String, Object?> metadata)  $default,) {final _that = this;
switch (_that) {
case _EvidenceSpan():
return $default(_that.schemaVersion,_that.sourceId,_that.sourceType,_that.startOffset,_that.endOffset,_that.quote,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'source_id')  String sourceId, @JsonKey(name: 'source_type')  String sourceType, @JsonKey(name: 'start_offset')  int startOffset, @JsonKey(name: 'end_offset')  int endOffset,  String? quote,  Map<String, Object?> metadata)?  $default,) {final _that = this;
switch (_that) {
case _EvidenceSpan() when $default != null:
return $default(_that.schemaVersion,_that.sourceId,_that.sourceType,_that.startOffset,_that.endOffset,_that.quote,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _EvidenceSpan implements EvidenceSpan {
  const _EvidenceSpan({@JsonKey(name: 'schema_version') this.schemaVersion = kEvidenceSpanSchemaVersion, @JsonKey(name: 'source_id') required this.sourceId, @JsonKey(name: 'source_type') required this.sourceType, @JsonKey(name: 'start_offset') required this.startOffset, @JsonKey(name: 'end_offset') required this.endOffset, this.quote, final  Map<String, Object?> metadata = const <String, Object?>{}}): assert(startOffset >= 0, 'startOffset must be non-negative'),assert(endOffset >= startOffset, 'endOffset must be >= startOffset'),_metadata = metadata;
  factory _EvidenceSpan.fromJson(Map<String, dynamic> json) => _$EvidenceSpanFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'source_id') final  String sourceId;
@override@JsonKey(name: 'source_type') final  String sourceType;
@override@JsonKey(name: 'start_offset') final  int startOffset;
@override@JsonKey(name: 'end_offset') final  int endOffset;
@override final  String? quote;
 final  Map<String, Object?> _metadata;
@override@JsonKey() Map<String, Object?> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of EvidenceSpan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EvidenceSpanCopyWith<_EvidenceSpan> get copyWith => __$EvidenceSpanCopyWithImpl<_EvidenceSpan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EvidenceSpanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EvidenceSpan&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.startOffset, startOffset) || other.startOffset == startOffset)&&(identical(other.endOffset, endOffset) || other.endOffset == endOffset)&&(identical(other.quote, quote) || other.quote == quote)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,sourceId,sourceType,startOffset,endOffset,quote,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'EvidenceSpan(schemaVersion: $schemaVersion, sourceId: $sourceId, sourceType: $sourceType, startOffset: $startOffset, endOffset: $endOffset, quote: $quote, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$EvidenceSpanCopyWith<$Res> implements $EvidenceSpanCopyWith<$Res> {
  factory _$EvidenceSpanCopyWith(_EvidenceSpan value, $Res Function(_EvidenceSpan) _then) = __$EvidenceSpanCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'source_id') String sourceId,@JsonKey(name: 'source_type') String sourceType,@JsonKey(name: 'start_offset') int startOffset,@JsonKey(name: 'end_offset') int endOffset, String? quote, Map<String, Object?> metadata
});




}
/// @nodoc
class __$EvidenceSpanCopyWithImpl<$Res>
    implements _$EvidenceSpanCopyWith<$Res> {
  __$EvidenceSpanCopyWithImpl(this._self, this._then);

  final _EvidenceSpan _self;
  final $Res Function(_EvidenceSpan) _then;

/// Create a copy of EvidenceSpan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? sourceId = null,Object? sourceType = null,Object? startOffset = null,Object? endOffset = null,Object? quote = freezed,Object? metadata = null,}) {
  return _then(_EvidenceSpan(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,startOffset: null == startOffset ? _self.startOffset : startOffset // ignore: cast_nullable_to_non_nullable
as int,endOffset: null == endOffset ? _self.endOffset : endOffset // ignore: cast_nullable_to_non_nullable
as int,quote: freezed == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as String?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}

// dart format on
