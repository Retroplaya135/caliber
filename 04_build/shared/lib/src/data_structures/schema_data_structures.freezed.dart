// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schema_data_structures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CorpusQuery {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'query_id') String get queryId;@JsonKey(name: 'query_text') String get queryText; TargetRoleCompany get target;@JsonKey(name: 'corpus_bundle_version') String get corpusBundleVersion; Map<String, String> get filters;@JsonKey(name: 'limit') int get limit;
/// Create a copy of CorpusQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CorpusQueryCopyWith<CorpusQuery> get copyWith => _$CorpusQueryCopyWithImpl<CorpusQuery>(this as CorpusQuery, _$identity);

  /// Serializes this CorpusQuery to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CorpusQuery&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.queryId, queryId) || other.queryId == queryId)&&(identical(other.queryText, queryText) || other.queryText == queryText)&&(identical(other.target, target) || other.target == target)&&(identical(other.corpusBundleVersion, corpusBundleVersion) || other.corpusBundleVersion == corpusBundleVersion)&&const DeepCollectionEquality().equals(other.filters, filters)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,queryId,queryText,target,corpusBundleVersion,const DeepCollectionEquality().hash(filters),limit);

@override
String toString() {
  return 'CorpusQuery(schemaVersion: $schemaVersion, queryId: $queryId, queryText: $queryText, target: $target, corpusBundleVersion: $corpusBundleVersion, filters: $filters, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $CorpusQueryCopyWith<$Res>  {
  factory $CorpusQueryCopyWith(CorpusQuery value, $Res Function(CorpusQuery) _then) = _$CorpusQueryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'query_id') String queryId,@JsonKey(name: 'query_text') String queryText, TargetRoleCompany target,@JsonKey(name: 'corpus_bundle_version') String corpusBundleVersion, Map<String, String> filters,@JsonKey(name: 'limit') int limit
});


$TargetRoleCompanyCopyWith<$Res> get target;

}
/// @nodoc
class _$CorpusQueryCopyWithImpl<$Res>
    implements $CorpusQueryCopyWith<$Res> {
  _$CorpusQueryCopyWithImpl(this._self, this._then);

  final CorpusQuery _self;
  final $Res Function(CorpusQuery) _then;

/// Create a copy of CorpusQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? queryId = null,Object? queryText = null,Object? target = null,Object? corpusBundleVersion = null,Object? filters = null,Object? limit = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,queryId: null == queryId ? _self.queryId : queryId // ignore: cast_nullable_to_non_nullable
as String,queryText: null == queryText ? _self.queryText : queryText // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as TargetRoleCompany,corpusBundleVersion: null == corpusBundleVersion ? _self.corpusBundleVersion : corpusBundleVersion // ignore: cast_nullable_to_non_nullable
as String,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as Map<String, String>,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of CorpusQuery
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetRoleCompanyCopyWith<$Res> get target {
  
  return $TargetRoleCompanyCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}


/// Adds pattern-matching-related methods to [CorpusQuery].
extension CorpusQueryPatterns on CorpusQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CorpusQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CorpusQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CorpusQuery value)  $default,){
final _that = this;
switch (_that) {
case _CorpusQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CorpusQuery value)?  $default,){
final _that = this;
switch (_that) {
case _CorpusQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'query_id')  String queryId, @JsonKey(name: 'query_text')  String queryText,  TargetRoleCompany target, @JsonKey(name: 'corpus_bundle_version')  String corpusBundleVersion,  Map<String, String> filters, @JsonKey(name: 'limit')  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CorpusQuery() when $default != null:
return $default(_that.schemaVersion,_that.queryId,_that.queryText,_that.target,_that.corpusBundleVersion,_that.filters,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'query_id')  String queryId, @JsonKey(name: 'query_text')  String queryText,  TargetRoleCompany target, @JsonKey(name: 'corpus_bundle_version')  String corpusBundleVersion,  Map<String, String> filters, @JsonKey(name: 'limit')  int limit)  $default,) {final _that = this;
switch (_that) {
case _CorpusQuery():
return $default(_that.schemaVersion,_that.queryId,_that.queryText,_that.target,_that.corpusBundleVersion,_that.filters,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'query_id')  String queryId, @JsonKey(name: 'query_text')  String queryText,  TargetRoleCompany target, @JsonKey(name: 'corpus_bundle_version')  String corpusBundleVersion,  Map<String, String> filters, @JsonKey(name: 'limit')  int limit)?  $default,) {final _that = this;
switch (_that) {
case _CorpusQuery() when $default != null:
return $default(_that.schemaVersion,_that.queryId,_that.queryText,_that.target,_that.corpusBundleVersion,_that.filters,_that.limit);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CorpusQuery implements CorpusQuery {
  const _CorpusQuery({@JsonKey(name: 'schema_version') this.schemaVersion = kCorpusQuerySchemaVersion, @JsonKey(name: 'query_id') required this.queryId, @JsonKey(name: 'query_text') required this.queryText, required this.target, @JsonKey(name: 'corpus_bundle_version') required this.corpusBundleVersion, final  Map<String, String> filters = const <String, String>{}, @JsonKey(name: 'limit') this.limit = 10}): _filters = filters;
  factory _CorpusQuery.fromJson(Map<String, dynamic> json) => _$CorpusQueryFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'query_id') final  String queryId;
@override@JsonKey(name: 'query_text') final  String queryText;
@override final  TargetRoleCompany target;
@override@JsonKey(name: 'corpus_bundle_version') final  String corpusBundleVersion;
 final  Map<String, String> _filters;
@override@JsonKey() Map<String, String> get filters {
  if (_filters is EqualUnmodifiableMapView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_filters);
}

@override@JsonKey(name: 'limit') final  int limit;

/// Create a copy of CorpusQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CorpusQueryCopyWith<_CorpusQuery> get copyWith => __$CorpusQueryCopyWithImpl<_CorpusQuery>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CorpusQueryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CorpusQuery&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.queryId, queryId) || other.queryId == queryId)&&(identical(other.queryText, queryText) || other.queryText == queryText)&&(identical(other.target, target) || other.target == target)&&(identical(other.corpusBundleVersion, corpusBundleVersion) || other.corpusBundleVersion == corpusBundleVersion)&&const DeepCollectionEquality().equals(other._filters, _filters)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,queryId,queryText,target,corpusBundleVersion,const DeepCollectionEquality().hash(_filters),limit);

@override
String toString() {
  return 'CorpusQuery(schemaVersion: $schemaVersion, queryId: $queryId, queryText: $queryText, target: $target, corpusBundleVersion: $corpusBundleVersion, filters: $filters, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$CorpusQueryCopyWith<$Res> implements $CorpusQueryCopyWith<$Res> {
  factory _$CorpusQueryCopyWith(_CorpusQuery value, $Res Function(_CorpusQuery) _then) = __$CorpusQueryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'query_id') String queryId,@JsonKey(name: 'query_text') String queryText, TargetRoleCompany target,@JsonKey(name: 'corpus_bundle_version') String corpusBundleVersion, Map<String, String> filters,@JsonKey(name: 'limit') int limit
});


