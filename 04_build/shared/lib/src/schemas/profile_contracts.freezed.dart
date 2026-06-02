// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_contracts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileIdentity {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'profile_id') String get profileId;@JsonKey(name: 'owner_user_id') String get ownerUserId;@JsonKey(name: 'display_name') String get displayName;@JsonKey(name: 'primary_domain') String get primaryDomain;@JsonKey(name: 'target_level_band') String get targetLevelBand; String get locale;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt; Map<String, Object?> get metadata;
/// Create a copy of ProfileIdentity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileIdentityCopyWith<ProfileIdentity> get copyWith => _$ProfileIdentityCopyWithImpl<ProfileIdentity>(this as ProfileIdentity, _$identity);

  /// Serializes this ProfileIdentity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileIdentity&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.ownerUserId, ownerUserId) || other.ownerUserId == ownerUserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.primaryDomain, primaryDomain) || other.primaryDomain == primaryDomain)&&(identical(other.targetLevelBand, targetLevelBand) || other.targetLevelBand == targetLevelBand)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,profileId,ownerUserId,displayName,primaryDomain,targetLevelBand,locale,createdAt,updatedAt,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'ProfileIdentity(schemaVersion: $schemaVersion, profileId: $profileId, ownerUserId: $ownerUserId, displayName: $displayName, primaryDomain: $primaryDomain, targetLevelBand: $targetLevelBand, locale: $locale, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ProfileIdentityCopyWith<$Res>  {
  factory $ProfileIdentityCopyWith(ProfileIdentity value, $Res Function(ProfileIdentity) _then) = _$ProfileIdentityCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'profile_id') String profileId,@JsonKey(name: 'owner_user_id') String ownerUserId,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'primary_domain') String primaryDomain,@JsonKey(name: 'target_level_band') String targetLevelBand, String locale,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, Map<String, Object?> metadata
});




}
/// @nodoc
class _$ProfileIdentityCopyWithImpl<$Res>
    implements $ProfileIdentityCopyWith<$Res> {
  _$ProfileIdentityCopyWithImpl(this._self, this._then);

  final ProfileIdentity _self;
  final $Res Function(ProfileIdentity) _then;

/// Create a copy of ProfileIdentity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? profileId = null,Object? ownerUserId = null,Object? displayName = null,Object? primaryDomain = null,Object? targetLevelBand = null,Object? locale = null,Object? createdAt = null,Object? updatedAt = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,ownerUserId: null == ownerUserId ? _self.ownerUserId : ownerUserId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,primaryDomain: null == primaryDomain ? _self.primaryDomain : primaryDomain // ignore: cast_nullable_to_non_nullable
as String,targetLevelBand: null == targetLevelBand ? _self.targetLevelBand : targetLevelBand // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileIdentity].
extension ProfileIdentityPatterns on ProfileIdentity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileIdentity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileIdentity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileIdentity value)  $default,){
final _that = this;
switch (_that) {
case _ProfileIdentity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileIdentity value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileIdentity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'profile_id')  String profileId, @JsonKey(name: 'owner_user_id')  String ownerUserId, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'primary_domain')  String primaryDomain, @JsonKey(name: 'target_level_band')  String targetLevelBand,  String locale, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  Map<String, Object?> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileIdentity() when $default != null:
return $default(_that.schemaVersion,_that.profileId,_that.ownerUserId,_that.displayName,_that.primaryDomain,_that.targetLevelBand,_that.locale,_that.createdAt,_that.updatedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'profile_id')  String profileId, @JsonKey(name: 'owner_user_id')  String ownerUserId, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'primary_domain')  String primaryDomain, @JsonKey(name: 'target_level_band')  String targetLevelBand,  String locale, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  Map<String, Object?> metadata)  $default,) {final _that = this;
switch (_that) {
case _ProfileIdentity():
return $default(_that.schemaVersion,_that.profileId,_that.ownerUserId,_that.displayName,_that.primaryDomain,_that.targetLevelBand,_that.locale,_that.createdAt,_that.updatedAt,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'profile_id')  String profileId, @JsonKey(name: 'owner_user_id')  String ownerUserId, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'primary_domain')  String primaryDomain, @JsonKey(name: 'target_level_band')  String targetLevelBand,  String locale, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  Map<String, Object?> metadata)?  $default,) {final _that = this;
switch (_that) {
case _ProfileIdentity() when $default != null:
return $default(_that.schemaVersion,_that.profileId,_that.ownerUserId,_that.displayName,_that.primaryDomain,_that.targetLevelBand,_that.locale,_that.createdAt,_that.updatedAt,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ProfileIdentity implements ProfileIdentity {
  const _ProfileIdentity({@JsonKey(name: 'schema_version') this.schemaVersion = kProfileIdentitySchemaVersion, @JsonKey(name: 'profile_id') required this.profileId, @JsonKey(name: 'owner_user_id') required this.ownerUserId, @JsonKey(name: 'display_name') required this.displayName, @JsonKey(name: 'primary_domain') required this.primaryDomain, @JsonKey(name: 'target_level_band') required this.targetLevelBand, required this.locale, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, final  Map<String, Object?> metadata = const <String, Object?>{}}): _metadata = metadata;
  factory _ProfileIdentity.fromJson(Map<String, dynamic> json) => _$ProfileIdentityFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'profile_id') final  String profileId;
@override@JsonKey(name: 'owner_user_id') final  String ownerUserId;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey(name: 'primary_domain') final  String primaryDomain;
@override@JsonKey(name: 'target_level_band') final  String targetLevelBand;
@override final  String locale;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
 final  Map<String, Object?> _metadata;
@override@JsonKey() Map<String, Object?> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of ProfileIdentity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileIdentityCopyWith<_ProfileIdentity> get copyWith => __$ProfileIdentityCopyWithImpl<_ProfileIdentity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileIdentityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileIdentity&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.ownerUserId, ownerUserId) || other.ownerUserId == ownerUserId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.primaryDomain, primaryDomain) || other.primaryDomain == primaryDomain)&&(identical(other.targetLevelBand, targetLevelBand) || other.targetLevelBand == targetLevelBand)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,profileId,ownerUserId,displayName,primaryDomain,targetLevelBand,locale,createdAt,updatedAt,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'ProfileIdentity(schemaVersion: $schemaVersion, profileId: $profileId, ownerUserId: $ownerUserId, displayName: $displayName, primaryDomain: $primaryDomain, targetLevelBand: $targetLevelBand, locale: $locale, createdAt: $createdAt, updatedAt: $updatedAt, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ProfileIdentityCopyWith<$Res> implements $ProfileIdentityCopyWith<$Res> {
  factory _$ProfileIdentityCopyWith(_ProfileIdentity value, $Res Function(_ProfileIdentity) _then) = __$ProfileIdentityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'profile_id') String profileId,@JsonKey(name: 'owner_user_id') String ownerUserId,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'primary_domain') String primaryDomain,@JsonKey(name: 'target_level_band') String targetLevelBand, String locale,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, Map<String, Object?> metadata
});




}
/// @nodoc
class __$ProfileIdentityCopyWithImpl<$Res>
    implements _$ProfileIdentityCopyWith<$Res> {
  __$ProfileIdentityCopyWithImpl(this._self, this._then);

  final _ProfileIdentity _self;
  final $Res Function(_ProfileIdentity) _then;

/// Create a copy of ProfileIdentity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? profileId = null,Object? ownerUserId = null,Object? displayName = null,Object? primaryDomain = null,Object? targetLevelBand = null,Object? locale = null,Object? createdAt = null,Object? updatedAt = null,Object? metadata = null,}) {
  return _then(_ProfileIdentity(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,ownerUserId: null == ownerUserId ? _self.ownerUserId : ownerUserId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,primaryDomain: null == primaryDomain ? _self.primaryDomain : primaryDomain // ignore: cast_nullable_to_non_nullable
as String,targetLevelBand: null == targetLevelBand ? _self.targetLevelBand : targetLevelBand // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}


/// @nodoc
mixin _$TargetMatrixCell {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'cell_id') String get cellId;@JsonKey(name: 'profile_id') String get profileId;@JsonKey(name: 'target') TargetRoleCompany get target;@JsonKey(name: 'skill_axis') String get skillAxis;@JsonKey(name: 'evidence_atom_ids') List<String> get evidenceAtomIds;@JsonKey(name: 'readiness_score') double get readinessScore;@JsonKey(name: 'gap_score') double get gapScore; int get priority;@JsonKey(name: 'source_version') String get sourceVersion; Map<String, Object?> get metadata;
/// Create a copy of TargetMatrixCell
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TargetMatrixCellCopyWith<TargetMatrixCell> get copyWith => _$TargetMatrixCellCopyWithImpl<TargetMatrixCell>(this as TargetMatrixCell, _$identity);

  /// Serializes this TargetMatrixCell to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TargetMatrixCell&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.cellId, cellId) || other.cellId == cellId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.target, target) || other.target == target)&&(identical(other.skillAxis, skillAxis) || other.skillAxis == skillAxis)&&const DeepCollectionEquality().equals(other.evidenceAtomIds, evidenceAtomIds)&&(identical(other.readinessScore, readinessScore) || other.readinessScore == readinessScore)&&(identical(other.gapScore, gapScore) || other.gapScore == gapScore)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.sourceVersion, sourceVersion) || other.sourceVersion == sourceVersion)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,cellId,profileId,target,skillAxis,const DeepCollectionEquality().hash(evidenceAtomIds),readinessScore,gapScore,priority,sourceVersion,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'TargetMatrixCell(schemaVersion: $schemaVersion, cellId: $cellId, profileId: $profileId, target: $target, skillAxis: $skillAxis, evidenceAtomIds: $evidenceAtomIds, readinessScore: $readinessScore, gapScore: $gapScore, priority: $priority, sourceVersion: $sourceVersion, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $TargetMatrixCellCopyWith<$Res>  {
  factory $TargetMatrixCellCopyWith(TargetMatrixCell value, $Res Function(TargetMatrixCell) _then) = _$TargetMatrixCellCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'cell_id') String cellId,@JsonKey(name: 'profile_id') String profileId,@JsonKey(name: 'target') TargetRoleCompany target,@JsonKey(name: 'skill_axis') String skillAxis,@JsonKey(name: 'evidence_atom_ids') List<String> evidenceAtomIds,@JsonKey(name: 'readiness_score') double readinessScore,@JsonKey(name: 'gap_score') double gapScore, int priority,@JsonKey(name: 'source_version') String sourceVersion, Map<String, Object?> metadata
});


