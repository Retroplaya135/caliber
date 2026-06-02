// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_contracts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EvidenceAtom {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'atom_id') String get atomId;@JsonKey(name: 'profile_id') String get profileId;@JsonKey(name: 'source_id') String get sourceId;@JsonKey(name: 'source_type') String get sourceType; String get text; List<String> get tags;@JsonKey(name: 'captured_at') DateTime get capturedAt;@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans; double get confidence; Map<String, Object?> get metadata;
/// Create a copy of EvidenceAtom
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EvidenceAtomCopyWith<EvidenceAtom> get copyWith => _$EvidenceAtomCopyWithImpl<EvidenceAtom>(this as EvidenceAtom, _$identity);

  /// Serializes this EvidenceAtom to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EvidenceAtom&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.atomId, atomId) || other.atomId == atomId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&const DeepCollectionEquality().equals(other.evidenceSpans, evidenceSpans)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,atomId,profileId,sourceId,sourceType,text,const DeepCollectionEquality().hash(tags),capturedAt,const DeepCollectionEquality().hash(evidenceSpans),confidence,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'EvidenceAtom(schemaVersion: $schemaVersion, atomId: $atomId, profileId: $profileId, sourceId: $sourceId, sourceType: $sourceType, text: $text, tags: $tags, capturedAt: $capturedAt, evidenceSpans: $evidenceSpans, confidence: $confidence, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $EvidenceAtomCopyWith<$Res>  {
  factory $EvidenceAtomCopyWith(EvidenceAtom value, $Res Function(EvidenceAtom) _then) = _$EvidenceAtomCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'atom_id') String atomId,@JsonKey(name: 'profile_id') String profileId,@JsonKey(name: 'source_id') String sourceId,@JsonKey(name: 'source_type') String sourceType, String text, List<String> tags,@JsonKey(name: 'captured_at') DateTime capturedAt,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans, double confidence, Map<String, Object?> metadata
});




}
/// @nodoc
class _$EvidenceAtomCopyWithImpl<$Res>
    implements $EvidenceAtomCopyWith<$Res> {
  _$EvidenceAtomCopyWithImpl(this._self, this._then);

  final EvidenceAtom _self;
  final $Res Function(EvidenceAtom) _then;

/// Create a copy of EvidenceAtom
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? atomId = null,Object? profileId = null,Object? sourceId = null,Object? sourceType = null,Object? text = null,Object? tags = null,Object? capturedAt = null,Object? evidenceSpans = null,Object? confidence = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,atomId: null == atomId ? _self.atomId : atomId // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,evidenceSpans: null == evidenceSpans ? _self.evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [EvidenceAtom].
extension EvidenceAtomPatterns on EvidenceAtom {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EvidenceAtom value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EvidenceAtom() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EvidenceAtom value)  $default,){
final _that = this;
switch (_that) {
case _EvidenceAtom():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EvidenceAtom value)?  $default,){
final _that = this;
switch (_that) {
case _EvidenceAtom() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'atom_id')  String atomId, @JsonKey(name: 'profile_id')  String profileId, @JsonKey(name: 'source_id')  String sourceId, @JsonKey(name: 'source_type')  String sourceType,  String text,  List<String> tags, @JsonKey(name: 'captured_at')  DateTime capturedAt, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans,  double confidence,  Map<String, Object?> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EvidenceAtom() when $default != null:
return $default(_that.schemaVersion,_that.atomId,_that.profileId,_that.sourceId,_that.sourceType,_that.text,_that.tags,_that.capturedAt,_that.evidenceSpans,_that.confidence,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'atom_id')  String atomId, @JsonKey(name: 'profile_id')  String profileId, @JsonKey(name: 'source_id')  String sourceId, @JsonKey(name: 'source_type')  String sourceType,  String text,  List<String> tags, @JsonKey(name: 'captured_at')  DateTime capturedAt, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans,  double confidence,  Map<String, Object?> metadata)  $default,) {final _that = this;
switch (_that) {
case _EvidenceAtom():
return $default(_that.schemaVersion,_that.atomId,_that.profileId,_that.sourceId,_that.sourceType,_that.text,_that.tags,_that.capturedAt,_that.evidenceSpans,_that.confidence,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'atom_id')  String atomId, @JsonKey(name: 'profile_id')  String profileId, @JsonKey(name: 'source_id')  String sourceId, @JsonKey(name: 'source_type')  String sourceType,  String text,  List<String> tags, @JsonKey(name: 'captured_at')  DateTime capturedAt, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans,  double confidence,  Map<String, Object?> metadata)?  $default,) {final _that = this;
switch (_that) {
case _EvidenceAtom() when $default != null:
return $default(_that.schemaVersion,_that.atomId,_that.profileId,_that.sourceId,_that.sourceType,_that.text,_that.tags,_that.capturedAt,_that.evidenceSpans,_that.confidence,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _EvidenceAtom implements EvidenceAtom {
   _EvidenceAtom({@JsonKey(name: 'schema_version') this.schemaVersion = kEvidenceAtomSchemaVersion, @JsonKey(name: 'atom_id') required this.atomId, @JsonKey(name: 'profile_id') required this.profileId, @JsonKey(name: 'source_id') required this.sourceId, @JsonKey(name: 'source_type') required this.sourceType, required this.text, final  List<String> tags = const <String>[], @JsonKey(name: 'captured_at') required this.capturedAt, @JsonKey(name: 'evidence_spans') required final  List<EvidenceSpan> evidenceSpans, required this.confidence, final  Map<String, Object?> metadata = const <String, Object?>{}}): assert(confidence >= 0 && confidence <= 1, 'confidence must be between 0 and 1'),assert(evidenceSpans.isNotEmpty, 'evidenceSpans must not be empty'),_tags = tags,_evidenceSpans = evidenceSpans,_metadata = metadata;
  factory _EvidenceAtom.fromJson(Map<String, dynamic> json) => _$EvidenceAtomFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'atom_id') final  String atomId;
@override@JsonKey(name: 'profile_id') final  String profileId;
@override@JsonKey(name: 'source_id') final  String sourceId;
@override@JsonKey(name: 'source_type') final  String sourceType;
@override final  String text;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey(name: 'captured_at') final  DateTime capturedAt;
 final  List<EvidenceSpan> _evidenceSpans;
@override@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans {
  if (_evidenceSpans is EqualUnmodifiableListView) return _evidenceSpans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidenceSpans);
}

@override final  double confidence;
 final  Map<String, Object?> _metadata;
@override@JsonKey() Map<String, Object?> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of EvidenceAtom
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EvidenceAtomCopyWith<_EvidenceAtom> get copyWith => __$EvidenceAtomCopyWithImpl<_EvidenceAtom>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EvidenceAtomToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EvidenceAtom&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.atomId, atomId) || other.atomId == atomId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&const DeepCollectionEquality().equals(other._evidenceSpans, _evidenceSpans)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,atomId,profileId,sourceId,sourceType,text,const DeepCollectionEquality().hash(_tags),capturedAt,const DeepCollectionEquality().hash(_evidenceSpans),confidence,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'EvidenceAtom(schemaVersion: $schemaVersion, atomId: $atomId, profileId: $profileId, sourceId: $sourceId, sourceType: $sourceType, text: $text, tags: $tags, capturedAt: $capturedAt, evidenceSpans: $evidenceSpans, confidence: $confidence, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$EvidenceAtomCopyWith<$Res> implements $EvidenceAtomCopyWith<$Res> {
  factory _$EvidenceAtomCopyWith(_EvidenceAtom value, $Res Function(_EvidenceAtom) _then) = __$EvidenceAtomCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'atom_id') String atomId,@JsonKey(name: 'profile_id') String profileId,@JsonKey(name: 'source_id') String sourceId,@JsonKey(name: 'source_type') String sourceType, String text, List<String> tags,@JsonKey(name: 'captured_at') DateTime capturedAt,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans, double confidence, Map<String, Object?> metadata
});




}
/// @nodoc
class __$EvidenceAtomCopyWithImpl<$Res>
    implements _$EvidenceAtomCopyWith<$Res> {
  __$EvidenceAtomCopyWithImpl(this._self, this._then);

  final _EvidenceAtom _self;
  final $Res Function(_EvidenceAtom) _then;

/// Create a copy of EvidenceAtom
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? atomId = null,Object? profileId = null,Object? sourceId = null,Object? sourceType = null,Object? text = null,Object? tags = null,Object? capturedAt = null,Object? evidenceSpans = null,Object? confidence = null,Object? metadata = null,}) {
  return _then(_EvidenceAtom(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,atomId: null == atomId ? _self.atomId : atomId // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,evidenceSpans: null == evidenceSpans ? _self._evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}


/// @nodoc
mixin _$RenderContract {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'renderer_id') String get rendererId;@JsonKey(name: 'renderer_version') String get rendererVersion;@JsonKey(name: 'template_id') String get templateId;@JsonKey(name: 'template_version') String get templateVersion;@JsonKey(name: 'page_size') String get pageSize;@JsonKey(name: 'margin_profile') String get marginProfile;@JsonKey(name: 'allowed_formats') List<String> get allowedFormats;@JsonKey(name: 'layout_policy_version') String get layoutPolicyVersion;
/// Create a copy of RenderContract
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RenderContractCopyWith<RenderContract> get copyWith => _$RenderContractCopyWithImpl<RenderContract>(this as RenderContract, _$identity);

  /// Serializes this RenderContract to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RenderContract&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.rendererId, rendererId) || other.rendererId == rendererId)&&(identical(other.rendererVersion, rendererVersion) || other.rendererVersion == rendererVersion)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.templateVersion, templateVersion) || other.templateVersion == templateVersion)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.marginProfile, marginProfile) || other.marginProfile == marginProfile)&&const DeepCollectionEquality().equals(other.allowedFormats, allowedFormats)&&(identical(other.layoutPolicyVersion, layoutPolicyVersion) || other.layoutPolicyVersion == layoutPolicyVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,rendererId,rendererVersion,templateId,templateVersion,pageSize,marginProfile,const DeepCollectionEquality().hash(allowedFormats),layoutPolicyVersion);

@override
String toString() {
  return 'RenderContract(schemaVersion: $schemaVersion, rendererId: $rendererId, rendererVersion: $rendererVersion, templateId: $templateId, templateVersion: $templateVersion, pageSize: $pageSize, marginProfile: $marginProfile, allowedFormats: $allowedFormats, layoutPolicyVersion: $layoutPolicyVersion)';
}


}

/// @nodoc
abstract mixin class $RenderContractCopyWith<$Res>  {
  factory $RenderContractCopyWith(RenderContract value, $Res Function(RenderContract) _then) = _$RenderContractCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'renderer_id') String rendererId,@JsonKey(name: 'renderer_version') String rendererVersion,@JsonKey(name: 'template_id') String templateId,@JsonKey(name: 'template_version') String templateVersion,@JsonKey(name: 'page_size') String pageSize,@JsonKey(name: 'margin_profile') String marginProfile,@JsonKey(name: 'allowed_formats') List<String> allowedFormats,@JsonKey(name: 'layout_policy_version') String layoutPolicyVersion
});




}
/// @nodoc
class _$RenderContractCopyWithImpl<$Res>
    implements $RenderContractCopyWith<$Res> {
  _$RenderContractCopyWithImpl(this._self, this._then);

  final RenderContract _self;
  final $Res Function(RenderContract) _then;

/// Create a copy of RenderContract
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? rendererId = null,Object? rendererVersion = null,Object? templateId = null,Object? templateVersion = null,Object? pageSize = null,Object? marginProfile = null,Object? allowedFormats = null,Object? layoutPolicyVersion = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,rendererId: null == rendererId ? _self.rendererId : rendererId // ignore: cast_nullable_to_non_nullable
as String,rendererVersion: null == rendererVersion ? _self.rendererVersion : rendererVersion // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,templateVersion: null == templateVersion ? _self.templateVersion : templateVersion // ignore: cast_nullable_to_non_nullable
as String,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as String,marginProfile: null == marginProfile ? _self.marginProfile : marginProfile // ignore: cast_nullable_to_non_nullable
as String,allowedFormats: null == allowedFormats ? _self.allowedFormats : allowedFormats // ignore: cast_nullable_to_non_nullable
as List<String>,layoutPolicyVersion: null == layoutPolicyVersion ? _self.layoutPolicyVersion : layoutPolicyVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RenderContract].
extension RenderContractPatterns on RenderContract {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RenderContract value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RenderContract() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RenderContract value)  $default,){
final _that = this;
switch (_that) {
case _RenderContract():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RenderContract value)?  $default,){
final _that = this;
switch (_that) {
case _RenderContract() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'renderer_id')  String rendererId, @JsonKey(name: 'renderer_version')  String rendererVersion, @JsonKey(name: 'template_id')  String templateId, @JsonKey(name: 'template_version')  String templateVersion, @JsonKey(name: 'page_size')  String pageSize, @JsonKey(name: 'margin_profile')  String marginProfile, @JsonKey(name: 'allowed_formats')  List<String> allowedFormats, @JsonKey(name: 'layout_policy_version')  String layoutPolicyVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RenderContract() when $default != null:
return $default(_that.schemaVersion,_that.rendererId,_that.rendererVersion,_that.templateId,_that.templateVersion,_that.pageSize,_that.marginProfile,_that.allowedFormats,_that.layoutPolicyVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'renderer_id')  String rendererId, @JsonKey(name: 'renderer_version')  String rendererVersion, @JsonKey(name: 'template_id')  String templateId, @JsonKey(name: 'template_version')  String templateVersion, @JsonKey(name: 'page_size')  String pageSize, @JsonKey(name: 'margin_profile')  String marginProfile, @JsonKey(name: 'allowed_formats')  List<String> allowedFormats, @JsonKey(name: 'layout_policy_version')  String layoutPolicyVersion)  $default,) {final _that = this;
switch (_that) {
case _RenderContract():
return $default(_that.schemaVersion,_that.rendererId,_that.rendererVersion,_that.templateId,_that.templateVersion,_that.pageSize,_that.marginProfile,_that.allowedFormats,_that.layoutPolicyVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'renderer_id')  String rendererId, @JsonKey(name: 'renderer_version')  String rendererVersion, @JsonKey(name: 'template_id')  String templateId, @JsonKey(name: 'template_version')  String templateVersion, @JsonKey(name: 'page_size')  String pageSize, @JsonKey(name: 'margin_profile')  String marginProfile, @JsonKey(name: 'allowed_formats')  List<String> allowedFormats, @JsonKey(name: 'layout_policy_version')  String layoutPolicyVersion)?  $default,) {final _that = this;
switch (_that) {
case _RenderContract() when $default != null:
return $default(_that.schemaVersion,_that.rendererId,_that.rendererVersion,_that.templateId,_that.templateVersion,_that.pageSize,_that.marginProfile,_that.allowedFormats,_that.layoutPolicyVersion);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _RenderContract implements RenderContract {
  const _RenderContract({@JsonKey(name: 'schema_version') this.schemaVersion = kRenderContractSchemaVersion, @JsonKey(name: 'renderer_id') required this.rendererId, @JsonKey(name: 'renderer_version') required this.rendererVersion, @JsonKey(name: 'template_id') required this.templateId, @JsonKey(name: 'template_version') required this.templateVersion, @JsonKey(name: 'page_size') required this.pageSize, @JsonKey(name: 'margin_profile') required this.marginProfile, @JsonKey(name: 'allowed_formats') final  List<String> allowedFormats = const <String>[], @JsonKey(name: 'layout_policy_version') required this.layoutPolicyVersion}): _allowedFormats = allowedFormats;
  factory _RenderContract.fromJson(Map<String, dynamic> json) => _$RenderContractFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'renderer_id') final  String rendererId;
@override@JsonKey(name: 'renderer_version') final  String rendererVersion;
@override@JsonKey(name: 'template_id') final  String templateId;
@override@JsonKey(name: 'template_version') final  String templateVersion;
@override@JsonKey(name: 'page_size') final  String pageSize;
@override@JsonKey(name: 'margin_profile') final  String marginProfile;
 final  List<String> _allowedFormats;
@override@JsonKey(name: 'allowed_formats') List<String> get allowedFormats {
  if (_allowedFormats is EqualUnmodifiableListView) return _allowedFormats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedFormats);
}

@override@JsonKey(name: 'layout_policy_version') final  String layoutPolicyVersion;

/// Create a copy of RenderContract
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RenderContractCopyWith<_RenderContract> get copyWith => __$RenderContractCopyWithImpl<_RenderContract>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RenderContractToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RenderContract&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.rendererId, rendererId) || other.rendererId == rendererId)&&(identical(other.rendererVersion, rendererVersion) || other.rendererVersion == rendererVersion)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.templateVersion, templateVersion) || other.templateVersion == templateVersion)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.marginProfile, marginProfile) || other.marginProfile == marginProfile)&&const DeepCollectionEquality().equals(other._allowedFormats, _allowedFormats)&&(identical(other.layoutPolicyVersion, layoutPolicyVersion) || other.layoutPolicyVersion == layoutPolicyVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,rendererId,rendererVersion,templateId,templateVersion,pageSize,marginProfile,const DeepCollectionEquality().hash(_allowedFormats),layoutPolicyVersion);