@override $TargetRoleCompanyCopyWith<$Res> get target;

}
/// @nodoc
class __$CorpusQueryCopyWithImpl<$Res>
    implements _$CorpusQueryCopyWith<$Res> {
  __$CorpusQueryCopyWithImpl(this._self, this._then);

  final _CorpusQuery _self;
  final $Res Function(_CorpusQuery) _then;

/// Create a copy of CorpusQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? queryId = null,Object? queryText = null,Object? target = null,Object? corpusBundleVersion = null,Object? filters = null,Object? limit = null,}) {
  return _then(_CorpusQuery(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,queryId: null == queryId ? _self.queryId : queryId // ignore: cast_nullable_to_non_nullable
as String,queryText: null == queryText ? _self.queryText : queryText // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as TargetRoleCompany,corpusBundleVersion: null == corpusBundleVersion ? _self.corpusBundleVersion : corpusBundleVersion // ignore: cast_nullable_to_non_nullable
as String,filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as Map<String, String>,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of CorpusQuery
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetRoleCompanyCopyWith<$Res> get target {
  
  return $TargetRoleCompanyCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}


/// @nodoc
mixin _$CorpusHit {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'record_id') String get recordId;@JsonKey(name: 'bundle_id') String get bundleId;@JsonKey(name: 'bundle_version') String get bundleVersion; double get score;@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans; Map<String, Object?> get metadata;
/// Create a copy of CorpusHit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CorpusHitCopyWith<CorpusHit> get copyWith => _$CorpusHitCopyWithImpl<CorpusHit>(this as CorpusHit, _$identity);

  /// Serializes this CorpusHit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CorpusHit&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.recordId, recordId) || other.recordId == recordId)&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId)&&(identical(other.bundleVersion, bundleVersion) || other.bundleVersion == bundleVersion)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other.evidenceSpans, evidenceSpans)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,recordId,bundleId,bundleVersion,score,const DeepCollectionEquality().hash(evidenceSpans),const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'CorpusHit(schemaVersion: $schemaVersion, recordId: $recordId, bundleId: $bundleId, bundleVersion: $bundleVersion, score: $score, evidenceSpans: $evidenceSpans, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $CorpusHitCopyWith<$Res>  {
  factory $CorpusHitCopyWith(CorpusHit value, $Res Function(CorpusHit) _then) = _$CorpusHitCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'record_id') String recordId,@JsonKey(name: 'bundle_id') String bundleId,@JsonKey(name: 'bundle_version') String bundleVersion, double score,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans, Map<String, Object?> metadata
});




}
/// @nodoc
class _$CorpusHitCopyWithImpl<$Res>
    implements $CorpusHitCopyWith<$Res> {
  _$CorpusHitCopyWithImpl(this._self, this._then);

  final CorpusHit _self;
  final $Res Function(CorpusHit) _then;

/// Create a copy of CorpusHit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? recordId = null,Object? bundleId = null,Object? bundleVersion = null,Object? score = null,Object? evidenceSpans = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,recordId: null == recordId ? _self.recordId : recordId // ignore: cast_nullable_to_non_nullable
as String,bundleId: null == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String,bundleVersion: null == bundleVersion ? _self.bundleVersion : bundleVersion // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,evidenceSpans: null == evidenceSpans ? _self.evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [CorpusHit].
extension CorpusHitPatterns on CorpusHit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CorpusHit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CorpusHit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CorpusHit value)  $default,){
final _that = this;
switch (_that) {
case _CorpusHit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CorpusHit value)?  $default,){
final _that = this;
switch (_that) {
case _CorpusHit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'record_id')  String recordId, @JsonKey(name: 'bundle_id')  String bundleId, @JsonKey(name: 'bundle_version')  String bundleVersion,  double score, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans,  Map<String, Object?> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CorpusHit() when $default != null:
return $default(_that.schemaVersion,_that.recordId,_that.bundleId,_that.bundleVersion,_that.score,_that.evidenceSpans,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'record_id')  String recordId, @JsonKey(name: 'bundle_id')  String bundleId, @JsonKey(name: 'bundle_version')  String bundleVersion,  double score, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans,  Map<String, Object?> metadata)  $default,) {final _that = this;
switch (_that) {
case _CorpusHit():
return $default(_that.schemaVersion,_that.recordId,_that.bundleId,_that.bundleVersion,_that.score,_that.evidenceSpans,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'record_id')  String recordId, @JsonKey(name: 'bundle_id')  String bundleId, @JsonKey(name: 'bundle_version')  String bundleVersion,  double score, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans,  Map<String, Object?> metadata)?  $default,) {final _that = this;
switch (_that) {
case _CorpusHit() when $default != null:
return $default(_that.schemaVersion,_that.recordId,_that.bundleId,_that.bundleVersion,_that.score,_that.evidenceSpans,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CorpusHit implements CorpusHit {
  const _CorpusHit({@JsonKey(name: 'schema_version') this.schemaVersion = kCorpusHitSchemaVersion, @JsonKey(name: 'record_id') required this.recordId, @JsonKey(name: 'bundle_id') required this.bundleId, @JsonKey(name: 'bundle_version') required this.bundleVersion, required this.score, @JsonKey(name: 'evidence_spans') required final  List<EvidenceSpan> evidenceSpans, final  Map<String, Object?> metadata = const <String, Object?>{}}): assert(score >= 0, 'score must be non-negative'),_evidenceSpans = evidenceSpans,_metadata = metadata;
  factory _CorpusHit.fromJson(Map<String, dynamic> json) => _$CorpusHitFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'record_id') final  String recordId;
@override@JsonKey(name: 'bundle_id') final  String bundleId;
@override@JsonKey(name: 'bundle_version') final  String bundleVersion;
@override final  double score;
 final  List<EvidenceSpan> _evidenceSpans;
@override@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans {
  if (_evidenceSpans is EqualUnmodifiableListView) return _evidenceSpans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidenceSpans);
}

 final  Map<String, Object?> _metadata;
@override@JsonKey() Map<String, Object?> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of CorpusHit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CorpusHitCopyWith<_CorpusHit> get copyWith => __$CorpusHitCopyWithImpl<_CorpusHit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CorpusHitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CorpusHit&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.recordId, recordId) || other.recordId == recordId)&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId)&&(identical(other.bundleVersion, bundleVersion) || other.bundleVersion == bundleVersion)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other._evidenceSpans, _evidenceSpans)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,recordId,bundleId,bundleVersion,score,const DeepCollectionEquality().hash(_evidenceSpans),const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'CorpusHit(schemaVersion: $schemaVersion, recordId: $recordId, bundleId: $bundleId, bundleVersion: $bundleVersion, score: $score, evidenceSpans: $evidenceSpans, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$CorpusHitCopyWith<$Res> implements $CorpusHitCopyWith<$Res> {
  factory _$CorpusHitCopyWith(_CorpusHit value, $Res Function(_CorpusHit) _then) = __$CorpusHitCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'record_id') String recordId,@JsonKey(name: 'bundle_id') String bundleId,@JsonKey(name: 'bundle_version') String bundleVersion, double score,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans, Map<String, Object?> metadata
});




}
/// @nodoc
class __$CorpusHitCopyWithImpl<$Res>
    implements _$CorpusHitCopyWith<$Res> {
  __$CorpusHitCopyWithImpl(this._self, this._then);

  final _CorpusHit _self;
  final $Res Function(_CorpusHit) _then;

/// Create a copy of CorpusHit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? recordId = null,Object? bundleId = null,Object? bundleVersion = null,Object? score = null,Object? evidenceSpans = null,Object? metadata = null,}) {
  return _then(_CorpusHit(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,recordId: null == recordId ? _self.recordId : recordId // ignore: cast_nullable_to_non_nullable
as String,bundleId: null == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String,bundleVersion: null == bundleVersion ? _self.bundleVersion : bundleVersion // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,evidenceSpans: null == evidenceSpans ? _self._evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}


/// @nodoc
mixin _$CorpusRetrievalResult {

@JsonKey(name: 'schema_version') String get schemaVersion; CorpusQuery get query; List<CorpusHit> get hits;@JsonKey(name: 'retrieval_policy_version') String get retrievalPolicyVersion;@JsonKey(name: 'generated_at') DateTime get generatedAt;
/// Create a copy of CorpusRetrievalResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CorpusRetrievalResultCopyWith<CorpusRetrievalResult> get copyWith => _$CorpusRetrievalResultCopyWithImpl<CorpusRetrievalResult>(this as CorpusRetrievalResult, _$identity);

  /// Serializes this CorpusRetrievalResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CorpusRetrievalResult&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.hits, hits)&&(identical(other.retrievalPolicyVersion, retrievalPolicyVersion) || other.retrievalPolicyVersion == retrievalPolicyVersion)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,query,const DeepCollectionEquality().hash(hits),retrievalPolicyVersion,generatedAt);

@override
String toString() {
  return 'CorpusRetrievalResult(schemaVersion: $schemaVersion, query: $query, hits: $hits, retrievalPolicyVersion: $retrievalPolicyVersion, generatedAt: $generatedAt)';
}


}

/// @nodoc
abstract mixin class $CorpusRetrievalResultCopyWith<$Res>  {
  factory $CorpusRetrievalResultCopyWith(CorpusRetrievalResult value, $Res Function(CorpusRetrievalResult) _then) = _$CorpusRetrievalResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion, CorpusQuery query, List<CorpusHit> hits,@JsonKey(name: 'retrieval_policy_version') String retrievalPolicyVersion,@JsonKey(name: 'generated_at') DateTime generatedAt
});


$CorpusQueryCopyWith<$Res> get query;

}
/// @nodoc
class _$CorpusRetrievalResultCopyWithImpl<$Res>
    implements $CorpusRetrievalResultCopyWith<$Res> {
  _$CorpusRetrievalResultCopyWithImpl(this._self, this._then);

  final CorpusRetrievalResult _self;
  final $Res Function(CorpusRetrievalResult) _then;

/// Create a copy of CorpusRetrievalResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? query = null,Object? hits = null,Object? retrievalPolicyVersion = null,Object? generatedAt = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as CorpusQuery,hits: null == hits ? _self.hits : hits // ignore: cast_nullable_to_non_nullable
as List<CorpusHit>,retrievalPolicyVersion: null == retrievalPolicyVersion ? _self.retrievalPolicyVersion : retrievalPolicyVersion // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of CorpusRetrievalResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CorpusQueryCopyWith<$Res> get query {
  
  return $CorpusQueryCopyWith<$Res>(_self.query, (value) {
    return _then(_self.copyWith(query: value));
  });
}
}