$TargetRoleCompanyCopyWith<$Res> get target;

}
/// @nodoc
class _$TargetMatrixCellCopyWithImpl<$Res>
    implements $TargetMatrixCellCopyWith<$Res> {
  _$TargetMatrixCellCopyWithImpl(this._self, this._then);

  final TargetMatrixCell _self;
  final $Res Function(TargetMatrixCell) _then;

/// Create a copy of TargetMatrixCell
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? cellId = null,Object? profileId = null,Object? target = null,Object? skillAxis = null,Object? evidenceAtomIds = null,Object? readinessScore = null,Object? gapScore = null,Object? priority = null,Object? sourceVersion = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,cellId: null == cellId ? _self.cellId : cellId // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as TargetRoleCompany,skillAxis: null == skillAxis ? _self.skillAxis : skillAxis // ignore: cast_nullable_to_non_nullable
as String,evidenceAtomIds: null == evidenceAtomIds ? _self.evidenceAtomIds : evidenceAtomIds // ignore: cast_nullable_to_non_nullable
as List<String>,readinessScore: null == readinessScore ? _self.readinessScore : readinessScore // ignore: cast_nullable_to_non_nullable
as double,gapScore: null == gapScore ? _self.gapScore : gapScore // ignore: cast_nullable_to_non_nullable
as double,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,sourceVersion: null == sourceVersion ? _self.sourceVersion : sourceVersion // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of TargetMatrixCell
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetRoleCompanyCopyWith<$Res> get target {
  
  return $TargetRoleCompanyCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}


/// Adds pattern-matching-related methods to [TargetMatrixCell].
extension TargetMatrixCellPatterns on TargetMatrixCell {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TargetMatrixCell value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TargetMatrixCell() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TargetMatrixCell value)  $default,){
final _that = this;
switch (_that) {
case _TargetMatrixCell():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TargetMatrixCell value)?  $default,){
final _that = this;
switch (_that) {
case _TargetMatrixCell() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'cell_id')  String cellId, @JsonKey(name: 'profile_id')  String profileId, @JsonKey(name: 'target')  TargetRoleCompany target, @JsonKey(name: 'skill_axis')  String skillAxis, @JsonKey(name: 'evidence_atom_ids')  List<String> evidenceAtomIds, @JsonKey(name: 'readiness_score')  double readinessScore, @JsonKey(name: 'gap_score')  double gapScore,  int priority, @JsonKey(name: 'source_version')  String sourceVersion,  Map<String, Object?> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TargetMatrixCell() when $default != null:
return $default(_that.schemaVersion,_that.cellId,_that.profileId,_that.target,_that.skillAxis,_that.evidenceAtomIds,_that.readinessScore,_that.gapScore,_that.priority,_that.sourceVersion,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'cell_id')  String cellId, @JsonKey(name: 'profile_id')  String profileId, @JsonKey(name: 'target')  TargetRoleCompany target, @JsonKey(name: 'skill_axis')  String skillAxis, @JsonKey(name: 'evidence_atom_ids')  List<String> evidenceAtomIds, @JsonKey(name: 'readiness_score')  double readinessScore, @JsonKey(name: 'gap_score')  double gapScore,  int priority, @JsonKey(name: 'source_version')  String sourceVersion,  Map<String, Object?> metadata)  $default,) {final _that = this;
switch (_that) {
case _TargetMatrixCell():
return $default(_that.schemaVersion,_that.cellId,_that.profileId,_that.target,_that.skillAxis,_that.evidenceAtomIds,_that.readinessScore,_that.gapScore,_that.priority,_that.sourceVersion,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'cell_id')  String cellId, @JsonKey(name: 'profile_id')  String profileId, @JsonKey(name: 'target')  TargetRoleCompany target, @JsonKey(name: 'skill_axis')  String skillAxis, @JsonKey(name: 'evidence_atom_ids')  List<String> evidenceAtomIds, @JsonKey(name: 'readiness_score')  double readinessScore, @JsonKey(name: 'gap_score')  double gapScore,  int priority, @JsonKey(name: 'source_version')  String sourceVersion,  Map<String, Object?> metadata)?  $default,) {final _that = this;
switch (_that) {
case _TargetMatrixCell() when $default != null:
return $default(_that.schemaVersion,_that.cellId,_that.profileId,_that.target,_that.skillAxis,_that.evidenceAtomIds,_that.readinessScore,_that.gapScore,_that.priority,_that.sourceVersion,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _TargetMatrixCell implements TargetMatrixCell {
  const _TargetMatrixCell({@JsonKey(name: 'schema_version') this.schemaVersion = kTargetMatrixCellSchemaVersion, @JsonKey(name: 'cell_id') required this.cellId, @JsonKey(name: 'profile_id') required this.profileId, @JsonKey(name: 'target') required this.target, @JsonKey(name: 'skill_axis') required this.skillAxis, @JsonKey(name: 'evidence_atom_ids') final  List<String> evidenceAtomIds = const <String>[], @JsonKey(name: 'readiness_score') required this.readinessScore, @JsonKey(name: 'gap_score') required this.gapScore, required this.priority, @JsonKey(name: 'source_version') required this.sourceVersion, final  Map<String, Object?> metadata = const <String, Object?>{}}): assert(readinessScore >= 0 && readinessScore <= 1, 'readinessScore must be between 0 and 1'),assert(gapScore >= 0 && gapScore <= 1, 'gapScore must be between 0 and 1'),_evidenceAtomIds = evidenceAtomIds,_metadata = metadata;
  factory _TargetMatrixCell.fromJson(Map<String, dynamic> json) => _$TargetMatrixCellFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'cell_id') final  String cellId;
@override@JsonKey(name: 'profile_id') final  String profileId;
@override@JsonKey(name: 'target') final  TargetRoleCompany target;
@override@JsonKey(name: 'skill_axis') final  String skillAxis;
 final  List<String> _evidenceAtomIds;
@override@JsonKey(name: 'evidence_atom_ids') List<String> get evidenceAtomIds {
  if (_evidenceAtomIds is EqualUnmodifiableListView) return _evidenceAtomIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidenceAtomIds);
}

@override@JsonKey(name: 'readiness_score') final  double readinessScore;
@override@JsonKey(name: 'gap_score') final  double gapScore;
@override final  int priority;
@override@JsonKey(name: 'source_version') final  String sourceVersion;
 final  Map<String, Object?> _metadata;
@override@JsonKey() Map<String, Object?> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of TargetMatrixCell
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TargetMatrixCellCopyWith<_TargetMatrixCell> get copyWith => __$TargetMatrixCellCopyWithImpl<_TargetMatrixCell>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TargetMatrixCellToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TargetMatrixCell&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.cellId, cellId) || other.cellId == cellId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.target, target) || other.target == target)&&(identical(other.skillAxis, skillAxis) || other.skillAxis == skillAxis)&&const DeepCollectionEquality().equals(other._evidenceAtomIds, _evidenceAtomIds)&&(identical(other.readinessScore, readinessScore) || other.readinessScore == readinessScore)&&(identical(other.gapScore, gapScore) || other.gapScore == gapScore)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.sourceVersion, sourceVersion) || other.sourceVersion == sourceVersion)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,cellId,profileId,target,skillAxis,const DeepCollectionEquality().hash(_evidenceAtomIds),readinessScore,gapScore,priority,sourceVersion,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'TargetMatrixCell(schemaVersion: $schemaVersion, cellId: $cellId, profileId: $profileId, target: $target, skillAxis: $skillAxis, evidenceAtomIds: $evidenceAtomIds, readinessScore: $readinessScore, gapScore: $gapScore, priority: $priority, sourceVersion: $sourceVersion, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$TargetMatrixCellCopyWith<$Res> implements $TargetMatrixCellCopyWith<$Res> {
  factory _$TargetMatrixCellCopyWith(_TargetMatrixCell value, $Res Function(_TargetMatrixCell) _then) = __$TargetMatrixCellCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'cell_id') String cellId,@JsonKey(name: 'profile_id') String profileId,@JsonKey(name: 'target') TargetRoleCompany target,@JsonKey(name: 'skill_axis') String skillAxis,@JsonKey(name: 'evidence_atom_ids') List<String> evidenceAtomIds,@JsonKey(name: 'readiness_score') double readinessScore,@JsonKey(name: 'gap_score') double gapScore, int priority,@JsonKey(name: 'source_version') String sourceVersion, Map<String, Object?> metadata
});