@override
String toString() {
  return 'RenderContract(schemaVersion: $schemaVersion, rendererId: $rendererId, rendererVersion: $rendererVersion, templateId: $templateId, templateVersion: $templateVersion, pageSize: $pageSize, marginProfile: $marginProfile, allowedFormats: $allowedFormats, layoutPolicyVersion: $layoutPolicyVersion)';
}


}

/// @nodoc
abstract mixin class _$RenderContractCopyWith<$Res> implements $RenderContractCopyWith<$Res> {
  factory _$RenderContractCopyWith(_RenderContract value, $Res Function(_RenderContract) _then) = __$RenderContractCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'renderer_id') String rendererId,@JsonKey(name: 'renderer_version') String rendererVersion,@JsonKey(name: 'template_id') String templateId,@JsonKey(name: 'template_version') String templateVersion,@JsonKey(name: 'page_size') String pageSize,@JsonKey(name: 'margin_profile') String marginProfile,@JsonKey(name: 'allowed_formats') List<String> allowedFormats,@JsonKey(name: 'layout_policy_version') String layoutPolicyVersion
});




}
/// @nodoc
class __$RenderContractCopyWithImpl<$Res>
    implements _$RenderContractCopyWith<$Res> {
  __$RenderContractCopyWithImpl(this._self, this._then);

  final _RenderContract _self;
  final $Res Function(_RenderContract) _then;

/// Create a copy of RenderContract
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? rendererId = null,Object? rendererVersion = null,Object? templateId = null,Object? templateVersion = null,Object? pageSize = null,Object? marginProfile = null,Object? allowedFormats = null,Object? layoutPolicyVersion = null,}) {
  return _then(_RenderContract(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,rendererId: null == rendererId ? _self.rendererId : rendererId // ignore: cast_nullable_to_non_nullable
as String,rendererVersion: null == rendererVersion ? _self.rendererVersion : rendererVersion // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,templateVersion: null == templateVersion ? _self.templateVersion : templateVersion // ignore: cast_nullable_to_non_nullable
as String,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as String,marginProfile: null == marginProfile ? _self.marginProfile : marginProfile // ignore: cast_nullable_to_non_nullable
as String,allowedFormats: null == allowedFormats ? _self._allowedFormats : allowedFormats // ignore: cast_nullable_to_non_nullable
as List<String>,layoutPolicyVersion: null == layoutPolicyVersion ? _self.layoutPolicyVersion : layoutPolicyVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ResumeSection {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'section_id') String get sectionId;@JsonKey(name: 'section_type') String get sectionType; String get heading; int get order; List<ResumeBullet> get bullets;@JsonKey(name: 'evidence_atom_ids') List<String> get evidenceAtomIds;
/// Create a copy of ResumeSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResumeSectionCopyWith<ResumeSection> get copyWith => _$ResumeSectionCopyWithImpl<ResumeSection>(this as ResumeSection, _$identity);

  /// Serializes this ResumeSection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResumeSection&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.sectionType, sectionType) || other.sectionType == sectionType)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.order, order) || other.order == order)&&const DeepCollectionEquality().equals(other.bullets, bullets)&&const DeepCollectionEquality().equals(other.evidenceAtomIds, evidenceAtomIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,sectionId,sectionType,heading,order,const DeepCollectionEquality().hash(bullets),const DeepCollectionEquality().hash(evidenceAtomIds));

@override
String toString() {
  return 'ResumeSection(schemaVersion: $schemaVersion, sectionId: $sectionId, sectionType: $sectionType, heading: $heading, order: $order, bullets: $bullets, evidenceAtomIds: $evidenceAtomIds)';
}


}

/// @nodoc
abstract mixin class $ResumeSectionCopyWith<$Res>  {
  factory $ResumeSectionCopyWith(ResumeSection value, $Res Function(ResumeSection) _then) = _$ResumeSectionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'section_id') String sectionId,@JsonKey(name: 'section_type') String sectionType, String heading, int order, List<ResumeBullet> bullets,@JsonKey(name: 'evidence_atom_ids') List<String> evidenceAtomIds
});




}
/// @nodoc
class _$ResumeSectionCopyWithImpl<$Res>
    implements $ResumeSectionCopyWith<$Res> {
  _$ResumeSectionCopyWithImpl(this._self, this._then);

  final ResumeSection _self;
  final $Res Function(ResumeSection) _then;

/// Create a copy of ResumeSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? sectionId = null,Object? sectionType = null,Object? heading = null,Object? order = null,Object? bullets = null,Object? evidenceAtomIds = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,sectionId: null == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String,sectionType: null == sectionType ? _self.sectionType : sectionType // ignore: cast_nullable_to_non_nullable
as String,heading: null == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,bullets: null == bullets ? _self.bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<ResumeBullet>,evidenceAtomIds: null == evidenceAtomIds ? _self.evidenceAtomIds : evidenceAtomIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ResumeSection].
extension ResumeSectionPatterns on ResumeSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResumeSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResumeSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResumeSection value)  $default,){
final _that = this;
switch (_that) {
case _ResumeSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResumeSection value)?  $default,){
final _that = this;
switch (_that) {
case _ResumeSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'section_id')  String sectionId, @JsonKey(name: 'section_type')  String sectionType,  String heading,  int order,  List<ResumeBullet> bullets, @JsonKey(name: 'evidence_atom_ids')  List<String> evidenceAtomIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResumeSection() when $default != null:
return $default(_that.schemaVersion,_that.sectionId,_that.sectionType,_that.heading,_that.order,_that.bullets,_that.evidenceAtomIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'section_id')  String sectionId, @JsonKey(name: 'section_type')  String sectionType,  String heading,  int order,  List<ResumeBullet> bullets, @JsonKey(name: 'evidence_atom_ids')  List<String> evidenceAtomIds)  $default,) {final _that = this;
switch (_that) {
case _ResumeSection():
return $default(_that.schemaVersion,_that.sectionId,_that.sectionType,_that.heading,_that.order,_that.bullets,_that.evidenceAtomIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'section_id')  String sectionId, @JsonKey(name: 'section_type')  String sectionType,  String heading,  int order,  List<ResumeBullet> bullets, @JsonKey(name: 'evidence_atom_ids')  List<String> evidenceAtomIds)?  $default,) {final _that = this;
switch (_that) {
case _ResumeSection() when $default != null:
return $default(_that.schemaVersion,_that.sectionId,_that.sectionType,_that.heading,_that.order,_that.bullets,_that.evidenceAtomIds);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ResumeSection implements ResumeSection {
  const _ResumeSection({@JsonKey(name: 'schema_version') this.schemaVersion = kResumeSectionSchemaVersion, @JsonKey(name: 'section_id') required this.sectionId, @JsonKey(name: 'section_type') required this.sectionType, required this.heading, required this.order, final  List<ResumeBullet> bullets = const <ResumeBullet>[], @JsonKey(name: 'evidence_atom_ids') final  List<String> evidenceAtomIds = const <String>[]}): _bullets = bullets,_evidenceAtomIds = evidenceAtomIds;
  factory _ResumeSection.fromJson(Map<String, dynamic> json) => _$ResumeSectionFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'section_id') final  String sectionId;
@override@JsonKey(name: 'section_type') final  String sectionType;
@override final  String heading;
@override final  int order;
 final  List<ResumeBullet> _bullets;
@override@JsonKey() List<ResumeBullet> get bullets {
  if (_bullets is EqualUnmodifiableListView) return _bullets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bullets);
}

 final  List<String> _evidenceAtomIds;
@override@JsonKey(name: 'evidence_atom_ids') List<String> get evidenceAtomIds {
  if (_evidenceAtomIds is EqualUnmodifiableListView) return _evidenceAtomIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidenceAtomIds);
}