/// Adds pattern-matching-related methods to [CorpusRetrievalResult].
extension CorpusRetrievalResultPatterns on CorpusRetrievalResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CorpusRetrievalResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CorpusRetrievalResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CorpusRetrievalResult value)  $default,){
final _that = this;
switch (_that) {
case _CorpusRetrievalResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CorpusRetrievalResult value)?  $default,){
final _that = this;
switch (_that) {
case _CorpusRetrievalResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion,  CorpusQuery query,  List<CorpusHit> hits, @JsonKey(name: 'retrieval_policy_version')  String retrievalPolicyVersion, @JsonKey(name: 'generated_at')  DateTime generatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CorpusRetrievalResult() when $default != null:
return $default(_that.schemaVersion,_that.query,_that.hits,_that.retrievalPolicyVersion,_that.generatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion,  CorpusQuery query,  List<CorpusHit> hits, @JsonKey(name: 'retrieval_policy_version')  String retrievalPolicyVersion, @JsonKey(name: 'generated_at')  DateTime generatedAt)  $default,) {final _that = this;
switch (_that) {
case _CorpusRetrievalResult():
return $default(_that.schemaVersion,_that.query,_that.hits,_that.retrievalPolicyVersion,_that.generatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion,  CorpusQuery query,  List<CorpusHit> hits, @JsonKey(name: 'retrieval_policy_version')  String retrievalPolicyVersion, @JsonKey(name: 'generated_at')  DateTime generatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CorpusRetrievalResult() when $default != null:
return $default(_that.schemaVersion,_that.query,_that.hits,_that.retrievalPolicyVersion,_that.generatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CorpusRetrievalResult implements CorpusRetrievalResult {
  const _CorpusRetrievalResult({@JsonKey(name: 'schema_version') this.schemaVersion = kCorpusRetrievalResultSchemaVersion, required this.query, required final  List<CorpusHit> hits, @JsonKey(name: 'retrieval_policy_version') required this.retrievalPolicyVersion, @JsonKey(name: 'generated_at') required this.generatedAt}): _hits = hits;
  factory _CorpusRetrievalResult.fromJson(Map<String, dynamic> json) => _$CorpusRetrievalResultFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override final  CorpusQuery query;
 final  List<CorpusHit> _hits;
@override List<CorpusHit> get hits {
  if (_hits is EqualUnmodifiableListView) return _hits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hits);
}

@override@JsonKey(name: 'retrieval_policy_version') final  String retrievalPolicyVersion;
@override@JsonKey(name: 'generated_at') final  DateTime generatedAt;

/// Create a copy of CorpusRetrievalResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CorpusRetrievalResultCopyWith<_CorpusRetrievalResult> get copyWith => __$CorpusRetrievalResultCopyWithImpl<_CorpusRetrievalResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CorpusRetrievalResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CorpusRetrievalResult&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other._hits, _hits)&&(identical(other.retrievalPolicyVersion, retrievalPolicyVersion) || other.retrievalPolicyVersion == retrievalPolicyVersion)&&(identical(other.generatedAt, generatedAt) || other.generatedAt == generatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,query,const DeepCollectionEquality().hash(_hits),retrievalPolicyVersion,generatedAt);

@override
String toString() {
  return 'CorpusRetrievalResult(schemaVersion: $schemaVersion, query: $query, hits: $hits, retrievalPolicyVersion: $retrievalPolicyVersion, generatedAt: $generatedAt)';
}


}

/// @nodoc
abstract mixin class _$CorpusRetrievalResultCopyWith<$Res> implements $CorpusRetrievalResultCopyWith<$Res> {
  factory _$CorpusRetrievalResultCopyWith(_CorpusRetrievalResult value, $Res Function(_CorpusRetrievalResult) _then) = __$CorpusRetrievalResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion, CorpusQuery query, List<CorpusHit> hits,@JsonKey(name: 'retrieval_policy_version') String retrievalPolicyVersion,@JsonKey(name: 'generated_at') DateTime generatedAt
});


@override $CorpusQueryCopyWith<$Res> get query;

}
/// @nodoc
class __$CorpusRetrievalResultCopyWithImpl<$Res>
    implements _$CorpusRetrievalResultCopyWith<$Res> {
  __$CorpusRetrievalResultCopyWithImpl(this._self, this._then);

  final _CorpusRetrievalResult _self;
  final $Res Function(_CorpusRetrievalResult) _then;

/// Create a copy of CorpusRetrievalResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? query = null,Object? hits = null,Object? retrievalPolicyVersion = null,Object? generatedAt = null,}) {
  return _then(_CorpusRetrievalResult(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as CorpusQuery,hits: null == hits ? _self._hits : hits // ignore: cast_nullable_to_non_nullable
as List<CorpusHit>,retrievalPolicyVersion: null == retrievalPolicyVersion ? _self.retrievalPolicyVersion : retrievalPolicyVersion // ignore: cast_nullable_to_non_nullable
as String,generatedAt: null == generatedAt ? _self.generatedAt : generatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of CorpusRetrievalResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CorpusQueryCopyWith<$Res> get query {
  
  return $CorpusQueryCopyWith<$Res>(_self.query, (value) {
    return _then(_self.copyWith(query: value));
  });
}
}


/// @nodoc
mixin _$BillingLedgerEntry {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'entry_id') String get entryId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'provider_id') String get providerId;@JsonKey(name: 'provider_event_id') String get providerEventId;@JsonKey(name: 'event_type') BillingEventType get eventType;@JsonKey(name: 'occurred_at') DateTime get occurredAt; Map<String, Object?> get metadata;
/// Create a copy of BillingLedgerEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillingLedgerEntryCopyWith<BillingLedgerEntry> get copyWith => _$BillingLedgerEntryCopyWithImpl<BillingLedgerEntry>(this as BillingLedgerEntry, _$identity);

  /// Serializes this BillingLedgerEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillingLedgerEntry&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.providerEventId, providerEventId) || other.providerEventId == providerEventId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,entryId,userId,providerId,providerEventId,eventType,occurredAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'BillingLedgerEntry(schemaVersion: $schemaVersion, entryId: $entryId, userId: $userId, providerId: $providerId, providerEventId: $providerEventId, eventType: $eventType, occurredAt: $occurredAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $BillingLedgerEntryCopyWith<$Res>  {
  factory $BillingLedgerEntryCopyWith(BillingLedgerEntry value, $Res Function(BillingLedgerEntry) _then) = _$BillingLedgerEntryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'entry_id') String entryId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'provider_id') String providerId,@JsonKey(name: 'provider_event_id') String providerEventId,@JsonKey(name: 'event_type') BillingEventType eventType,@JsonKey(name: 'occurred_at') DateTime occurredAt, Map<String, Object?> metadata
});




}
/// @nodoc
class _$BillingLedgerEntryCopyWithImpl<$Res>
    implements $BillingLedgerEntryCopyWith<$Res> {
  _$BillingLedgerEntryCopyWithImpl(this._self, this._then);

  final BillingLedgerEntry _self;
  final $Res Function(BillingLedgerEntry) _then;

/// Create a copy of BillingLedgerEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? entryId = null,Object? userId = null,Object? providerId = null,Object? providerEventId = null,Object? eventType = null,Object? occurredAt = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,providerEventId: null == providerEventId ? _self.providerEventId : providerEventId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as BillingEventType,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [BillingLedgerEntry].
extension BillingLedgerEntryPatterns on BillingLedgerEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillingLedgerEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillingLedgerEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillingLedgerEntry value)  $default,){
final _that = this;
switch (_that) {
case _BillingLedgerEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillingLedgerEntry value)?  $default,){
final _that = this;
switch (_that) {
case _BillingLedgerEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'entry_id')  String entryId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'provider_id')  String providerId, @JsonKey(name: 'provider_event_id')  String providerEventId, @JsonKey(name: 'event_type')  BillingEventType eventType, @JsonKey(name: 'occurred_at')  DateTime occurredAt,  Map<String, Object?> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillingLedgerEntry() when $default != null:
return $default(_that.schemaVersion,_that.entryId,_that.userId,_that.providerId,_that.providerEventId,_that.eventType,_that.occurredAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'entry_id')  String entryId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'provider_id')  String providerId, @JsonKey(name: 'provider_event_id')  String providerEventId, @JsonKey(name: 'event_type')  BillingEventType eventType, @JsonKey(name: 'occurred_at')  DateTime occurredAt,  Map<String, Object?> metadata)  $default,) {final _that = this;
switch (_that) {
case _BillingLedgerEntry():
return $default(_that.schemaVersion,_that.entryId,_that.userId,_that.providerId,_that.providerEventId,_that.eventType,_that.occurredAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'entry_id')  String entryId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'provider_id')  String providerId, @JsonKey(name: 'provider_event_id')  String providerEventId, @JsonKey(name: 'event_type')  BillingEventType eventType, @JsonKey(name: 'occurred_at')  DateTime occurredAt,  Map<String, Object?> metadata)?  $default,) {final _that = this;
switch (_that) {
case _BillingLedgerEntry() when $default != null:
return $default(_that.schemaVersion,_that.entryId,_that.userId,_that.providerId,_that.providerEventId,_that.eventType,_that.occurredAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _BillingLedgerEntry implements BillingLedgerEntry {
  const _BillingLedgerEntry({@JsonKey(name: 'schema_version') this.schemaVersion = kBillingLedgerEntrySchemaVersion, @JsonKey(name: 'entry_id') required this.entryId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'provider_id') required this.providerId, @JsonKey(name: 'provider_event_id') required this.providerEventId, @JsonKey(name: 'event_type') required this.eventType, @JsonKey(name: 'occurred_at') required this.occurredAt, final  Map<String, Object?> metadata = const <String, Object?>{}}): _metadata = metadata;
  factory _BillingLedgerEntry.fromJson(Map<String, dynamic> json) => _$BillingLedgerEntryFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'entry_id') final  String entryId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'provider_id') final  String providerId;
@override@JsonKey(name: 'provider_event_id') final  String providerEventId;
@override@JsonKey(name: 'event_type') final  BillingEventType eventType;
@override@JsonKey(name: 'occurred_at') final  DateTime occurredAt;
 final  Map<String, Object?> _metadata;
@override@JsonKey() Map<String, Object?> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of BillingLedgerEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillingLedgerEntryCopyWith<_BillingLedgerEntry> get copyWith => __$BillingLedgerEntryCopyWithImpl<_BillingLedgerEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillingLedgerEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillingLedgerEntry&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.providerEventId, providerEventId) || other.providerEventId == providerEventId)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,entryId,userId,providerId,providerEventId,eventType,occurredAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'BillingLedgerEntry(schemaVersion: $schemaVersion, entryId: $entryId, userId: $userId, providerId: $providerId, providerEventId: $providerEventId, eventType: $eventType, occurredAt: $occurredAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$BillingLedgerEntryCopyWith<$Res> implements $BillingLedgerEntryCopyWith<$Res> {
  factory _$BillingLedgerEntryCopyWith(_BillingLedgerEntry value, $Res Function(_BillingLedgerEntry) _then) = __$BillingLedgerEntryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'entry_id') String entryId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'provider_id') String providerId,@JsonKey(name: 'provider_event_id') String providerEventId,@JsonKey(name: 'event_type') BillingEventType eventType,@JsonKey(name: 'occurred_at') DateTime occurredAt, Map<String, Object?> metadata
});




}
/// @nodoc
class __$BillingLedgerEntryCopyWithImpl<$Res>
    implements _$BillingLedgerEntryCopyWith<$Res> {
  __$BillingLedgerEntryCopyWithImpl(this._self, this._then);

  final _BillingLedgerEntry _self;
  final $Res Function(_BillingLedgerEntry) _then;

/// Create a copy of BillingLedgerEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? entryId = null,Object? userId = null,Object? providerId = null,Object? providerEventId = null,Object? eventType = null,Object? occurredAt = null,Object? metadata = null,}) {
  return _then(_BillingLedgerEntry(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String,providerEventId: null == providerEventId ? _self.providerEventId : providerEventId // ignore: cast_nullable_to_non_nullable
as String,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as BillingEventType,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}


/// @nodoc
mixin _$EntitlementSnapshot {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'user_id') String get userId; EntitlementStatus get status;@JsonKey(name: 'plan_id') String get planId;@JsonKey(name: 'source_ledger_entry_ids') List<String> get sourceLedgerEntryIds;@JsonKey(name: 'effective_at') DateTime get effectiveAt;@JsonKey(name: 'expires_at') DateTime? get expiresAt;
/// Create a copy of EntitlementSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntitlementSnapshotCopyWith<EntitlementSnapshot> get copyWith => _$EntitlementSnapshotCopyWithImpl<EntitlementSnapshot>(this as EntitlementSnapshot, _$identity);

  /// Serializes this EntitlementSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntitlementSnapshot&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.planId, planId) || other.planId == planId)&&const DeepCollectionEquality().equals(other.sourceLedgerEntryIds, sourceLedgerEntryIds)&&(identical(other.effectiveAt, effectiveAt) || other.effectiveAt == effectiveAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,userId,status,planId,const DeepCollectionEquality().hash(sourceLedgerEntryIds),effectiveAt,expiresAt);

@override
String toString() {
  return 'EntitlementSnapshot(schemaVersion: $schemaVersion, userId: $userId, status: $status, planId: $planId, sourceLedgerEntryIds: $sourceLedgerEntryIds, effectiveAt: $effectiveAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $EntitlementSnapshotCopyWith<$Res>  {
  factory $EntitlementSnapshotCopyWith(EntitlementSnapshot value, $Res Function(EntitlementSnapshot) _then) = _$EntitlementSnapshotCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'user_id') String userId, EntitlementStatus status,@JsonKey(name: 'plan_id') String planId,@JsonKey(name: 'source_ledger_entry_ids') List<String> sourceLedgerEntryIds,@JsonKey(name: 'effective_at') DateTime effectiveAt,@JsonKey(name: 'expires_at') DateTime? expiresAt
});




}
/// @nodoc
class _$EntitlementSnapshotCopyWithImpl<$Res>
    implements $EntitlementSnapshotCopyWith<$Res> {
  _$EntitlementSnapshotCopyWithImpl(this._self, this._then);

  final EntitlementSnapshot _self;
  final $Res Function(EntitlementSnapshot) _then;

/// Create a copy of EntitlementSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? userId = null,Object? status = null,Object? planId = null,Object? sourceLedgerEntryIds = null,Object? effectiveAt = null,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntitlementStatus,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,sourceLedgerEntryIds: null == sourceLedgerEntryIds ? _self.sourceLedgerEntryIds : sourceLedgerEntryIds // ignore: cast_nullable_to_non_nullable
as List<String>,effectiveAt: null == effectiveAt ? _self.effectiveAt : effectiveAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EntitlementSnapshot].
extension EntitlementSnapshotPatterns on EntitlementSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntitlementSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntitlementSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntitlementSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _EntitlementSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntitlementSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _EntitlementSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'user_id')  String userId,  EntitlementStatus status, @JsonKey(name: 'plan_id')  String planId, @JsonKey(name: 'source_ledger_entry_ids')  List<String> sourceLedgerEntryIds, @JsonKey(name: 'effective_at')  DateTime effectiveAt, @JsonKey(name: 'expires_at')  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntitlementSnapshot() when $default != null:
return $default(_that.schemaVersion,_that.userId,_that.status,_that.planId,_that.sourceLedgerEntryIds,_that.effectiveAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'user_id')  String userId,  EntitlementStatus status, @JsonKey(name: 'plan_id')  String planId, @JsonKey(name: 'source_ledger_entry_ids')  List<String> sourceLedgerEntryIds, @JsonKey(name: 'effective_at')  DateTime effectiveAt, @JsonKey(name: 'expires_at')  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _EntitlementSnapshot():
return $default(_that.schemaVersion,_that.userId,_that.status,_that.planId,_that.sourceLedgerEntryIds,_that.effectiveAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'user_id')  String userId,  EntitlementStatus status, @JsonKey(name: 'plan_id')  String planId, @JsonKey(name: 'source_ledger_entry_ids')  List<String> sourceLedgerEntryIds, @JsonKey(name: 'effective_at')  DateTime effectiveAt, @JsonKey(name: 'expires_at')  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _EntitlementSnapshot() when $default != null:
return $default(_that.schemaVersion,_that.userId,_that.status,_that.planId,_that.sourceLedgerEntryIds,_that.effectiveAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _EntitlementSnapshot implements EntitlementSnapshot {
  const _EntitlementSnapshot({@JsonKey(name: 'schema_version') this.schemaVersion = kEntitlementSnapshotSchemaVersion, @JsonKey(name: 'user_id') required this.userId, required this.status, @JsonKey(name: 'plan_id') required this.planId, @JsonKey(name: 'source_ledger_entry_ids') final  List<String> sourceLedgerEntryIds = const <String>[], @JsonKey(name: 'effective_at') required this.effectiveAt, @JsonKey(name: 'expires_at') this.expiresAt}): _sourceLedgerEntryIds = sourceLedgerEntryIds;
  factory _EntitlementSnapshot.fromJson(Map<String, dynamic> json) => _$EntitlementSnapshotFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  EntitlementStatus status;
@override@JsonKey(name: 'plan_id') final  String planId;
 final  List<String> _sourceLedgerEntryIds;
@override@JsonKey(name: 'source_ledger_entry_ids') List<String> get sourceLedgerEntryIds {
  if (_sourceLedgerEntryIds is EqualUnmodifiableListView) return _sourceLedgerEntryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sourceLedgerEntryIds);
}

@override@JsonKey(name: 'effective_at') final  DateTime effectiveAt;
@override@JsonKey(name: 'expires_at') final  DateTime? expiresAt;

/// Create a copy of EntitlementSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntitlementSnapshotCopyWith<_EntitlementSnapshot> get copyWith => __$EntitlementSnapshotCopyWithImpl<_EntitlementSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntitlementSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntitlementSnapshot&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.planId, planId) || other.planId == planId)&&const DeepCollectionEquality().equals(other._sourceLedgerEntryIds, _sourceLedgerEntryIds)&&(identical(other.effectiveAt, effectiveAt) || other.effectiveAt == effectiveAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,userId,status,planId,const DeepCollectionEquality().hash(_sourceLedgerEntryIds),effectiveAt,expiresAt);

@override
String toString() {
  return 'EntitlementSnapshot(schemaVersion: $schemaVersion, userId: $userId, status: $status, planId: $planId, sourceLedgerEntryIds: $sourceLedgerEntryIds, effectiveAt: $effectiveAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$EntitlementSnapshotCopyWith<$Res> implements $EntitlementSnapshotCopyWith<$Res> {
  factory _$EntitlementSnapshotCopyWith(_EntitlementSnapshot value, $Res Function(_EntitlementSnapshot) _then) = __$EntitlementSnapshotCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'user_id') String userId, EntitlementStatus status,@JsonKey(name: 'plan_id') String planId,@JsonKey(name: 'source_ledger_entry_ids') List<String> sourceLedgerEntryIds,@JsonKey(name: 'effective_at') DateTime effectiveAt,@JsonKey(name: 'expires_at') DateTime? expiresAt
});




}
/// @nodoc
class __$EntitlementSnapshotCopyWithImpl<$Res>
    implements _$EntitlementSnapshotCopyWith<$Res> {
  __$EntitlementSnapshotCopyWithImpl(this._self, this._then);

  final _EntitlementSnapshot _self;
  final $Res Function(_EntitlementSnapshot) _then;

/// Create a copy of EntitlementSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? userId = null,Object? status = null,Object? planId = null,Object? sourceLedgerEntryIds = null,Object? effectiveAt = null,Object? expiresAt = freezed,}) {
  return _then(_EntitlementSnapshot(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntitlementStatus,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,sourceLedgerEntryIds: null == sourceLedgerEntryIds ? _self._sourceLedgerEntryIds : sourceLedgerEntryIds // ignore: cast_nullable_to_non_nullable
as List<String>,effectiveAt: null == effectiveAt ? _self.effectiveAt : effectiveAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$EntitlementDecision {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'decision_id') String get decisionId;@JsonKey(name: 'allowed') bool get allowed;@JsonKey(name: 'reason_code') String get reasonCode;@JsonKey(name: 'policy_version') String get policyVersion; EntitlementSnapshot get snapshot;
/// Create a copy of EntitlementDecision
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntitlementDecisionCopyWith<EntitlementDecision> get copyWith => _$EntitlementDecisionCopyWithImpl<EntitlementDecision>(this as EntitlementDecision, _$identity);

  /// Serializes this EntitlementDecision to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntitlementDecision&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.decisionId, decisionId) || other.decisionId == decisionId)&&(identical(other.allowed, allowed) || other.allowed == allowed)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&(identical(other.policyVersion, policyVersion) || other.policyVersion == policyVersion)&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,decisionId,allowed,reasonCode,policyVersion,snapshot);

@override
String toString() {
  return 'EntitlementDecision(schemaVersion: $schemaVersion, decisionId: $decisionId, allowed: $allowed, reasonCode: $reasonCode, policyVersion: $policyVersion, snapshot: $snapshot)';
}


}

/// @nodoc
abstract mixin class $EntitlementDecisionCopyWith<$Res>  {
  factory $EntitlementDecisionCopyWith(EntitlementDecision value, $Res Function(EntitlementDecision) _then) = _$EntitlementDecisionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'decision_id') String decisionId,@JsonKey(name: 'allowed') bool allowed,@JsonKey(name: 'reason_code') String reasonCode,@JsonKey(name: 'policy_version') String policyVersion, EntitlementSnapshot snapshot
});


