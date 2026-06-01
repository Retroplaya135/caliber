// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_output_contracts.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InterviewContentJudgment {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'judgment_id') String get judgmentId;@JsonKey(name: 'profile_id') String get profileId; TargetRoleCompany get target;@JsonKey(name: 'question_id') String get questionId;@JsonKey(name: 'answer_transcript_id') String get answerTranscriptId;@JsonKey(name: 'rubric_version') String get rubricVersion;@JsonKey(name: 'prompt_version') String get promptVersion;@JsonKey(name: 'model_id') String get modelId;@JsonKey(name: 'level_band') String get levelBand; List<String> get strengths; List<String> get risks;@JsonKey(name: 'recommended_actions') List<String> get recommendedActions;@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of InterviewContentJudgment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InterviewContentJudgmentCopyWith<InterviewContentJudgment> get copyWith => _$InterviewContentJudgmentCopyWithImpl<InterviewContentJudgment>(this as InterviewContentJudgment, _$identity);

  /// Serializes this InterviewContentJudgment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InterviewContentJudgment&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.judgmentId, judgmentId) || other.judgmentId == judgmentId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.target, target) || other.target == target)&&(identical(other.questionId, questionId) || other.questionId == questionId)&&(identical(other.answerTranscriptId, answerTranscriptId) || other.answerTranscriptId == answerTranscriptId)&&(identical(other.rubricVersion, rubricVersion) || other.rubricVersion == rubricVersion)&&(identical(other.promptVersion, promptVersion) || other.promptVersion == promptVersion)&&(identical(other.modelId, modelId) || other.modelId == modelId)&&(identical(other.levelBand, levelBand) || other.levelBand == levelBand)&&const DeepCollectionEquality().equals(other.strengths, strengths)&&const DeepCollectionEquality().equals(other.risks, risks)&&const DeepCollectionEquality().equals(other.recommendedActions, recommendedActions)&&const DeepCollectionEquality().equals(other.evidenceSpans, evidenceSpans)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,judgmentId,profileId,target,questionId,answerTranscriptId,rubricVersion,promptVersion,modelId,levelBand,const DeepCollectionEquality().hash(strengths),const DeepCollectionEquality().hash(risks),const DeepCollectionEquality().hash(recommendedActions),const DeepCollectionEquality().hash(evidenceSpans),createdAt);

@override
String toString() {
  return 'InterviewContentJudgment(schemaVersion: $schemaVersion, judgmentId: $judgmentId, profileId: $profileId, target: $target, questionId: $questionId, answerTranscriptId: $answerTranscriptId, rubricVersion: $rubricVersion, promptVersion: $promptVersion, modelId: $modelId, levelBand: $levelBand, strengths: $strengths, risks: $risks, recommendedActions: $recommendedActions, evidenceSpans: $evidenceSpans, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $InterviewContentJudgmentCopyWith<$Res>  {
  factory $InterviewContentJudgmentCopyWith(InterviewContentJudgment value, $Res Function(InterviewContentJudgment) _then) = _$InterviewContentJudgmentCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'judgment_id') String judgmentId,@JsonKey(name: 'profile_id') String profileId, TargetRoleCompany target,@JsonKey(name: 'question_id') String questionId,@JsonKey(name: 'answer_transcript_id') String answerTranscriptId,@JsonKey(name: 'rubric_version') String rubricVersion,@JsonKey(name: 'prompt_version') String promptVersion,@JsonKey(name: 'model_id') String modelId,@JsonKey(name: 'level_band') String levelBand, List<String> strengths, List<String> risks,@JsonKey(name: 'recommended_actions') List<String> recommendedActions,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans,@JsonKey(name: 'created_at') DateTime createdAt
});