/// Create a copy of ResumeSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResumeSectionCopyWith<_ResumeSection> get copyWith => __$ResumeSectionCopyWithImpl<_ResumeSection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResumeSectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResumeSection&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.sectionType, sectionType) || other.sectionType == sectionType)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.order, order) || other.order == order)&&const DeepCollectionEquality().equals(other._bullets, _bullets)&&const DeepCollectionEquality().equals(other._evidenceAtomIds, _evidenceAtomIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,sectionId,sectionType,heading,order,const DeepCollectionEquality().hash(_bullets),const DeepCollectionEquality().hash(_evidenceAtomIds));

@override
String toString() {
  return 'ResumeSection(schemaVersion: $schemaVersion, sectionId: $sectionId, sectionType: $sectionType, heading: $heading, order: $order, bullets: $bullets, evidenceAtomIds: $evidenceAtomIds)';
}


}

/// @nodoc
abstract mixin class _$ResumeSectionCopyWith<$Res> implements $ResumeSectionCopyWith<$Res> {
  factory _$ResumeSectionCopyWith(_ResumeSection value, $Res Function(_ResumeSection) _then) = __$ResumeSectionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'section_id') String sectionId,@JsonKey(name: 'section_type') String sectionType, String heading, int order, List<ResumeBullet> bullets,@JsonKey(name: 'evidence_atom_ids') List<String> evidenceAtomIds
});




}
/// @nodoc
class __$ResumeSectionCopyWithImpl<$Res>
    implements _$ResumeSectionCopyWith<$Res> {
  __$ResumeSectionCopyWithImpl(this._self, this._then);

  final _ResumeSection _self;
  final $Res Function(_ResumeSection) _then;

/// Create a copy of ResumeSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? sectionId = null,Object? sectionType = null,Object? heading = null,Object? order = null,Object? bullets = null,Object? evidenceAtomIds = null,}) {
  return _then(_ResumeSection(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,sectionId: null == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String,sectionType: null == sectionType ? _self.sectionType : sectionType // ignore: cast_nullable_to_non_nullable
as String,heading: null == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,bullets: null == bullets ? _self._bullets : bullets // ignore: cast_nullable_to_non_nullable
as List<ResumeBullet>,evidenceAtomIds: null == evidenceAtomIds ? _self._evidenceAtomIds : evidenceAtomIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$ResumeDocument {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'document_id') String get documentId;@JsonKey(name: 'profile_id') String get profileId; String get title;@JsonKey(name: 'template_id') String get templateId;@JsonKey(name: 'template_version') String get templateVersion;@JsonKey(name: 'render_contract') RenderContract get renderContract; List<ResumeSection> get sections;@JsonKey(name: 'evidence_atoms') List<EvidenceAtom> get evidenceAtoms;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of ResumeDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResumeDocumentCopyWith<ResumeDocument> get copyWith => _$ResumeDocumentCopyWithImpl<ResumeDocument>(this as ResumeDocument, _$identity);

  /// Serializes this ResumeDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResumeDocument&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.title, title) || other.title == title)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.templateVersion, templateVersion) || other.templateVersion == templateVersion)&&(identical(other.renderContract, renderContract) || other.renderContract == renderContract)&&const DeepCollectionEquality().equals(other.sections, sections)&&const DeepCollectionEquality().equals(other.evidenceAtoms, evidenceAtoms)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,documentId,profileId,title,templateId,templateVersion,renderContract,const DeepCollectionEquality().hash(sections),const DeepCollectionEquality().hash(evidenceAtoms),createdAt,updatedAt);

@override
String toString() {
  return 'ResumeDocument(schemaVersion: $schemaVersion, documentId: $documentId, profileId: $profileId, title: $title, templateId: $templateId, templateVersion: $templateVersion, renderContract: $renderContract, sections: $sections, evidenceAtoms: $evidenceAtoms, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ResumeDocumentCopyWith<$Res>  {
  factory $ResumeDocumentCopyWith(ResumeDocument value, $Res Function(ResumeDocument) _then) = _$ResumeDocumentCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'document_id') String documentId,@JsonKey(name: 'profile_id') String profileId, String title,@JsonKey(name: 'template_id') String templateId,@JsonKey(name: 'template_version') String templateVersion,@JsonKey(name: 'render_contract') RenderContract renderContract, List<ResumeSection> sections,@JsonKey(name: 'evidence_atoms') List<EvidenceAtom> evidenceAtoms,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});


$RenderContractCopyWith<$Res> get renderContract;

}
/// @nodoc
class _$ResumeDocumentCopyWithImpl<$Res>
    implements $ResumeDocumentCopyWith<$Res> {
  _$ResumeDocumentCopyWithImpl(this._self, this._then);

  final ResumeDocument _self;
  final $Res Function(ResumeDocument) _then;

/// Create a copy of ResumeDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? documentId = null,Object? profileId = null,Object? title = null,Object? templateId = null,Object? templateVersion = null,Object? renderContract = null,Object? sections = null,Object? evidenceAtoms = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,templateVersion: null == templateVersion ? _self.templateVersion : templateVersion // ignore: cast_nullable_to_non_nullable
as String,renderContract: null == renderContract ? _self.renderContract : renderContract // ignore: cast_nullable_to_non_nullable
as RenderContract,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<ResumeSection>,evidenceAtoms: null == evidenceAtoms ? _self.evidenceAtoms : evidenceAtoms // ignore: cast_nullable_to_non_nullable
as List<EvidenceAtom>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of ResumeDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RenderContractCopyWith<$Res> get renderContract {
  
  return $RenderContractCopyWith<$Res>(_self.renderContract, (value) {
    return _then(_self.copyWith(renderContract: value));
  });
}
}