$EntitlementSnapshotCopyWith<$Res> get snapshot;

}
/// @nodoc
class _$EntitlementDecisionCopyWithImpl<$Res>
    implements $EntitlementDecisionCopyWith<$Res> {
  _$EntitlementDecisionCopyWithImpl(this._self, this._then);

  final EntitlementDecision _self;
  final $Res Function(EntitlementDecision) _then;

/// Create a copy of EntitlementDecision
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? decisionId = null,Object? allowed = null,Object? reasonCode = null,Object? policyVersion = null,Object? snapshot = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,decisionId: null == decisionId ? _self.decisionId : decisionId // ignore: cast_nullable_to_non_nullable
as String,allowed: null == allowed ? _self.allowed : allowed // ignore: cast_nullable_to_non_nullable
as bool,reasonCode: null == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String,policyVersion: null == policyVersion ? _self.policyVersion : policyVersion // ignore: cast_nullable_to_non_nullable
as String,snapshot: null == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as EntitlementSnapshot,
  ));
}
/// Create a copy of EntitlementDecision
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntitlementSnapshotCopyWith<$Res> get snapshot {
  
  return $EntitlementSnapshotCopyWith<$Res>(_self.snapshot, (value) {
    return _then(_self.copyWith(snapshot: value));
  });
}
}