$TargetRoleCompanyCopyWith<$Res> get target;

}
/// @nodoc
class _$InterviewContentJudgmentCopyWithImpl<$Res>
    implements $InterviewContentJudgmentCopyWith<$Res> {
  _$InterviewContentJudgmentCopyWithImpl(this._self, this._then);

  final InterviewContentJudgment _self;
  final $Res Function(InterviewContentJudgment) _then;

/// Create a copy of InterviewContentJudgment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? judgmentId = null,Object? profileId = null,Object? target = null,Object? questionId = null,Object? answerTranscriptId = null,Object? rubricVersion = null,Object? promptVersion = null,Object? modelId = null,Object? levelBand = null,Object? strengths = null,Object? risks = null,Object? recommendedActions = null,Object? evidenceSpans = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,judgmentId: null == judgmentId ? _self.judgmentId : judgmentId // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as TargetRoleCompany,questionId: null == questionId ? _self.questionId : questionId // ignore: cast_nullable_to_non_nullable
as String,answerTranscriptId: null == answerTranscriptId ? _self.answerTranscriptId : answerTranscriptId // ignore: cast_nullable_to_non_nullable
as String,rubricVersion: null == rubricVersion ? _self.rubricVersion : rubricVersion // ignore: cast_nullable_to_non_nullable
as String,promptVersion: null == promptVersion ? _self.promptVersion : promptVersion // ignore: cast_nullable_to_non_nullable
as String,modelId: null == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String,levelBand: null == levelBand ? _self.levelBand : levelBand // ignore: cast_nullable_to_non_nullable
as String,strengths: null == strengths ? _self.strengths : strengths // ignore: cast_nullable_to_non_nullable
as List<String>,risks: null == risks ? _self.risks : risks // ignore: cast_nullable_to_non_nullable
as List<String>,recommendedActions: null == recommendedActions ? _self.recommendedActions : recommendedActions // ignore: cast_nullable_to_non_nullable
as List<String>,evidenceSpans: null == evidenceSpans ? _self.evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of InterviewContentJudgment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetRoleCompanyCopyWith<$Res> get target {
  
  return $TargetRoleCompanyCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}


/// Adds pattern-matching-related methods to [InterviewContentJudgment].
extension InterviewContentJudgmentPatterns on InterviewContentJudgment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InterviewContentJudgment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InterviewContentJudgment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InterviewContentJudgment value)  $default,){
final _that = this;
switch (_that) {
case _InterviewContentJudgment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InterviewContentJudgment value)?  $default,){
final _that = this;
switch (_that) {
case _InterviewContentJudgment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'judgment_id')  String judgmentId, @JsonKey(name: 'profile_id')  String profileId,  TargetRoleCompany target, @JsonKey(name: 'question_id')  String questionId, @JsonKey(name: 'answer_transcript_id')  String answerTranscriptId, @JsonKey(name: 'rubric_version')  String rubricVersion, @JsonKey(name: 'prompt_version')  String promptVersion, @JsonKey(name: 'model_id')  String modelId, @JsonKey(name: 'level_band')  String levelBand,  List<String> strengths,  List<String> risks, @JsonKey(name: 'recommended_actions')  List<String> recommendedActions, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InterviewContentJudgment() when $default != null:
return $default(_that.schemaVersion,_that.judgmentId,_that.profileId,_that.target,_that.questionId,_that.answerTranscriptId,_that.rubricVersion,_that.promptVersion,_that.modelId,_that.levelBand,_that.strengths,_that.risks,_that.recommendedActions,_that.evidenceSpans,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'judgment_id')  String judgmentId, @JsonKey(name: 'profile_id')  String profileId,  TargetRoleCompany target, @JsonKey(name: 'question_id')  String questionId, @JsonKey(name: 'answer_transcript_id')  String answerTranscriptId, @JsonKey(name: 'rubric_version')  String rubricVersion, @JsonKey(name: 'prompt_version')  String promptVersion, @JsonKey(name: 'model_id')  String modelId, @JsonKey(name: 'level_band')  String levelBand,  List<String> strengths,  List<String> risks, @JsonKey(name: 'recommended_actions')  List<String> recommendedActions, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _InterviewContentJudgment():
return $default(_that.schemaVersion,_that.judgmentId,_that.profileId,_that.target,_that.questionId,_that.answerTranscriptId,_that.rubricVersion,_that.promptVersion,_that.modelId,_that.levelBand,_that.strengths,_that.risks,_that.recommendedActions,_that.evidenceSpans,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'judgment_id')  String judgmentId, @JsonKey(name: 'profile_id')  String profileId,  TargetRoleCompany target, @JsonKey(name: 'question_id')  String questionId, @JsonKey(name: 'answer_transcript_id')  String answerTranscriptId, @JsonKey(name: 'rubric_version')  String rubricVersion, @JsonKey(name: 'prompt_version')  String promptVersion, @JsonKey(name: 'model_id')  String modelId, @JsonKey(name: 'level_band')  String levelBand,  List<String> strengths,  List<String> risks, @JsonKey(name: 'recommended_actions')  List<String> recommendedActions, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InterviewContentJudgment() when $default != null:
return $default(_that.schemaVersion,_that.judgmentId,_that.profileId,_that.target,_that.questionId,_that.answerTranscriptId,_that.rubricVersion,_that.promptVersion,_that.modelId,_that.levelBand,_that.strengths,_that.risks,_that.recommendedActions,_that.evidenceSpans,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _InterviewContentJudgment implements InterviewContentJudgment {
   _InterviewContentJudgment({@JsonKey(name: 'schema_version') this.schemaVersion = kInterviewContentJudgmentSchemaVersion, @JsonKey(name: 'judgment_id') required this.judgmentId, @JsonKey(name: 'profile_id') required this.profileId, required this.target, @JsonKey(name: 'question_id') required this.questionId, @JsonKey(name: 'answer_transcript_id') required this.answerTranscriptId, @JsonKey(name: 'rubric_version') required this.rubricVersion, @JsonKey(name: 'prompt_version') required this.promptVersion, @JsonKey(name: 'model_id') required this.modelId, @JsonKey(name: 'level_band') required this.levelBand, final  List<String> strengths = const <String>[], final  List<String> risks = const <String>[], @JsonKey(name: 'recommended_actions') final  List<String> recommendedActions = const <String>[], @JsonKey(name: 'evidence_spans') required final  List<EvidenceSpan> evidenceSpans, @JsonKey(name: 'created_at') required this.createdAt}): assert(evidenceSpans.isNotEmpty, 'evidenceSpans must not be empty'),_strengths = strengths,_risks = risks,_recommendedActions = recommendedActions,_evidenceSpans = evidenceSpans;
  factory _InterviewContentJudgment.fromJson(Map<String, dynamic> json) => _$InterviewContentJudgmentFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'judgment_id') final  String judgmentId;
@override@JsonKey(name: 'profile_id') final  String profileId;
@override final  TargetRoleCompany target;
@override@JsonKey(name: 'question_id') final  String questionId;
@override@JsonKey(name: 'answer_transcript_id') final  String answerTranscriptId;
@override@JsonKey(name: 'rubric_version') final  String rubricVersion;
@override@JsonKey(name: 'prompt_version') final  String promptVersion;
@override@JsonKey(name: 'model_id') final  String modelId;
@override@JsonKey(name: 'level_band') final  String levelBand;
 final  List<String> _strengths;
@override@JsonKey() List<String> get strengths {
  if (_strengths is EqualUnmodifiableListView) return _strengths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_strengths);
}

 final  List<String> _risks;
@override@JsonKey() List<String> get risks {
  if (_risks is EqualUnmodifiableListView) return _risks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_risks);
}

 final  List<String> _recommendedActions;
@override@JsonKey(name: 'recommended_actions') List<String> get recommendedActions {
  if (_recommendedActions is EqualUnmodifiableListView) return _recommendedActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recommendedActions);
}

 final  List<EvidenceSpan> _evidenceSpans;
@override@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans {
  if (_evidenceSpans is EqualUnmodifiableListView) return _evidenceSpans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidenceSpans);
}

@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of InterviewContentJudgment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InterviewContentJudgmentCopyWith<_InterviewContentJudgment> get copyWith => __$InterviewContentJudgmentCopyWithImpl<_InterviewContentJudgment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InterviewContentJudgmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InterviewContentJudgment&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.judgmentId, judgmentId) || other.judgmentId == judgmentId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.target, target) || other.target == target)&&(identical(other.questionId, questionId) || other.questionId == questionId)&&(identical(other.answerTranscriptId, answerTranscriptId) || other.answerTranscriptId == answerTranscriptId)&&(identical(other.rubricVersion, rubricVersion) || other.rubricVersion == rubricVersion)&&(identical(other.promptVersion, promptVersion) || other.promptVersion == promptVersion)&&(identical(other.modelId, modelId) || other.modelId == modelId)&&(identical(other.levelBand, levelBand) || other.levelBand == levelBand)&&const DeepCollectionEquality().equals(other._strengths, _strengths)&&const DeepCollectionEquality().equals(other._risks, _risks)&&const DeepCollectionEquality().equals(other._recommendedActions, _recommendedActions)&&const DeepCollectionEquality().equals(other._evidenceSpans, _evidenceSpans)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,judgmentId,profileId,target,questionId,answerTranscriptId,rubricVersion,promptVersion,modelId,levelBand,const DeepCollectionEquality().hash(_strengths),const DeepCollectionEquality().hash(_risks),const DeepCollectionEquality().hash(_recommendedActions),const DeepCollectionEquality().hash(_evidenceSpans),createdAt);

@override
String toString() {
  return 'InterviewContentJudgment(schemaVersion: $schemaVersion, judgmentId: $judgmentId, profileId: $profileId, target: $target, questionId: $questionId, answerTranscriptId: $answerTranscriptId, rubricVersion: $rubricVersion, promptVersion: $promptVersion, modelId: $modelId, levelBand: $levelBand, strengths: $strengths, risks: $risks, recommendedActions: $recommendedActions, evidenceSpans: $evidenceSpans, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InterviewContentJudgmentCopyWith<$Res> implements $InterviewContentJudgmentCopyWith<$Res> {
  factory _$InterviewContentJudgmentCopyWith(_InterviewContentJudgment value, $Res Function(_InterviewContentJudgment) _then) = __$InterviewContentJudgmentCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'judgment_id') String judgmentId,@JsonKey(name: 'profile_id') String profileId, TargetRoleCompany target,@JsonKey(name: 'question_id') String questionId,@JsonKey(name: 'answer_transcript_id') String answerTranscriptId,@JsonKey(name: 'rubric_version') String rubricVersion,@JsonKey(name: 'prompt_version') String promptVersion,@JsonKey(name: 'model_id') String modelId,@JsonKey(name: 'level_band') String levelBand, List<String> strengths, List<String> risks,@JsonKey(name: 'recommended_actions') List<String> recommendedActions,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans,@JsonKey(name: 'created_at') DateTime createdAt
});