@override $TargetRoleCompanyCopyWith<$Res> get target;

}
/// @nodoc
class __$TargetMatrixCellCopyWithImpl<$Res>
    implements _$TargetMatrixCellCopyWith<$Res> {
  __$TargetMatrixCellCopyWithImpl(this._self, this._then);

  final _TargetMatrixCell _self;
  final $Res Function(_TargetMatrixCell) _then;

/// Create a copy of TargetMatrixCell
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? cellId = null,Object? profileId = null,Object? target = null,Object? skillAxis = null,Object? evidenceAtomIds = null,Object? readinessScore = null,Object? gapScore = null,Object? priority = null,Object? sourceVersion = null,Object? metadata = null,}) {
  return _then(_TargetMatrixCell(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,cellId: null == cellId ? _self.cellId : cellId // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as TargetRoleCompany,skillAxis: null == skillAxis ? _self.skillAxis : skillAxis // ignore: cast_nullable_to_non_nullable
as String,evidenceAtomIds: null == evidenceAtomIds ? _self._evidenceAtomIds : evidenceAtomIds // ignore: cast_nullable_to_non_nullable
as List<String>,readinessScore: null == readinessScore ? _self.readinessScore : readinessScore // ignore: cast_nullable_to_non_nullable
as double,gapScore: null == gapScore ? _self.gapScore : gapScore // ignore: cast_nullable_to_non_nullable
as double,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,sourceVersion: null == sourceVersion ? _self.sourceVersion : sourceVersion // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

/// Create a copy of TargetMatrixCell
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetRoleCompanyCopyWith<$Res> get target {
  
  return $TargetRoleCompanyCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}

// dart format on