/// Adds pattern-matching-related methods to [EntitlementDecision].
extension EntitlementDecisionPatterns on EntitlementDecision {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntitlementDecision value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntitlementDecision() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntitlementDecision value)  $default,){
final _that = this;
switch (_that) {
case _EntitlementDecision():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntitlementDecision value)?  $default,){
final _that = this;
switch (_that) {
case _EntitlementDecision() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'decision_id')  String decisionId, @JsonKey(name: 'allowed')  bool allowed, @JsonKey(name: 'reason_code')  String reasonCode, @JsonKey(name: 'policy_version')  String policyVersion,  EntitlementSnapshot snapshot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntitlementDecision() when $default != null:
return $default(_that.schemaVersion,_that.decisionId,_that.allowed,_that.reasonCode,_that.policyVersion,_that.snapshot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'decision_id')  String decisionId, @JsonKey(name: 'allowed')  bool allowed, @JsonKey(name: 'reason_code')  String reasonCode, @JsonKey(name: 'policy_version')  String policyVersion,  EntitlementSnapshot snapshot)  $default,) {final _that = this;
switch (_that) {
case _EntitlementDecision():
return $default(_that.schemaVersion,_that.decisionId,_that.allowed,_that.reasonCode,_that.policyVersion,_that.snapshot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'decision_id')  String decisionId, @JsonKey(name: 'allowed')  bool allowed, @JsonKey(name: 'reason_code')  String reasonCode, @JsonKey(name: 'policy_version')  String policyVersion,  EntitlementSnapshot snapshot)?  $default,) {final _that = this;
switch (_that) {
case _EntitlementDecision() when $default != null:
return $default(_that.schemaVersion,_that.decisionId,_that.allowed,_that.reasonCode,_that.policyVersion,_that.snapshot);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _EntitlementDecision implements EntitlementDecision {
  const _EntitlementDecision({@JsonKey(name: 'schema_version') this.schemaVersion = kEntitlementDecisionSchemaVersion, @JsonKey(name: 'decision_id') required this.decisionId, @JsonKey(name: 'allowed') required this.allowed, @JsonKey(name: 'reason_code') required this.reasonCode, @JsonKey(name: 'policy_version') required this.policyVersion, required this.snapshot});
  factory _EntitlementDecision.fromJson(Map<String, dynamic> json) => _$EntitlementDecisionFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'decision_id') final  String decisionId;
@override@JsonKey(name: 'allowed') final  bool allowed;
@override@JsonKey(name: 'reason_code') final  String reasonCode;
@override@JsonKey(name: 'policy_version') final  String policyVersion;
@override final  EntitlementSnapshot snapshot;

/// Create a copy of EntitlementDecision
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntitlementDecisionCopyWith<_EntitlementDecision> get copyWith => __$EntitlementDecisionCopyWithImpl<_EntitlementDecision>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntitlementDecisionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntitlementDecision&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.decisionId, decisionId) || other.decisionId == decisionId)&&(identical(other.allowed, allowed) || other.allowed == allowed)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&(identical(other.policyVersion, policyVersion) || other.policyVersion == policyVersion)&&(identical(other.snapshot, snapshot) || other.snapshot == snapshot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,decisionId,allowed,reasonCode,policyVersion,snapshot);