/// Adds pattern-matching-related methods to [ResumeDocument].
extension ResumeDocumentPatterns on ResumeDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResumeDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResumeDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResumeDocument value)  $default,){
final _that = this;
switch (_that) {
case _ResumeDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResumeDocument value)?  $default,){
final _that = this;
switch (_that) {
case _ResumeDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'document_id')  String documentId, @JsonKey(name: 'profile_id')  String profileId,  String title, @JsonKey(name: 'template_id')  String templateId, @JsonKey(name: 'template_version')  String templateVersion, @JsonKey(name: 'render_contract')  RenderContract renderContract,  List<ResumeSection> sections, @JsonKey(name: 'evidence_atoms')  List<EvidenceAtom> evidenceAtoms, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResumeDocument() when $default != null:
return $default(_that.schemaVersion,_that.documentId,_that.profileId,_that.title,_that.templateId,_that.templateVersion,_that.renderContract,_that.sections,_that.evidenceAtoms,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'document_id')  String documentId, @JsonKey(name: 'profile_id')  String profileId,  String title, @JsonKey(name: 'template_id')  String templateId, @JsonKey(name: 'template_version')  String templateVersion, @JsonKey(name: 'render_contract')  RenderContract renderContract,  List<ResumeSection> sections, @JsonKey(name: 'evidence_atoms')  List<EvidenceAtom> evidenceAtoms, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ResumeDocument():
return $default(_that.schemaVersion,_that.documentId,_that.profileId,_that.title,_that.templateId,_that.templateVersion,_that.renderContract,_that.sections,_that.evidenceAtoms,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'document_id')  String documentId, @JsonKey(name: 'profile_id')  String profileId,  String title, @JsonKey(name: 'template_id')  String templateId, @JsonKey(name: 'template_version')  String templateVersion, @JsonKey(name: 'render_contract')  RenderContract renderContract,  List<ResumeSection> sections, @JsonKey(name: 'evidence_atoms')  List<EvidenceAtom> evidenceAtoms, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ResumeDocument() when $default != null:
return $default(_that.schemaVersion,_that.documentId,_that.profileId,_that.title,_that.templateId,_that.templateVersion,_that.renderContract,_that.sections,_that.evidenceAtoms,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ResumeDocument implements ResumeDocument {
  const _ResumeDocument({@JsonKey(name: 'schema_version') this.schemaVersion = kResumeDocumentSchemaVersion, @JsonKey(name: 'document_id') required this.documentId, @JsonKey(name: 'profile_id') required this.profileId, required this.title, @JsonKey(name: 'template_id') required this.templateId, @JsonKey(name: 'template_version') required this.templateVersion, @JsonKey(name: 'render_contract') required this.renderContract, required final  List<ResumeSection> sections, @JsonKey(name: 'evidence_atoms') required final  List<EvidenceAtom> evidenceAtoms, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt}): _sections = sections,_evidenceAtoms = evidenceAtoms;
  factory _ResumeDocument.fromJson(Map<String, dynamic> json) => _$ResumeDocumentFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'document_id') final  String documentId;
@override@JsonKey(name: 'profile_id') final  String profileId;
@override final  String title;
@override@JsonKey(name: 'template_id') final  String templateId;
@override@JsonKey(name: 'template_version') final  String templateVersion;
@override@JsonKey(name: 'render_contract') final  RenderContract renderContract;
 final  List<ResumeSection> _sections;
@override List<ResumeSection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}

 final  List<EvidenceAtom> _evidenceAtoms;
@override@JsonKey(name: 'evidence_atoms') List<EvidenceAtom> get evidenceAtoms {
  if (_evidenceAtoms is EqualUnmodifiableListView) return _evidenceAtoms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidenceAtoms);
}