@override $TargetRoleCompanyCopyWith<$Res> get target;

}
/// @nodoc
class __$InterviewContentJudgmentCopyWithImpl<$Res>
    implements _$InterviewContentJudgmentCopyWith<$Res> {
  __$InterviewContentJudgmentCopyWithImpl(this._self, this._then);

  final _InterviewContentJudgment _self;
  final $Res Function(_InterviewContentJudgment) _then;

/// Create a copy of InterviewContentJudgment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? judgmentId = null,Object? profileId = null,Object? target = null,Object? questionId = null,Object? answerTranscriptId = null,Object? rubricVersion = null,Object? promptVersion = null,Object? modelId = null,Object? levelBand = null,Object? strengths = null,Object? risks = null,Object? recommendedActions = null,Object? evidenceSpans = null,Object? createdAt = null,}) {
  return _then(_InterviewContentJudgment(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,judgmentId: null == judgmentId ? _self.judgmentId : judgmentId // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as TargetRoleCompany,questionId: null == questionId ? _self.questionId : questionId // ignore: cast_nullable_to_non_nullable
as String,answerTranscriptId: null == answerTranscriptId ? _self.answerTranscriptId : answerTranscriptId // ignore: cast_nullable_to_non_nullable
as String,rubricVersion: null == rubricVersion ? _self.rubricVersion : rubricVersion // ignore: cast_nullable_to_non_nullable
as String,promptVersion: null == promptVersion ? _self.promptVersion : promptVersion // ignore: cast_nullable_to_non_nullable
as String,modelId: null == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String,levelBand: null == levelBand ? _self.levelBand : levelBand // ignore: cast_nullable_to_non_nullable
as String,strengths: null == strengths ? _self._strengths : strengths // ignore: cast_nullable_to_non_nullable
as List<String>,risks: null == risks ? _self._risks : risks // ignore: cast_nullable_to_non_nullable
as List<String>,recommendedActions: null == recommendedActions ? _self._recommendedActions : recommendedActions // ignore: cast_nullable_to_non_nullable
as List<String>,evidenceSpans: null == evidenceSpans ? _self._evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of InterviewContentJudgment
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
mixin _$ResumeBullet {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'bullet_id') String get bulletId;@JsonKey(name: 'document_id') String get documentId; String get text;@JsonKey(name: 'evidence_atom_ids') List<String> get evidenceAtomIds;@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans;@JsonKey(name: 'rewrite_policy_version') String get rewritePolicyVersion;@JsonKey(name: 'prompt_version') String get promptVersion;@JsonKey(name: 'model_id') String get modelId;@JsonKey(name: 'source_bullet_id') String? get sourceBulletId; double get confidence;
/// Create a copy of ResumeBullet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResumeBulletCopyWith<ResumeBullet> get copyWith => _$ResumeBulletCopyWithImpl<ResumeBullet>(this as ResumeBullet, _$identity);

  /// Serializes this ResumeBullet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResumeBullet&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.bulletId, bulletId) || other.bulletId == bulletId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.evidenceAtomIds, evidenceAtomIds)&&const DeepCollectionEquality().equals(other.evidenceSpans, evidenceSpans)&&(identical(other.rewritePolicyVersion, rewritePolicyVersion) || other.rewritePolicyVersion == rewritePolicyVersion)&&(identical(other.promptVersion, promptVersion) || other.promptVersion == promptVersion)&&(identical(other.modelId, modelId) || other.modelId == modelId)&&(identical(other.sourceBulletId, sourceBulletId) || other.sourceBulletId == sourceBulletId)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,bulletId,documentId,text,const DeepCollectionEquality().hash(evidenceAtomIds),const DeepCollectionEquality().hash(evidenceSpans),rewritePolicyVersion,promptVersion,modelId,sourceBulletId,confidence);

@override
String toString() {
  return 'ResumeBullet(schemaVersion: $schemaVersion, bulletId: $bulletId, documentId: $documentId, text: $text, evidenceAtomIds: $evidenceAtomIds, evidenceSpans: $evidenceSpans, rewritePolicyVersion: $rewritePolicyVersion, promptVersion: $promptVersion, modelId: $modelId, sourceBulletId: $sourceBulletId, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $ResumeBulletCopyWith<$Res>  {
  factory $ResumeBulletCopyWith(ResumeBullet value, $Res Function(ResumeBullet) _then) = _$ResumeBulletCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'bullet_id') String bulletId,@JsonKey(name: 'document_id') String documentId, String text,@JsonKey(name: 'evidence_atom_ids') List<String> evidenceAtomIds,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans,@JsonKey(name: 'rewrite_policy_version') String rewritePolicyVersion,@JsonKey(name: 'prompt_version') String promptVersion,@JsonKey(name: 'model_id') String modelId,@JsonKey(name: 'source_bullet_id') String? sourceBulletId, double confidence
});




}
/// @nodoc
class _$ResumeBulletCopyWithImpl<$Res>
    implements $ResumeBulletCopyWith<$Res> {
  _$ResumeBulletCopyWithImpl(this._self, this._then);

  final ResumeBullet _self;
  final $Res Function(ResumeBullet) _then;

/// Create a copy of ResumeBullet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? bulletId = null,Object? documentId = null,Object? text = null,Object? evidenceAtomIds = null,Object? evidenceSpans = null,Object? rewritePolicyVersion = null,Object? promptVersion = null,Object? modelId = null,Object? sourceBulletId = freezed,Object? confidence = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,bulletId: null == bulletId ? _self.bulletId : bulletId // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,evidenceAtomIds: null == evidenceAtomIds ? _self.evidenceAtomIds : evidenceAtomIds // ignore: cast_nullable_to_non_nullable
as List<String>,evidenceSpans: null == evidenceSpans ? _self.evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,rewritePolicyVersion: null == rewritePolicyVersion ? _self.rewritePolicyVersion : rewritePolicyVersion // ignore: cast_nullable_to_non_nullable
as String,promptVersion: null == promptVersion ? _self.promptVersion : promptVersion // ignore: cast_nullable_to_non_nullable
as String,modelId: null == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String,sourceBulletId: freezed == sourceBulletId ? _self.sourceBulletId : sourceBulletId // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ResumeBullet].
extension ResumeBulletPatterns on ResumeBullet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResumeBullet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResumeBullet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResumeBullet value)  $default,){
final _that = this;
switch (_that) {
case _ResumeBullet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResumeBullet value)?  $default,){
final _that = this;
switch (_that) {
case _ResumeBullet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'bullet_id')  String bulletId, @JsonKey(name: 'document_id')  String documentId,  String text, @JsonKey(name: 'evidence_atom_ids')  List<String> evidenceAtomIds, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans, @JsonKey(name: 'rewrite_policy_version')  String rewritePolicyVersion, @JsonKey(name: 'prompt_version')  String promptVersion, @JsonKey(name: 'model_id')  String modelId, @JsonKey(name: 'source_bullet_id')  String? sourceBulletId,  double confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResumeBullet() when $default != null:
return $default(_that.schemaVersion,_that.bulletId,_that.documentId,_that.text,_that.evidenceAtomIds,_that.evidenceSpans,_that.rewritePolicyVersion,_that.promptVersion,_that.modelId,_that.sourceBulletId,_that.confidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'bullet_id')  String bulletId, @JsonKey(name: 'document_id')  String documentId,  String text, @JsonKey(name: 'evidence_atom_ids')  List<String> evidenceAtomIds, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans, @JsonKey(name: 'rewrite_policy_version')  String rewritePolicyVersion, @JsonKey(name: 'prompt_version')  String promptVersion, @JsonKey(name: 'model_id')  String modelId, @JsonKey(name: 'source_bullet_id')  String? sourceBulletId,  double confidence)  $default,) {final _that = this;
switch (_that) {
case _ResumeBullet():
return $default(_that.schemaVersion,_that.bulletId,_that.documentId,_that.text,_that.evidenceAtomIds,_that.evidenceSpans,_that.rewritePolicyVersion,_that.promptVersion,_that.modelId,_that.sourceBulletId,_that.confidence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'bullet_id')  String bulletId, @JsonKey(name: 'document_id')  String documentId,  String text, @JsonKey(name: 'evidence_atom_ids')  List<String> evidenceAtomIds, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans, @JsonKey(name: 'rewrite_policy_version')  String rewritePolicyVersion, @JsonKey(name: 'prompt_version')  String promptVersion, @JsonKey(name: 'model_id')  String modelId, @JsonKey(name: 'source_bullet_id')  String? sourceBulletId,  double confidence)?  $default,) {final _that = this;
switch (_that) {
case _ResumeBullet() when $default != null:
return $default(_that.schemaVersion,_that.bulletId,_that.documentId,_that.text,_that.evidenceAtomIds,_that.evidenceSpans,_that.rewritePolicyVersion,_that.promptVersion,_that.modelId,_that.sourceBulletId,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ResumeBullet implements ResumeBullet {
   _ResumeBullet({@JsonKey(name: 'schema_version') this.schemaVersion = kResumeBulletSchemaVersion, @JsonKey(name: 'bullet_id') required this.bulletId, @JsonKey(name: 'document_id') required this.documentId, required this.text, @JsonKey(name: 'evidence_atom_ids') required final  List<String> evidenceAtomIds, @JsonKey(name: 'evidence_spans') required final  List<EvidenceSpan> evidenceSpans, @JsonKey(name: 'rewrite_policy_version') required this.rewritePolicyVersion, @JsonKey(name: 'prompt_version') required this.promptVersion, @JsonKey(name: 'model_id') required this.modelId, @JsonKey(name: 'source_bullet_id') this.sourceBulletId, required this.confidence}): assert(confidence >= 0 && confidence <= 1, 'confidence must be between 0 and 1'),assert(evidenceSpans.isNotEmpty, 'evidenceSpans must not be empty'),assert(evidenceAtomIds.isNotEmpty, 'evidenceAtomIds must not be empty'),_evidenceAtomIds = evidenceAtomIds,_evidenceSpans = evidenceSpans;
  factory _ResumeBullet.fromJson(Map<String, dynamic> json) => _$ResumeBulletFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'bullet_id') final  String bulletId;
@override@JsonKey(name: 'document_id') final  String documentId;
@override final  String text;
 final  List<String> _evidenceAtomIds;
@override@JsonKey(name: 'evidence_atom_ids') List<String> get evidenceAtomIds {
  if (_evidenceAtomIds is EqualUnmodifiableListView) return _evidenceAtomIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidenceAtomIds);
}

 final  List<EvidenceSpan> _evidenceSpans;
@override@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans {
  if (_evidenceSpans is EqualUnmodifiableListView) return _evidenceSpans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidenceSpans);
}

@override@JsonKey(name: 'rewrite_policy_version') final  String rewritePolicyVersion;
@override@JsonKey(name: 'prompt_version') final  String promptVersion;
@override@JsonKey(name: 'model_id') final  String modelId;
@override@JsonKey(name: 'source_bullet_id') final  String? sourceBulletId;
@override final  double confidence;

/// Create a copy of ResumeBullet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResumeBulletCopyWith<_ResumeBullet> get copyWith => __$ResumeBulletCopyWithImpl<_ResumeBullet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResumeBulletToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResumeBullet&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.bulletId, bulletId) || other.bulletId == bulletId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._evidenceAtomIds, _evidenceAtomIds)&&const DeepCollectionEquality().equals(other._evidenceSpans, _evidenceSpans)&&(identical(other.rewritePolicyVersion, rewritePolicyVersion) || other.rewritePolicyVersion == rewritePolicyVersion)&&(identical(other.promptVersion, promptVersion) || other.promptVersion == promptVersion)&&(identical(other.modelId, modelId) || other.modelId == modelId)&&(identical(other.sourceBulletId, sourceBulletId) || other.sourceBulletId == sourceBulletId)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,bulletId,documentId,text,const DeepCollectionEquality().hash(_evidenceAtomIds),const DeepCollectionEquality().hash(_evidenceSpans),rewritePolicyVersion,promptVersion,modelId,sourceBulletId,confidence);

@override
String toString() {
  return 'ResumeBullet(schemaVersion: $schemaVersion, bulletId: $bulletId, documentId: $documentId, text: $text, evidenceAtomIds: $evidenceAtomIds, evidenceSpans: $evidenceSpans, rewritePolicyVersion: $rewritePolicyVersion, promptVersion: $promptVersion, modelId: $modelId, sourceBulletId: $sourceBulletId, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$ResumeBulletCopyWith<$Res> implements $ResumeBulletCopyWith<$Res> {
  factory _$ResumeBulletCopyWith(_ResumeBullet value, $Res Function(_ResumeBullet) _then) = __$ResumeBulletCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'bullet_id') String bulletId,@JsonKey(name: 'document_id') String documentId, String text,@JsonKey(name: 'evidence_atom_ids') List<String> evidenceAtomIds,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans,@JsonKey(name: 'rewrite_policy_version') String rewritePolicyVersion,@JsonKey(name: 'prompt_version') String promptVersion,@JsonKey(name: 'model_id') String modelId,@JsonKey(name: 'source_bullet_id') String? sourceBulletId, double confidence
});




}
/// @nodoc
class __$ResumeBulletCopyWithImpl<$Res>
    implements _$ResumeBulletCopyWith<$Res> {
  __$ResumeBulletCopyWithImpl(this._self, this._then);

  final _ResumeBullet _self;
  final $Res Function(_ResumeBullet) _then;

/// Create a copy of ResumeBullet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? bulletId = null,Object? documentId = null,Object? text = null,Object? evidenceAtomIds = null,Object? evidenceSpans = null,Object? rewritePolicyVersion = null,Object? promptVersion = null,Object? modelId = null,Object? sourceBulletId = freezed,Object? confidence = null,}) {
  return _then(_ResumeBullet(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,bulletId: null == bulletId ? _self.bulletId : bulletId // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,evidenceAtomIds: null == evidenceAtomIds ? _self._evidenceAtomIds : evidenceAtomIds // ignore: cast_nullable_to_non_nullable
as List<String>,evidenceSpans: null == evidenceSpans ? _self._evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,rewritePolicyVersion: null == rewritePolicyVersion ? _self.rewritePolicyVersion : rewritePolicyVersion // ignore: cast_nullable_to_non_nullable
as String,promptVersion: null == promptVersion ? _self.promptVersion : promptVersion // ignore: cast_nullable_to_non_nullable
as String,modelId: null == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String,sourceBulletId: freezed == sourceBulletId ? _self.sourceBulletId : sourceBulletId // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ATSExtractableField {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'field_key') String get fieldKey; String get label; String get value;@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans;
/// Create a copy of ATSExtractableField
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ATSExtractableFieldCopyWith<ATSExtractableField> get copyWith => _$ATSExtractableFieldCopyWithImpl<ATSExtractableField>(this as ATSExtractableField, _$identity);

  /// Serializes this ATSExtractableField to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ATSExtractableField&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.fieldKey, fieldKey) || other.fieldKey == fieldKey)&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&const DeepCollectionEquality().equals(other.evidenceSpans, evidenceSpans));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,fieldKey,label,value,const DeepCollectionEquality().hash(evidenceSpans));

@override
String toString() {
  return 'ATSExtractableField(schemaVersion: $schemaVersion, fieldKey: $fieldKey, label: $label, value: $value, evidenceSpans: $evidenceSpans)';
}


}

/// @nodoc
abstract mixin class $ATSExtractableFieldCopyWith<$Res>  {
  factory $ATSExtractableFieldCopyWith(ATSExtractableField value, $Res Function(ATSExtractableField) _then) = _$ATSExtractableFieldCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'field_key') String fieldKey, String label, String value,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans
});




}
/// @nodoc
class _$ATSExtractableFieldCopyWithImpl<$Res>
    implements $ATSExtractableFieldCopyWith<$Res> {
  _$ATSExtractableFieldCopyWithImpl(this._self, this._then);

  final ATSExtractableField _self;
  final $Res Function(ATSExtractableField) _then;

/// Create a copy of ATSExtractableField
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? fieldKey = null,Object? label = null,Object? value = null,Object? evidenceSpans = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,fieldKey: null == fieldKey ? _self.fieldKey : fieldKey // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,evidenceSpans: null == evidenceSpans ? _self.evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,
  ));
}

}