@override
String toString() {
  return 'EntitlementDecision(schemaVersion: $schemaVersion, decisionId: $decisionId, allowed: $allowed, reasonCode: $reasonCode, policyVersion: $policyVersion, snapshot: $snapshot)';
}


}

/// @nodoc
abstract mixin class _$EntitlementDecisionCopyWith<$Res> implements $EntitlementDecisionCopyWith<$Res> {
  factory _$EntitlementDecisionCopyWith(_EntitlementDecision value, $Res Function(_EntitlementDecision) _then) = __$EntitlementDecisionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'decision_id') String decisionId,@JsonKey(name: 'allowed') bool allowed,@JsonKey(name: 'reason_code') String reasonCode,@JsonKey(name: 'policy_version') String policyVersion, EntitlementSnapshot snapshot
});


@override $EntitlementSnapshotCopyWith<$Res> get snapshot;

}
/// @nodoc
class __$EntitlementDecisionCopyWithImpl<$Res>
    implements _$EntitlementDecisionCopyWith<$Res> {
  __$EntitlementDecisionCopyWithImpl(this._self, this._then);

  final _EntitlementDecision _self;
  final $Res Function(_EntitlementDecision) _then;

/// Create a copy of EntitlementDecision
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? decisionId = null,Object? allowed = null,Object? reasonCode = null,Object? policyVersion = null,Object? snapshot = null,}) {
  return _then(_EntitlementDecision(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,decisionId: null == decisionId ? _self.decisionId : decisionId // ignore: cast_nullable_to_non_nullable
as String,allowed: null == allowed ? _self.allowed : allowed // ignore: cast_nullable_to_non_nullable
as bool,reasonCode: null == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String,policyVersion: null == policyVersion ? _self.policyVersion : policyVersion // ignore: cast_nullable_to_non_nullable
as String,snapshot: null == snapshot ? _self.snapshot : snapshot // ignore: cast_nullable_to_non_nullable
as EntitlementSnapshot,
  ));
}