@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of ResumeDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResumeDocumentCopyWith<_ResumeDocument> get copyWith => __$ResumeDocumentCopyWithImpl<_ResumeDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResumeDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResumeDocument&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.title, title) || other.title == title)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.templateVersion, templateVersion) || other.templateVersion == templateVersion)&&(identical(other.renderContract, renderContract) || other.renderContract == renderContract)&&const DeepCollectionEquality().equals(other._sections, _sections)&&const DeepCollectionEquality().equals(other._evidenceAtoms, _evidenceAtoms)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,documentId,profileId,title,templateId,templateVersion,renderContract,const DeepCollectionEquality().hash(_sections),const DeepCollectionEquality().hash(_evidenceAtoms),createdAt,updatedAt);

@override
String toString() {
  return 'ResumeDocument(schemaVersion: $schemaVersion, documentId: $documentId, profileId: $profileId, title: $title, templateId: $templateId, templateVersion: $templateVersion, renderContract: $renderContract, sections: $sections, evidenceAtoms: $evidenceAtoms, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ResumeDocumentCopyWith<$Res> implements $ResumeDocumentCopyWith<$Res> {
  factory _$ResumeDocumentCopyWith(_ResumeDocument value, $Res Function(_ResumeDocument) _then) = __$ResumeDocumentCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'document_id') String documentId,@JsonKey(name: 'profile_id') String profileId, String title,@JsonKey(name: 'template_id') String templateId,@JsonKey(name: 'template_version') String templateVersion,@JsonKey(name: 'render_contract') RenderContract renderContract, List<ResumeSection> sections,@JsonKey(name: 'evidence_atoms') List<EvidenceAtom> evidenceAtoms,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});