/// Adds pattern-matching-related methods to [ATSExtractableField].
extension ATSExtractableFieldPatterns on ATSExtractableField {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ATSExtractableField value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ATSExtractableField() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ATSExtractableField value)  $default,){
final _that = this;
switch (_that) {
case _ATSExtractableField():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ATSExtractableField value)?  $default,){
final _that = this;
switch (_that) {
case _ATSExtractableField() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'field_key')  String fieldKey,  String label,  String value, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ATSExtractableField() when $default != null:
return $default(_that.schemaVersion,_that.fieldKey,_that.label,_that.value,_that.evidenceSpans);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'field_key')  String fieldKey,  String label,  String value, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans)  $default,) {final _that = this;
switch (_that) {
case _ATSExtractableField():
return $default(_that.schemaVersion,_that.fieldKey,_that.label,_that.value,_that.evidenceSpans);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'field_key')  String fieldKey,  String label,  String value, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans)?  $default,) {final _that = this;
switch (_that) {
case _ATSExtractableField() when $default != null:
return $default(_that.schemaVersion,_that.fieldKey,_that.label,_that.value,_that.evidenceSpans);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ATSExtractableField implements ATSExtractableField {
   _ATSExtractableField({@JsonKey(name: 'schema_version') this.schemaVersion = kAtsExtractableFieldSchemaVersion, @JsonKey(name: 'field_key') required this.fieldKey, required this.label, required this.value, @JsonKey(name: 'evidence_spans') required final  List<EvidenceSpan> evidenceSpans}): assert(evidenceSpans.isNotEmpty, 'evidenceSpans must not be empty'),_evidenceSpans = evidenceSpans;
  factory _ATSExtractableField.fromJson(Map<String, dynamic> json) => _$ATSExtractableFieldFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'field_key') final  String fieldKey;
@override final  String label;
@override final  String value;
 final  List<EvidenceSpan> _evidenceSpans;
@override@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans {
  if (_evidenceSpans is EqualUnmodifiableListView) return _evidenceSpans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidenceSpans);
}


/// Create a copy of ATSExtractableField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ATSExtractableFieldCopyWith<_ATSExtractableField> get copyWith => __$ATSExtractableFieldCopyWithImpl<_ATSExtractableField>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ATSExtractableFieldToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ATSExtractableField&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.fieldKey, fieldKey) || other.fieldKey == fieldKey)&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&const DeepCollectionEquality().equals(other._evidenceSpans, _evidenceSpans));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,fieldKey,label,value,const DeepCollectionEquality().hash(_evidenceSpans));

@override
String toString() {
  return 'ATSExtractableField(schemaVersion: $schemaVersion, fieldKey: $fieldKey, label: $label, value: $value, evidenceSpans: $evidenceSpans)';
}


}