/// Create a copy of EntitlementDecision
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntitlementSnapshotCopyWith<$Res> get snapshot {
  
  return $EntitlementSnapshotCopyWith<$Res>(_self.snapshot, (value) {
    return _then(_self.copyWith(snapshot: value));
  });
}
}


/// @nodoc
mixin _$EvidenceAtomView {

@JsonKey(name: 'atom_id') String get atomId;@JsonKey(name: 'source_id') String get sourceId; String get text;@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans;
/// Create a copy of EvidenceAtomView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvidenceAtomViewCopyWith<EvidenceAtomView> get copyWith => _$EvidenceAtomViewCopyWithImpl<EvidenceAtomView>(this as EvidenceAtomView, _$identity);

  /// Serializes this EvidenceAtomView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EvidenceAtomView&&(identical(other.atomId, atomId) || other.atomId == atomId)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.evidenceSpans, evidenceSpans));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,atomId,sourceId,text,const DeepCollectionEquality().hash(evidenceSpans));

@override
String toString() {
  return 'EvidenceAtomView(atomId: $atomId, sourceId: $sourceId, text: $text, evidenceSpans: $evidenceSpans)';
}


}

/// @nodoc
abstract mixin class $EvidenceAtomViewCopyWith<$Res>  {
  factory $EvidenceAtomViewCopyWith(EvidenceAtomView value, $Res Function(EvidenceAtomView) _then) = _$EvidenceAtomViewCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'atom_id') String atomId,@JsonKey(name: 'source_id') String sourceId, String text,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans
});




}
/// @nodoc
class _$EvidenceAtomViewCopyWithImpl<$Res>
    implements $EvidenceAtomViewCopyWith<$Res> {
  _$EvidenceAtomViewCopyWithImpl(this._self, this._then);

  final EvidenceAtomView _self;
  final $Res Function(EvidenceAtomView) _then;

/// Create a copy of EvidenceAtomView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? atomId = null,Object? sourceId = null,Object? text = null,Object? evidenceSpans = null,}) {
  return _then(_self.copyWith(
atomId: null == atomId ? _self.atomId : atomId // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,evidenceSpans: null == evidenceSpans ? _self.evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,
  ));
}

}