@override $RenderContractCopyWith<$Res> get renderContract;

}
/// @nodoc
class __$ResumeDocumentCopyWithImpl<$Res>
    implements _$ResumeDocumentCopyWith<$Res> {
  __$ResumeDocumentCopyWithImpl(this._self, this._then);

  final _ResumeDocument _self;
  final $Res Function(_ResumeDocument) _then;

/// Create a copy of ResumeDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? documentId = null,Object? profileId = null,Object? title = null,Object? templateId = null,Object? templateVersion = null,Object? renderContract = null,Object? sections = null,Object? evidenceAtoms = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ResumeDocument(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,templateVersion: null == templateVersion ? _self.templateVersion : templateVersion // ignore: cast_nullable_to_non_nullable
as String,renderContract: null == renderContract ? _self.renderContract : renderContract // ignore: cast_nullable_to_non_nullable
as RenderContract,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<ResumeSection>,evidenceAtoms: null == evidenceAtoms ? _self._evidenceAtoms : evidenceAtoms // ignore: cast_nullable_to_non_nullable
as List<EvidenceAtom>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of ResumeDocument
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RenderContractCopyWith<$Res> get renderContract {
  
  return $RenderContractCopyWith<$Res>(_self.renderContract, (value) {
    return _then(_self.copyWith(renderContract: value));
  });
}
}

// dart format on