/// @nodoc
abstract mixin class _$ATSExtractableFieldCopyWith<$Res> implements $ATSExtractableFieldCopyWith<$Res> {
  factory _$ATSExtractableFieldCopyWith(_ATSExtractableField value, $Res Function(_ATSExtractableField) _then) = __$ATSExtractableFieldCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'field_key') String fieldKey, String label, String value,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans
});




}
/// @nodoc
class __$ATSExtractableFieldCopyWithImpl<$Res>
    implements _$ATSExtractableFieldCopyWith<$Res> {
  __$ATSExtractableFieldCopyWithImpl(this._self, this._then);

  final _ATSExtractableField _self;
  final $Res Function(_ATSExtractableField) _then;

/// Create a copy of ATSExtractableField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? fieldKey = null,Object? label = null,Object? value = null,Object? evidenceSpans = null,}) {
  return _then(_ATSExtractableField(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,fieldKey: null == fieldKey ? _self.fieldKey : fieldKey // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,evidenceSpans: null == evidenceSpans ? _self._evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,
  ));
}


}


/// @nodoc
mixin _$ATSCoverageGap {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'gap_id') String get gapId; String get keyword; String get reason; String get severity;@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans;
/// Create a copy of ATSCoverageGap
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ATSCoverageGapCopyWith<ATSCoverageGap> get copyWith => _$ATSCoverageGapCopyWithImpl<ATSCoverageGap>(this as ATSCoverageGap, _$identity);

  /// Serializes this ATSCoverageGap to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ATSCoverageGap&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.gapId, gapId) || other.gapId == gapId)&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.severity, severity) || other.severity == severity)&&const DeepCollectionEquality().equals(other.evidenceSpans, evidenceSpans));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,gapId,keyword,reason,severity,const DeepCollectionEquality().hash(evidenceSpans));