/// Adds pattern-matching-related methods to [EvidenceAtomView].
extension EvidenceAtomViewPatterns on EvidenceAtomView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EvidenceAtomView value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EvidenceAtomView() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EvidenceAtomView value)  $default,){
final _that = this;
switch (_that) {
case _EvidenceAtomView():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EvidenceAtomView value)?  $default,){
final _that = this;
switch (_that) {
case _EvidenceAtomView() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'atom_id')  String atomId, @JsonKey(name: 'source_id')  String sourceId,  String text, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EvidenceAtomView() when $default != null:
return $default(_that.atomId,_that.sourceId,_that.text,_that.evidenceSpans);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'atom_id')  String atomId, @JsonKey(name: 'source_id')  String sourceId,  String text, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans)  $default,) {final _that = this;
switch (_that) {
case _EvidenceAtomView():
return $default(_that.atomId,_that.sourceId,_that.text,_that.evidenceSpans);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'atom_id')  String atomId, @JsonKey(name: 'source_id')  String sourceId,  String text, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans)?  $default,) {final _that = this;
switch (_that) {
case _EvidenceAtomView() when $default != null:
return $default(_that.atomId,_that.sourceId,_that.text,_that.evidenceSpans);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _EvidenceAtomView implements EvidenceAtomView {
  const _EvidenceAtomView({@JsonKey(name: 'atom_id') required this.atomId, @JsonKey(name: 'source_id') required this.sourceId, required this.text, @JsonKey(name: 'evidence_spans') required final  List<EvidenceSpan> evidenceSpans}): _evidenceSpans = evidenceSpans;
  factory _EvidenceAtomView.fromJson(Map<String, dynamic> json) => _$EvidenceAtomViewFromJson(json);

@override@JsonKey(name: 'atom_id') final  String atomId;
@override@JsonKey(name: 'source_id') final  String sourceId;
@override final  String text;
 final  List<EvidenceSpan> _evidenceSpans;
@override@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans {
  if (_evidenceSpans is EqualUnmodifiableListView) return _evidenceSpans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidenceSpans);
}


/// Create a copy of EvidenceAtomView
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EvidenceAtomViewCopyWith<_EvidenceAtomView> get copyWith => __$EvidenceAtomViewCopyWithImpl<_EvidenceAtomView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EvidenceAtomViewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EvidenceAtomView&&(identical(other.atomId, atomId) || other.atomId == atomId)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._evidenceSpans, _evidenceSpans));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,atomId,sourceId,text,const DeepCollectionEquality().hash(_evidenceSpans));

@override
String toString() {
  return 'EvidenceAtomView(atomId: $atomId, sourceId: $sourceId, text: $text, evidenceSpans: $evidenceSpans)';
}


}

/// @nodoc
abstract mixin class _$EvidenceAtomViewCopyWith<$Res> implements $EvidenceAtomViewCopyWith<$Res> {
  factory _$EvidenceAtomViewCopyWith(_EvidenceAtomView value, $Res Function(_EvidenceAtomView) _then) = __$EvidenceAtomViewCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'atom_id') String atomId,@JsonKey(name: 'source_id') String sourceId, String text,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans
});




}
/// @nodoc
class __$EvidenceAtomViewCopyWithImpl<$Res>
    implements _$EvidenceAtomViewCopyWith<$Res> {
  __$EvidenceAtomViewCopyWithImpl(this._self, this._then);

  final _EvidenceAtomView _self;
  final $Res Function(_EvidenceAtomView) _then;

/// Create a copy of EvidenceAtomView
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? atomId = null,Object? sourceId = null,Object? text = null,Object? evidenceSpans = null,}) {
  return _then(_EvidenceAtomView(
atomId: null == atomId ? _self.atomId : atomId // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,evidenceSpans: null == evidenceSpans ? _self._evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,
  ));
}


}

// dart format on
