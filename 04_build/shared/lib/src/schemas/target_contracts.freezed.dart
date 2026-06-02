// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'target_contracts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TargetRoleCompany {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'role_id') String get roleId; String get domain;@JsonKey(name: 'level_band') String get levelBand;@JsonKey(name: 'company_archetype') String get companyArchetype; String? get title; String? get market;@JsonKey(name: 'seniority_order') int? get seniorityOrder; Map<String, Object?> get metadata;
/// Create a copy of TargetRoleCompany
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TargetRoleCompanyCopyWith<TargetRoleCompany> get copyWith => _$TargetRoleCompanyCopyWithImpl<TargetRoleCompany>(this as TargetRoleCompany, _$identity);

  /// Serializes this TargetRoleCompany to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TargetRoleCompany&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.levelBand, levelBand) || other.levelBand == levelBand)&&(identical(other.companyArchetype, companyArchetype) || other.companyArchetype == companyArchetype)&&(identical(other.title, title) || other.title == title)&&(identical(other.market, market) || other.market == market)&&(identical(other.seniorityOrder, seniorityOrder) || other.seniorityOrder == seniorityOrder)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,roleId,domain,levelBand,companyArchetype,title,market,seniorityOrder,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'TargetRoleCompany(schemaVersion: $schemaVersion, roleId: $roleId, domain: $domain, levelBand: $levelBand, companyArchetype: $companyArchetype, title: $title, market: $market, seniorityOrder: $seniorityOrder, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $TargetRoleCompanyCopyWith<$Res>  {
  factory $TargetRoleCompanyCopyWith(TargetRoleCompany value, $Res Function(TargetRoleCompany) _then) = _$TargetRoleCompanyCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'role_id') String roleId, String domain,@JsonKey(name: 'level_band') String levelBand,@JsonKey(name: 'company_archetype') String companyArchetype, String? title, String? market,@JsonKey(name: 'seniority_order') int? seniorityOrder, Map<String, Object?> metadata
});




}
/// @nodoc
class _$TargetRoleCompanyCopyWithImpl<$Res>
    implements $TargetRoleCompanyCopyWith<$Res> {
  _$TargetRoleCompanyCopyWithImpl(this._self, this._then);

  final TargetRoleCompany _self;
  final $Res Function(TargetRoleCompany) _then;

/// Create a copy of TargetRoleCompany
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? roleId = null,Object? domain = null,Object? levelBand = null,Object? companyArchetype = null,Object? title = freezed,Object? market = freezed,Object? seniorityOrder = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,roleId: null == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,levelBand: null == levelBand ? _self.levelBand : levelBand // ignore: cast_nullable_to_non_nullable
as String,companyArchetype: null == companyArchetype ? _self.companyArchetype : companyArchetype // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,market: freezed == market ? _self.market : market // ignore: cast_nullable_to_non_nullable
as String?,seniorityOrder: freezed == seniorityOrder ? _self.seniorityOrder : seniorityOrder // ignore: cast_nullable_to_non_nullable
as int?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [TargetRoleCompany].
extension TargetRoleCompanyPatterns on TargetRoleCompany {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TargetRoleCompany value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TargetRoleCompany() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TargetRoleCompany value)  $default,){
final _that = this;
switch (_that) {
case _TargetRoleCompany():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TargetRoleCompany value)?  $default,){
final _that = this;
switch (_that) {
case _TargetRoleCompany() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'role_id')  String roleId,  String domain, @JsonKey(name: 'level_band')  String levelBand, @JsonKey(name: 'company_archetype')  String companyArchetype,  String? title,  String? market, @JsonKey(name: 'seniority_order')  int? seniorityOrder,  Map<String, Object?> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TargetRoleCompany() when $default != null:
return $default(_that.schemaVersion,_that.roleId,_that.domain,_that.levelBand,_that.companyArchetype,_that.title,_that.market,_that.seniorityOrder,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'role_id')  String roleId,  String domain, @JsonKey(name: 'level_band')  String levelBand, @JsonKey(name: 'company_archetype')  String companyArchetype,  String? title,  String? market, @JsonKey(name: 'seniority_order')  int? seniorityOrder,  Map<String, Object?> metadata)  $default,) {final _that = this;
switch (_that) {
case _TargetRoleCompany():
return $default(_that.schemaVersion,_that.roleId,_that.domain,_that.levelBand,_that.companyArchetype,_that.title,_that.market,_that.seniorityOrder,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'role_id')  String roleId,  String domain, @JsonKey(name: 'level_band')  String levelBand, @JsonKey(name: 'company_archetype')  String companyArchetype,  String? title,  String? market, @JsonKey(name: 'seniority_order')  int? seniorityOrder,  Map<String, Object?> metadata)?  $default,) {final _that = this;
switch (_that) {
case _TargetRoleCompany() when $default != null:
return $default(_that.schemaVersion,_that.roleId,_that.domain,_that.levelBand,_that.companyArchetype,_that.title,_that.market,_that.seniorityOrder,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _TargetRoleCompany implements TargetRoleCompany {
  const _TargetRoleCompany({@JsonKey(name: 'schema_version') this.schemaVersion = kTargetRoleCompanySchemaVersion, @JsonKey(name: 'role_id') required this.roleId, required this.domain, @JsonKey(name: 'level_band') required this.levelBand, @JsonKey(name: 'company_archetype') required this.companyArchetype, this.title, this.market, @JsonKey(name: 'seniority_order') this.seniorityOrder, final  Map<String, Object?> metadata = const <String, Object?>{}}): _metadata = metadata;
  factory _TargetRoleCompany.fromJson(Map<String, dynamic> json) => _$TargetRoleCompanyFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'role_id') final  String roleId;
@override final  String domain;
@override@JsonKey(name: 'level_band') final  String levelBand;
@override@JsonKey(name: 'company_archetype') final  String companyArchetype;
@override final  String? title;
@override final  String? market;
@override@JsonKey(name: 'seniority_order') final  int? seniorityOrder;
 final  Map<String, Object?> _metadata;
@override@JsonKey() Map<String, Object?> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of TargetRoleCompany
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TargetRoleCompanyCopyWith<_TargetRoleCompany> get copyWith => __$TargetRoleCompanyCopyWithImpl<_TargetRoleCompany>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TargetRoleCompanyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TargetRoleCompany&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.roleId, roleId) || other.roleId == roleId)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.levelBand, levelBand) || other.levelBand == levelBand)&&(identical(other.companyArchetype, companyArchetype) || other.companyArchetype == companyArchetype)&&(identical(other.title, title) || other.title == title)&&(identical(other.market, market) || other.market == market)&&(identical(other.seniorityOrder, seniorityOrder) || other.seniorityOrder == seniorityOrder)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,roleId,domain,levelBand,companyArchetype,title,market,seniorityOrder,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'TargetRoleCompany(schemaVersion: $schemaVersion, roleId: $roleId, domain: $domain, levelBand: $levelBand, companyArchetype: $companyArchetype, title: $title, market: $market, seniorityOrder: $seniorityOrder, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$TargetRoleCompanyCopyWith<$Res> implements $TargetRoleCompanyCopyWith<$Res> {
  factory _$TargetRoleCompanyCopyWith(_TargetRoleCompany value, $Res Function(_TargetRoleCompany) _then) = __$TargetRoleCompanyCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'role_id') String roleId, String domain,@JsonKey(name: 'level_band') String levelBand,@JsonKey(name: 'company_archetype') String companyArchetype, String? title, String? market,@JsonKey(name: 'seniority_order') int? seniorityOrder, Map<String, Object?> metadata
});




}
/// @nodoc
class __$TargetRoleCompanyCopyWithImpl<$Res>
    implements _$TargetRoleCompanyCopyWith<$Res> {
  __$TargetRoleCompanyCopyWithImpl(this._self, this._then);

  final _TargetRoleCompany _self;
  final $Res Function(_TargetRoleCompany) _then;

/// Create a copy of TargetRoleCompany
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? roleId = null,Object? domain = null,Object? levelBand = null,Object? companyArchetype = null,Object? title = freezed,Object? market = freezed,Object? seniorityOrder = freezed,Object? metadata = null,}) {
  return _then(_TargetRoleCompany(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,roleId: null == roleId ? _self.roleId : roleId // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,levelBand: null == levelBand ? _self.levelBand : levelBand // ignore: cast_nullable_to_non_nullable
as String,companyArchetype: null == companyArchetype ? _self.companyArchetype : companyArchetype // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,market: freezed == market ? _self.market : market // ignore: cast_nullable_to_non_nullable
as String?,seniorityOrder: freezed == seniorityOrder ? _self.seniorityOrder : seniorityOrder // ignore: cast_nullable_to_non_nullable
as int?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}

// dart format on