@override
String toString() {
  return 'ATSCoverageGap(schemaVersion: $schemaVersion, gapId: $gapId, keyword: $keyword, reason: $reason, severity: $severity, evidenceSpans: $evidenceSpans)';
}


}

/// @nodoc
abstract mixin class $ATSCoverageGapCopyWith<$Res>  {
  factory $ATSCoverageGapCopyWith(ATSCoverageGap value, $Res Function(ATSCoverageGap) _then) = _$ATSCoverageGapCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'gap_id') String gapId, String keyword, String reason, String severity,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans
});




}
/// @nodoc
class _$ATSCoverageGapCopyWithImpl<$Res>
    implements $ATSCoverageGapCopyWith<$Res> {
  _$ATSCoverageGapCopyWithImpl(this._self, this._then);

  final ATSCoverageGap _self;
  final $Res Function(ATSCoverageGap) _then;

/// Create a copy of ATSCoverageGap
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? gapId = null,Object? keyword = null,Object? reason = null,Object? severity = null,Object? evidenceSpans = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,gapId: null == gapId ? _self.gapId : gapId // ignore: cast_nullable_to_non_nullable
as String,keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,evidenceSpans: null == evidenceSpans ? _self.evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,
  ));
}

}


/// Adds pattern-matching-related methods to [ATSCoverageGap].
extension ATSCoverageGapPatterns on ATSCoverageGap {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ATSCoverageGap value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ATSCoverageGap() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ATSCoverageGap value)  $default,){
final _that = this;
switch (_that) {
case _ATSCoverageGap():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ATSCoverageGap value)?  $default,){
final _that = this;
switch (_that) {
case _ATSCoverageGap() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'gap_id')  String gapId,  String keyword,  String reason,  String severity, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ATSCoverageGap() when $default != null:
return $default(_that.schemaVersion,_that.gapId,_that.keyword,_that.reason,_that.severity,_that.evidenceSpans);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'gap_id')  String gapId,  String keyword,  String reason,  String severity, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans)  $default,) {final _that = this;
switch (_that) {
case _ATSCoverageGap():
return $default(_that.schemaVersion,_that.gapId,_that.keyword,_that.reason,_that.severity,_that.evidenceSpans);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'gap_id')  String gapId,  String keyword,  String reason,  String severity, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans)?  $default,) {final _that = this;
switch (_that) {
case _ATSCoverageGap() when $default != null:
return $default(_that.schemaVersion,_that.gapId,_that.keyword,_that.reason,_that.severity,_that.evidenceSpans);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ATSCoverageGap implements ATSCoverageGap {
   _ATSCoverageGap({@JsonKey(name: 'schema_version') this.schemaVersion = kAtsCoverageGapSchemaVersion, @JsonKey(name: 'gap_id') required this.gapId, required this.keyword, required this.reason, required this.severity, @JsonKey(name: 'evidence_spans') required final  List<EvidenceSpan> evidenceSpans}): assert(evidenceSpans.isNotEmpty, 'evidenceSpans must not be empty'),_evidenceSpans = evidenceSpans;
  factory _ATSCoverageGap.fromJson(Map<String, dynamic> json) => _$ATSCoverageGapFromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'gap_id') final  String gapId;
@override final  String keyword;
@override final  String reason;
@override final  String severity;
 final  List<EvidenceSpan> _evidenceSpans;
@override@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans {
  if (_evidenceSpans is EqualUnmodifiableListView) return _evidenceSpans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidenceSpans);
}


/// Create a copy of ATSCoverageGap
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ATSCoverageGapCopyWith<_ATSCoverageGap> get copyWith => __$ATSCoverageGapCopyWithImpl<_ATSCoverageGap>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ATSCoverageGapToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ATSCoverageGap&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.gapId, gapId) || other.gapId == gapId)&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.severity, severity) || other.severity == severity)&&const DeepCollectionEquality().equals(other._evidenceSpans, _evidenceSpans));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,gapId,keyword,reason,severity,const DeepCollectionEquality().hash(_evidenceSpans));

@override
String toString() {
  return 'ATSCoverageGap(schemaVersion: $schemaVersion, gapId: $gapId, keyword: $keyword, reason: $reason, severity: $severity, evidenceSpans: $evidenceSpans)';
}


}

/// @nodoc
abstract mixin class _$ATSCoverageGapCopyWith<$Res> implements $ATSCoverageGapCopyWith<$Res> {
  factory _$ATSCoverageGapCopyWith(_ATSCoverageGap value, $Res Function(_ATSCoverageGap) _then) = __$ATSCoverageGapCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'gap_id') String gapId, String keyword, String reason, String severity,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans
});




}
/// @nodoc
class __$ATSCoverageGapCopyWithImpl<$Res>
    implements _$ATSCoverageGapCopyWith<$Res> {
  __$ATSCoverageGapCopyWithImpl(this._self, this._then);

  final _ATSCoverageGap _self;
  final $Res Function(_ATSCoverageGap) _then;

/// Create a copy of ATSCoverageGap
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? gapId = null,Object? keyword = null,Object? reason = null,Object? severity = null,Object? evidenceSpans = null,}) {
  return _then(_ATSCoverageGap(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,gapId: null == gapId ? _self.gapId : gapId // ignore: cast_nullable_to_non_nullable
as String,keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,evidenceSpans: null == evidenceSpans ? _self._evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,
  ));
}


}


/// @nodoc
mixin _$ATSReportV2 {

@JsonKey(name: 'schema_version') String get schemaVersion;@JsonKey(name: 'report_id') String get reportId;@JsonKey(name: 'document_id') String get documentId; TargetRoleCompany get target;@JsonKey(name: 'ats_test_matrix_version') String get atsTestMatrixVersion;@JsonKey(name: 'keyword_match_version') String get keywordMatchVersion;@JsonKey(name: 'extractable_fields') List<ATSExtractableField> get extractableFields;@JsonKey(name: 'matched_keywords') List<String> get matchedKeywords;@JsonKey(name: 'coverage_gaps') List<ATSCoverageGap> get coverageGaps; String get reasoning;@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of ATSReportV2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ATSReportV2CopyWith<ATSReportV2> get copyWith => _$ATSReportV2CopyWithImpl<ATSReportV2>(this as ATSReportV2, _$identity);

  /// Serializes this ATSReportV2 to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ATSReportV2&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.target, target) || other.target == target)&&(identical(other.atsTestMatrixVersion, atsTestMatrixVersion) || other.atsTestMatrixVersion == atsTestMatrixVersion)&&(identical(other.keywordMatchVersion, keywordMatchVersion) || other.keywordMatchVersion == keywordMatchVersion)&&const DeepCollectionEquality().equals(other.extractableFields, extractableFields)&&const DeepCollectionEquality().equals(other.matchedKeywords, matchedKeywords)&&const DeepCollectionEquality().equals(other.coverageGaps, coverageGaps)&&(identical(other.reasoning, reasoning) || other.reasoning == reasoning)&&const DeepCollectionEquality().equals(other.evidenceSpans, evidenceSpans)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,reportId,documentId,target,atsTestMatrixVersion,keywordMatchVersion,const DeepCollectionEquality().hash(extractableFields),const DeepCollectionEquality().hash(matchedKeywords),const DeepCollectionEquality().hash(coverageGaps),reasoning,const DeepCollectionEquality().hash(evidenceSpans),createdAt);

@override
String toString() {
  return 'ATSReportV2(schemaVersion: $schemaVersion, reportId: $reportId, documentId: $documentId, target: $target, atsTestMatrixVersion: $atsTestMatrixVersion, keywordMatchVersion: $keywordMatchVersion, extractableFields: $extractableFields, matchedKeywords: $matchedKeywords, coverageGaps: $coverageGaps, reasoning: $reasoning, evidenceSpans: $evidenceSpans, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ATSReportV2CopyWith<$Res>  {
  factory $ATSReportV2CopyWith(ATSReportV2 value, $Res Function(ATSReportV2) _then) = _$ATSReportV2CopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'report_id') String reportId,@JsonKey(name: 'document_id') String documentId, TargetRoleCompany target,@JsonKey(name: 'ats_test_matrix_version') String atsTestMatrixVersion,@JsonKey(name: 'keyword_match_version') String keywordMatchVersion,@JsonKey(name: 'extractable_fields') List<ATSExtractableField> extractableFields,@JsonKey(name: 'matched_keywords') List<String> matchedKeywords,@JsonKey(name: 'coverage_gaps') List<ATSCoverageGap> coverageGaps, String reasoning,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans,@JsonKey(name: 'created_at') DateTime createdAt
});


$TargetRoleCompanyCopyWith<$Res> get target;

}
/// @nodoc
class _$ATSReportV2CopyWithImpl<$Res>
    implements $ATSReportV2CopyWith<$Res> {
  _$ATSReportV2CopyWithImpl(this._self, this._then);

  final ATSReportV2 _self;
  final $Res Function(ATSReportV2) _then;

/// Create a copy of ATSReportV2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? reportId = null,Object? documentId = null,Object? target = null,Object? atsTestMatrixVersion = null,Object? keywordMatchVersion = null,Object? extractableFields = null,Object? matchedKeywords = null,Object? coverageGaps = null,Object? reasoning = null,Object? evidenceSpans = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as TargetRoleCompany,atsTestMatrixVersion: null == atsTestMatrixVersion ? _self.atsTestMatrixVersion : atsTestMatrixVersion // ignore: cast_nullable_to_non_nullable
as String,keywordMatchVersion: null == keywordMatchVersion ? _self.keywordMatchVersion : keywordMatchVersion // ignore: cast_nullable_to_non_nullable
as String,extractableFields: null == extractableFields ? _self.extractableFields : extractableFields // ignore: cast_nullable_to_non_nullable
as List<ATSExtractableField>,matchedKeywords: null == matchedKeywords ? _self.matchedKeywords : matchedKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,coverageGaps: null == coverageGaps ? _self.coverageGaps : coverageGaps // ignore: cast_nullable_to_non_nullable
as List<ATSCoverageGap>,reasoning: null == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String,evidenceSpans: null == evidenceSpans ? _self.evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of ATSReportV2
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetRoleCompanyCopyWith<$Res> get target {
  
  return $TargetRoleCompanyCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}


/// Adds pattern-matching-related methods to [ATSReportV2].
extension ATSReportV2Patterns on ATSReportV2 {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ATSReportV2 value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ATSReportV2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ATSReportV2 value)  $default,){
final _that = this;
switch (_that) {
case _ATSReportV2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ATSReportV2 value)?  $default,){
final _that = this;
switch (_that) {
case _ATSReportV2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'report_id')  String reportId, @JsonKey(name: 'document_id')  String documentId,  TargetRoleCompany target, @JsonKey(name: 'ats_test_matrix_version')  String atsTestMatrixVersion, @JsonKey(name: 'keyword_match_version')  String keywordMatchVersion, @JsonKey(name: 'extractable_fields')  List<ATSExtractableField> extractableFields, @JsonKey(name: 'matched_keywords')  List<String> matchedKeywords, @JsonKey(name: 'coverage_gaps')  List<ATSCoverageGap> coverageGaps,  String reasoning, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ATSReportV2() when $default != null:
return $default(_that.schemaVersion,_that.reportId,_that.documentId,_that.target,_that.atsTestMatrixVersion,_that.keywordMatchVersion,_that.extractableFields,_that.matchedKeywords,_that.coverageGaps,_that.reasoning,_that.evidenceSpans,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'report_id')  String reportId, @JsonKey(name: 'document_id')  String documentId,  TargetRoleCompany target, @JsonKey(name: 'ats_test_matrix_version')  String atsTestMatrixVersion, @JsonKey(name: 'keyword_match_version')  String keywordMatchVersion, @JsonKey(name: 'extractable_fields')  List<ATSExtractableField> extractableFields, @JsonKey(name: 'matched_keywords')  List<String> matchedKeywords, @JsonKey(name: 'coverage_gaps')  List<ATSCoverageGap> coverageGaps,  String reasoning, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ATSReportV2():
return $default(_that.schemaVersion,_that.reportId,_that.documentId,_that.target,_that.atsTestMatrixVersion,_that.keywordMatchVersion,_that.extractableFields,_that.matchedKeywords,_that.coverageGaps,_that.reasoning,_that.evidenceSpans,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'schema_version')  String schemaVersion, @JsonKey(name: 'report_id')  String reportId, @JsonKey(name: 'document_id')  String documentId,  TargetRoleCompany target, @JsonKey(name: 'ats_test_matrix_version')  String atsTestMatrixVersion, @JsonKey(name: 'keyword_match_version')  String keywordMatchVersion, @JsonKey(name: 'extractable_fields')  List<ATSExtractableField> extractableFields, @JsonKey(name: 'matched_keywords')  List<String> matchedKeywords, @JsonKey(name: 'coverage_gaps')  List<ATSCoverageGap> coverageGaps,  String reasoning, @JsonKey(name: 'evidence_spans')  List<EvidenceSpan> evidenceSpans, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ATSReportV2() when $default != null:
return $default(_that.schemaVersion,_that.reportId,_that.documentId,_that.target,_that.atsTestMatrixVersion,_that.keywordMatchVersion,_that.extractableFields,_that.matchedKeywords,_that.coverageGaps,_that.reasoning,_that.evidenceSpans,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ATSReportV2 implements ATSReportV2 {
   _ATSReportV2({@JsonKey(name: 'schema_version') this.schemaVersion = kAtsReportV2SchemaVersion, @JsonKey(name: 'report_id') required this.reportId, @JsonKey(name: 'document_id') required this.documentId, required this.target, @JsonKey(name: 'ats_test_matrix_version') required this.atsTestMatrixVersion, @JsonKey(name: 'keyword_match_version') required this.keywordMatchVersion, @JsonKey(name: 'extractable_fields') required final  List<ATSExtractableField> extractableFields, @JsonKey(name: 'matched_keywords') final  List<String> matchedKeywords = const <String>[], @JsonKey(name: 'coverage_gaps') required final  List<ATSCoverageGap> coverageGaps, required this.reasoning, @JsonKey(name: 'evidence_spans') required final  List<EvidenceSpan> evidenceSpans, @JsonKey(name: 'created_at') required this.createdAt}): assert(extractableFields.isNotEmpty, 'extractableFields must not be empty'),assert(coverageGaps.isNotEmpty, 'coverageGaps must not be empty'),assert(evidenceSpans.isNotEmpty, 'evidenceSpans must not be empty'),_extractableFields = extractableFields,_matchedKeywords = matchedKeywords,_coverageGaps = coverageGaps,_evidenceSpans = evidenceSpans;
  factory _ATSReportV2.fromJson(Map<String, dynamic> json) => _$ATSReportV2FromJson(json);

@override@JsonKey(name: 'schema_version') final  String schemaVersion;
@override@JsonKey(name: 'report_id') final  String reportId;
@override@JsonKey(name: 'document_id') final  String documentId;
@override final  TargetRoleCompany target;
@override@JsonKey(name: 'ats_test_matrix_version') final  String atsTestMatrixVersion;
@override@JsonKey(name: 'keyword_match_version') final  String keywordMatchVersion;
 final  List<ATSExtractableField> _extractableFields;
@override@JsonKey(name: 'extractable_fields') List<ATSExtractableField> get extractableFields {
  if (_extractableFields is EqualUnmodifiableListView) return _extractableFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extractableFields);
}

 final  List<String> _matchedKeywords;
@override@JsonKey(name: 'matched_keywords') List<String> get matchedKeywords {
  if (_matchedKeywords is EqualUnmodifiableListView) return _matchedKeywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_matchedKeywords);
}

 final  List<ATSCoverageGap> _coverageGaps;
@override@JsonKey(name: 'coverage_gaps') List<ATSCoverageGap> get coverageGaps {
  if (_coverageGaps is EqualUnmodifiableListView) return _coverageGaps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_coverageGaps);
}

@override final  String reasoning;
 final  List<EvidenceSpan> _evidenceSpans;
@override@JsonKey(name: 'evidence_spans') List<EvidenceSpan> get evidenceSpans {
  if (_evidenceSpans is EqualUnmodifiableListView) return _evidenceSpans;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidenceSpans);
}

@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of ATSReportV2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ATSReportV2CopyWith<_ATSReportV2> get copyWith => __$ATSReportV2CopyWithImpl<_ATSReportV2>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ATSReportV2ToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ATSReportV2&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.target, target) || other.target == target)&&(identical(other.atsTestMatrixVersion, atsTestMatrixVersion) || other.atsTestMatrixVersion == atsTestMatrixVersion)&&(identical(other.keywordMatchVersion, keywordMatchVersion) || other.keywordMatchVersion == keywordMatchVersion)&&const DeepCollectionEquality().equals(other._extractableFields, _extractableFields)&&const DeepCollectionEquality().equals(other._matchedKeywords, _matchedKeywords)&&const DeepCollectionEquality().equals(other._coverageGaps, _coverageGaps)&&(identical(other.reasoning, reasoning) || other.reasoning == reasoning)&&const DeepCollectionEquality().equals(other._evidenceSpans, _evidenceSpans)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,reportId,documentId,target,atsTestMatrixVersion,keywordMatchVersion,const DeepCollectionEquality().hash(_extractableFields),const DeepCollectionEquality().hash(_matchedKeywords),const DeepCollectionEquality().hash(_coverageGaps),reasoning,const DeepCollectionEquality().hash(_evidenceSpans),createdAt);

@override
String toString() {
  return 'ATSReportV2(schemaVersion: $schemaVersion, reportId: $reportId, documentId: $documentId, target: $target, atsTestMatrixVersion: $atsTestMatrixVersion, keywordMatchVersion: $keywordMatchVersion, extractableFields: $extractableFields, matchedKeywords: $matchedKeywords, coverageGaps: $coverageGaps, reasoning: $reasoning, evidenceSpans: $evidenceSpans, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ATSReportV2CopyWith<$Res> implements $ATSReportV2CopyWith<$Res> {
  factory _$ATSReportV2CopyWith(_ATSReportV2 value, $Res Function(_ATSReportV2) _then) = __$ATSReportV2CopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'schema_version') String schemaVersion,@JsonKey(name: 'report_id') String reportId,@JsonKey(name: 'document_id') String documentId, TargetRoleCompany target,@JsonKey(name: 'ats_test_matrix_version') String atsTestMatrixVersion,@JsonKey(name: 'keyword_match_version') String keywordMatchVersion,@JsonKey(name: 'extractable_fields') List<ATSExtractableField> extractableFields,@JsonKey(name: 'matched_keywords') List<String> matchedKeywords,@JsonKey(name: 'coverage_gaps') List<ATSCoverageGap> coverageGaps, String reasoning,@JsonKey(name: 'evidence_spans') List<EvidenceSpan> evidenceSpans,@JsonKey(name: 'created_at') DateTime createdAt
});


@override $TargetRoleCompanyCopyWith<$Res> get target;

}
/// @nodoc
class __$ATSReportV2CopyWithImpl<$Res>
    implements _$ATSReportV2CopyWith<$Res> {
  __$ATSReportV2CopyWithImpl(this._self, this._then);

  final _ATSReportV2 _self;
  final $Res Function(_ATSReportV2) _then;

/// Create a copy of ATSReportV2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? reportId = null,Object? documentId = null,Object? target = null,Object? atsTestMatrixVersion = null,Object? keywordMatchVersion = null,Object? extractableFields = null,Object? matchedKeywords = null,Object? coverageGaps = null,Object? reasoning = null,Object? evidenceSpans = null,Object? createdAt = null,}) {
  return _then(_ATSReportV2(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as String,reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String,documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as TargetRoleCompany,atsTestMatrixVersion: null == atsTestMatrixVersion ? _self.atsTestMatrixVersion : atsTestMatrixVersion // ignore: cast_nullable_to_non_nullable
as String,keywordMatchVersion: null == keywordMatchVersion ? _self.keywordMatchVersion : keywordMatchVersion // ignore: cast_nullable_to_non_nullable
as String,extractableFields: null == extractableFields ? _self._extractableFields : extractableFields // ignore: cast_nullable_to_non_nullable
as List<ATSExtractableField>,matchedKeywords: null == matchedKeywords ? _self._matchedKeywords : matchedKeywords // ignore: cast_nullable_to_non_nullable
as List<String>,coverageGaps: null == coverageGaps ? _self._coverageGaps : coverageGaps // ignore: cast_nullable_to_non_nullable
as List<ATSCoverageGap>,reasoning: null == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String,evidenceSpans: null == evidenceSpans ? _self._evidenceSpans : evidenceSpans // ignore: cast_nullable_to_non_nullable
as List<EvidenceSpan>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of ATSReportV2
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
