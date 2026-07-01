// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_inspection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocalInspection {

 String get id; DateTime get createdAt; DateTime? get updatedAt; LocalStatus get status; bool get isCompleted; int? get inspectionId; int get currentSection; Map<String, dynamic>? get vehicleDetails; Map<String, dynamic>? get inspectionTemplate;// Working per-item draft state (keyed by field uniqueId).
 Map<String, String> get itemValues; Map<String, String> get itemRemarks; Map<String, String> get textFieldValues; Map<String, String> get itemImages; Map<String, String> get itemVideos; Map<String, String> get itemAudios; Map<String, String> get itemFiles; Map<String, List<String>> get itemMultiImages; Map<String, List<String>> get itemFlaggedIssues;// Submission.
 Map<String, dynamic>? get submissionData; List<PendingMedia> get pendingMedia;
/// Create a copy of LocalInspection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalInspectionCopyWith<LocalInspection> get copyWith => _$LocalInspectionCopyWithImpl<LocalInspection>(this as LocalInspection, _$identity);

  /// Serializes this LocalInspection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalInspection&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.inspectionId, inspectionId) || other.inspectionId == inspectionId)&&(identical(other.currentSection, currentSection) || other.currentSection == currentSection)&&const DeepCollectionEquality().equals(other.vehicleDetails, vehicleDetails)&&const DeepCollectionEquality().equals(other.inspectionTemplate, inspectionTemplate)&&const DeepCollectionEquality().equals(other.itemValues, itemValues)&&const DeepCollectionEquality().equals(other.itemRemarks, itemRemarks)&&const DeepCollectionEquality().equals(other.textFieldValues, textFieldValues)&&const DeepCollectionEquality().equals(other.itemImages, itemImages)&&const DeepCollectionEquality().equals(other.itemVideos, itemVideos)&&const DeepCollectionEquality().equals(other.itemAudios, itemAudios)&&const DeepCollectionEquality().equals(other.itemFiles, itemFiles)&&const DeepCollectionEquality().equals(other.itemMultiImages, itemMultiImages)&&const DeepCollectionEquality().equals(other.itemFlaggedIssues, itemFlaggedIssues)&&const DeepCollectionEquality().equals(other.submissionData, submissionData)&&const DeepCollectionEquality().equals(other.pendingMedia, pendingMedia));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,createdAt,updatedAt,status,isCompleted,inspectionId,currentSection,const DeepCollectionEquality().hash(vehicleDetails),const DeepCollectionEquality().hash(inspectionTemplate),const DeepCollectionEquality().hash(itemValues),const DeepCollectionEquality().hash(itemRemarks),const DeepCollectionEquality().hash(textFieldValues),const DeepCollectionEquality().hash(itemImages),const DeepCollectionEquality().hash(itemVideos),const DeepCollectionEquality().hash(itemAudios),const DeepCollectionEquality().hash(itemFiles),const DeepCollectionEquality().hash(itemMultiImages),const DeepCollectionEquality().hash(itemFlaggedIssues),const DeepCollectionEquality().hash(submissionData),const DeepCollectionEquality().hash(pendingMedia)]);

@override
String toString() {
  return 'LocalInspection(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, isCompleted: $isCompleted, inspectionId: $inspectionId, currentSection: $currentSection, vehicleDetails: $vehicleDetails, inspectionTemplate: $inspectionTemplate, itemValues: $itemValues, itemRemarks: $itemRemarks, textFieldValues: $textFieldValues, itemImages: $itemImages, itemVideos: $itemVideos, itemAudios: $itemAudios, itemFiles: $itemFiles, itemMultiImages: $itemMultiImages, itemFlaggedIssues: $itemFlaggedIssues, submissionData: $submissionData, pendingMedia: $pendingMedia)';
}


}

/// @nodoc
abstract mixin class $LocalInspectionCopyWith<$Res>  {
  factory $LocalInspectionCopyWith(LocalInspection value, $Res Function(LocalInspection) _then) = _$LocalInspectionCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, DateTime? updatedAt, LocalStatus status, bool isCompleted, int? inspectionId, int currentSection, Map<String, dynamic>? vehicleDetails, Map<String, dynamic>? inspectionTemplate, Map<String, String> itemValues, Map<String, String> itemRemarks, Map<String, String> textFieldValues, Map<String, String> itemImages, Map<String, String> itemVideos, Map<String, String> itemAudios, Map<String, String> itemFiles, Map<String, List<String>> itemMultiImages, Map<String, List<String>> itemFlaggedIssues, Map<String, dynamic>? submissionData, List<PendingMedia> pendingMedia
});




}
/// @nodoc
class _$LocalInspectionCopyWithImpl<$Res>
    implements $LocalInspectionCopyWith<$Res> {
  _$LocalInspectionCopyWithImpl(this._self, this._then);

  final LocalInspection _self;
  final $Res Function(LocalInspection) _then;

/// Create a copy of LocalInspection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = freezed,Object? status = null,Object? isCompleted = null,Object? inspectionId = freezed,Object? currentSection = null,Object? vehicleDetails = freezed,Object? inspectionTemplate = freezed,Object? itemValues = null,Object? itemRemarks = null,Object? textFieldValues = null,Object? itemImages = null,Object? itemVideos = null,Object? itemAudios = null,Object? itemFiles = null,Object? itemMultiImages = null,Object? itemFlaggedIssues = null,Object? submissionData = freezed,Object? pendingMedia = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LocalStatus,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,inspectionId: freezed == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as int?,currentSection: null == currentSection ? _self.currentSection : currentSection // ignore: cast_nullable_to_non_nullable
as int,vehicleDetails: freezed == vehicleDetails ? _self.vehicleDetails : vehicleDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,inspectionTemplate: freezed == inspectionTemplate ? _self.inspectionTemplate : inspectionTemplate // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,itemValues: null == itemValues ? _self.itemValues : itemValues // ignore: cast_nullable_to_non_nullable
as Map<String, String>,itemRemarks: null == itemRemarks ? _self.itemRemarks : itemRemarks // ignore: cast_nullable_to_non_nullable
as Map<String, String>,textFieldValues: null == textFieldValues ? _self.textFieldValues : textFieldValues // ignore: cast_nullable_to_non_nullable
as Map<String, String>,itemImages: null == itemImages ? _self.itemImages : itemImages // ignore: cast_nullable_to_non_nullable
as Map<String, String>,itemVideos: null == itemVideos ? _self.itemVideos : itemVideos // ignore: cast_nullable_to_non_nullable
as Map<String, String>,itemAudios: null == itemAudios ? _self.itemAudios : itemAudios // ignore: cast_nullable_to_non_nullable
as Map<String, String>,itemFiles: null == itemFiles ? _self.itemFiles : itemFiles // ignore: cast_nullable_to_non_nullable
as Map<String, String>,itemMultiImages: null == itemMultiImages ? _self.itemMultiImages : itemMultiImages // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,itemFlaggedIssues: null == itemFlaggedIssues ? _self.itemFlaggedIssues : itemFlaggedIssues // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,submissionData: freezed == submissionData ? _self.submissionData : submissionData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,pendingMedia: null == pendingMedia ? _self.pendingMedia : pendingMedia // ignore: cast_nullable_to_non_nullable
as List<PendingMedia>,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalInspection].
extension LocalInspectionPatterns on LocalInspection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalInspection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalInspection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalInspection value)  $default,){
final _that = this;
switch (_that) {
case _LocalInspection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalInspection value)?  $default,){
final _that = this;
switch (_that) {
case _LocalInspection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime? updatedAt,  LocalStatus status,  bool isCompleted,  int? inspectionId,  int currentSection,  Map<String, dynamic>? vehicleDetails,  Map<String, dynamic>? inspectionTemplate,  Map<String, String> itemValues,  Map<String, String> itemRemarks,  Map<String, String> textFieldValues,  Map<String, String> itemImages,  Map<String, String> itemVideos,  Map<String, String> itemAudios,  Map<String, String> itemFiles,  Map<String, List<String>> itemMultiImages,  Map<String, List<String>> itemFlaggedIssues,  Map<String, dynamic>? submissionData,  List<PendingMedia> pendingMedia)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalInspection() when $default != null:
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.status,_that.isCompleted,_that.inspectionId,_that.currentSection,_that.vehicleDetails,_that.inspectionTemplate,_that.itemValues,_that.itemRemarks,_that.textFieldValues,_that.itemImages,_that.itemVideos,_that.itemAudios,_that.itemFiles,_that.itemMultiImages,_that.itemFlaggedIssues,_that.submissionData,_that.pendingMedia);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime? updatedAt,  LocalStatus status,  bool isCompleted,  int? inspectionId,  int currentSection,  Map<String, dynamic>? vehicleDetails,  Map<String, dynamic>? inspectionTemplate,  Map<String, String> itemValues,  Map<String, String> itemRemarks,  Map<String, String> textFieldValues,  Map<String, String> itemImages,  Map<String, String> itemVideos,  Map<String, String> itemAudios,  Map<String, String> itemFiles,  Map<String, List<String>> itemMultiImages,  Map<String, List<String>> itemFlaggedIssues,  Map<String, dynamic>? submissionData,  List<PendingMedia> pendingMedia)  $default,) {final _that = this;
switch (_that) {
case _LocalInspection():
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.status,_that.isCompleted,_that.inspectionId,_that.currentSection,_that.vehicleDetails,_that.inspectionTemplate,_that.itemValues,_that.itemRemarks,_that.textFieldValues,_that.itemImages,_that.itemVideos,_that.itemAudios,_that.itemFiles,_that.itemMultiImages,_that.itemFlaggedIssues,_that.submissionData,_that.pendingMedia);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  DateTime? updatedAt,  LocalStatus status,  bool isCompleted,  int? inspectionId,  int currentSection,  Map<String, dynamic>? vehicleDetails,  Map<String, dynamic>? inspectionTemplate,  Map<String, String> itemValues,  Map<String, String> itemRemarks,  Map<String, String> textFieldValues,  Map<String, String> itemImages,  Map<String, String> itemVideos,  Map<String, String> itemAudios,  Map<String, String> itemFiles,  Map<String, List<String>> itemMultiImages,  Map<String, List<String>> itemFlaggedIssues,  Map<String, dynamic>? submissionData,  List<PendingMedia> pendingMedia)?  $default,) {final _that = this;
switch (_that) {
case _LocalInspection() when $default != null:
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.status,_that.isCompleted,_that.inspectionId,_that.currentSection,_that.vehicleDetails,_that.inspectionTemplate,_that.itemValues,_that.itemRemarks,_that.textFieldValues,_that.itemImages,_that.itemVideos,_that.itemAudios,_that.itemFiles,_that.itemMultiImages,_that.itemFlaggedIssues,_that.submissionData,_that.pendingMedia);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalInspection extends LocalInspection {
  const _LocalInspection({required this.id, required this.createdAt, this.updatedAt, this.status = LocalStatus.draft, this.isCompleted = false, this.inspectionId, this.currentSection = 0, final  Map<String, dynamic>? vehicleDetails, final  Map<String, dynamic>? inspectionTemplate, final  Map<String, String> itemValues = const <String, String>{}, final  Map<String, String> itemRemarks = const <String, String>{}, final  Map<String, String> textFieldValues = const <String, String>{}, final  Map<String, String> itemImages = const <String, String>{}, final  Map<String, String> itemVideos = const <String, String>{}, final  Map<String, String> itemAudios = const <String, String>{}, final  Map<String, String> itemFiles = const <String, String>{}, final  Map<String, List<String>> itemMultiImages = const <String, List<String>>{}, final  Map<String, List<String>> itemFlaggedIssues = const <String, List<String>>{}, final  Map<String, dynamic>? submissionData, final  List<PendingMedia> pendingMedia = const <PendingMedia>[]}): _vehicleDetails = vehicleDetails,_inspectionTemplate = inspectionTemplate,_itemValues = itemValues,_itemRemarks = itemRemarks,_textFieldValues = textFieldValues,_itemImages = itemImages,_itemVideos = itemVideos,_itemAudios = itemAudios,_itemFiles = itemFiles,_itemMultiImages = itemMultiImages,_itemFlaggedIssues = itemFlaggedIssues,_submissionData = submissionData,_pendingMedia = pendingMedia,super._();
  factory _LocalInspection.fromJson(Map<String, dynamic> json) => _$LocalInspectionFromJson(json);

@override final  String id;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
@override@JsonKey() final  LocalStatus status;
@override@JsonKey() final  bool isCompleted;
@override final  int? inspectionId;
@override@JsonKey() final  int currentSection;
 final  Map<String, dynamic>? _vehicleDetails;
@override Map<String, dynamic>? get vehicleDetails {
  final value = _vehicleDetails;
  if (value == null) return null;
  if (_vehicleDetails is EqualUnmodifiableMapView) return _vehicleDetails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _inspectionTemplate;
@override Map<String, dynamic>? get inspectionTemplate {
  final value = _inspectionTemplate;
  if (value == null) return null;
  if (_inspectionTemplate is EqualUnmodifiableMapView) return _inspectionTemplate;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Working per-item draft state (keyed by field uniqueId).
 final  Map<String, String> _itemValues;
// Working per-item draft state (keyed by field uniqueId).
@override@JsonKey() Map<String, String> get itemValues {
  if (_itemValues is EqualUnmodifiableMapView) return _itemValues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_itemValues);
}

 final  Map<String, String> _itemRemarks;
@override@JsonKey() Map<String, String> get itemRemarks {
  if (_itemRemarks is EqualUnmodifiableMapView) return _itemRemarks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_itemRemarks);
}

 final  Map<String, String> _textFieldValues;
@override@JsonKey() Map<String, String> get textFieldValues {
  if (_textFieldValues is EqualUnmodifiableMapView) return _textFieldValues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_textFieldValues);
}

 final  Map<String, String> _itemImages;
@override@JsonKey() Map<String, String> get itemImages {
  if (_itemImages is EqualUnmodifiableMapView) return _itemImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_itemImages);
}

 final  Map<String, String> _itemVideos;
@override@JsonKey() Map<String, String> get itemVideos {
  if (_itemVideos is EqualUnmodifiableMapView) return _itemVideos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_itemVideos);
}

 final  Map<String, String> _itemAudios;
@override@JsonKey() Map<String, String> get itemAudios {
  if (_itemAudios is EqualUnmodifiableMapView) return _itemAudios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_itemAudios);
}

 final  Map<String, String> _itemFiles;
@override@JsonKey() Map<String, String> get itemFiles {
  if (_itemFiles is EqualUnmodifiableMapView) return _itemFiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_itemFiles);
}

 final  Map<String, List<String>> _itemMultiImages;
@override@JsonKey() Map<String, List<String>> get itemMultiImages {
  if (_itemMultiImages is EqualUnmodifiableMapView) return _itemMultiImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_itemMultiImages);
}

 final  Map<String, List<String>> _itemFlaggedIssues;
@override@JsonKey() Map<String, List<String>> get itemFlaggedIssues {
  if (_itemFlaggedIssues is EqualUnmodifiableMapView) return _itemFlaggedIssues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_itemFlaggedIssues);
}

// Submission.
 final  Map<String, dynamic>? _submissionData;
// Submission.
@override Map<String, dynamic>? get submissionData {
  final value = _submissionData;
  if (value == null) return null;
  if (_submissionData is EqualUnmodifiableMapView) return _submissionData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<PendingMedia> _pendingMedia;
@override@JsonKey() List<PendingMedia> get pendingMedia {
  if (_pendingMedia is EqualUnmodifiableListView) return _pendingMedia;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendingMedia);
}


/// Create a copy of LocalInspection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalInspectionCopyWith<_LocalInspection> get copyWith => __$LocalInspectionCopyWithImpl<_LocalInspection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalInspectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalInspection&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.inspectionId, inspectionId) || other.inspectionId == inspectionId)&&(identical(other.currentSection, currentSection) || other.currentSection == currentSection)&&const DeepCollectionEquality().equals(other._vehicleDetails, _vehicleDetails)&&const DeepCollectionEquality().equals(other._inspectionTemplate, _inspectionTemplate)&&const DeepCollectionEquality().equals(other._itemValues, _itemValues)&&const DeepCollectionEquality().equals(other._itemRemarks, _itemRemarks)&&const DeepCollectionEquality().equals(other._textFieldValues, _textFieldValues)&&const DeepCollectionEquality().equals(other._itemImages, _itemImages)&&const DeepCollectionEquality().equals(other._itemVideos, _itemVideos)&&const DeepCollectionEquality().equals(other._itemAudios, _itemAudios)&&const DeepCollectionEquality().equals(other._itemFiles, _itemFiles)&&const DeepCollectionEquality().equals(other._itemMultiImages, _itemMultiImages)&&const DeepCollectionEquality().equals(other._itemFlaggedIssues, _itemFlaggedIssues)&&const DeepCollectionEquality().equals(other._submissionData, _submissionData)&&const DeepCollectionEquality().equals(other._pendingMedia, _pendingMedia));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,createdAt,updatedAt,status,isCompleted,inspectionId,currentSection,const DeepCollectionEquality().hash(_vehicleDetails),const DeepCollectionEquality().hash(_inspectionTemplate),const DeepCollectionEquality().hash(_itemValues),const DeepCollectionEquality().hash(_itemRemarks),const DeepCollectionEquality().hash(_textFieldValues),const DeepCollectionEquality().hash(_itemImages),const DeepCollectionEquality().hash(_itemVideos),const DeepCollectionEquality().hash(_itemAudios),const DeepCollectionEquality().hash(_itemFiles),const DeepCollectionEquality().hash(_itemMultiImages),const DeepCollectionEquality().hash(_itemFlaggedIssues),const DeepCollectionEquality().hash(_submissionData),const DeepCollectionEquality().hash(_pendingMedia)]);

@override
String toString() {
  return 'LocalInspection(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, isCompleted: $isCompleted, inspectionId: $inspectionId, currentSection: $currentSection, vehicleDetails: $vehicleDetails, inspectionTemplate: $inspectionTemplate, itemValues: $itemValues, itemRemarks: $itemRemarks, textFieldValues: $textFieldValues, itemImages: $itemImages, itemVideos: $itemVideos, itemAudios: $itemAudios, itemFiles: $itemFiles, itemMultiImages: $itemMultiImages, itemFlaggedIssues: $itemFlaggedIssues, submissionData: $submissionData, pendingMedia: $pendingMedia)';
}


}

/// @nodoc
abstract mixin class _$LocalInspectionCopyWith<$Res> implements $LocalInspectionCopyWith<$Res> {
  factory _$LocalInspectionCopyWith(_LocalInspection value, $Res Function(_LocalInspection) _then) = __$LocalInspectionCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, DateTime? updatedAt, LocalStatus status, bool isCompleted, int? inspectionId, int currentSection, Map<String, dynamic>? vehicleDetails, Map<String, dynamic>? inspectionTemplate, Map<String, String> itemValues, Map<String, String> itemRemarks, Map<String, String> textFieldValues, Map<String, String> itemImages, Map<String, String> itemVideos, Map<String, String> itemAudios, Map<String, String> itemFiles, Map<String, List<String>> itemMultiImages, Map<String, List<String>> itemFlaggedIssues, Map<String, dynamic>? submissionData, List<PendingMedia> pendingMedia
});




}
/// @nodoc
class __$LocalInspectionCopyWithImpl<$Res>
    implements _$LocalInspectionCopyWith<$Res> {
  __$LocalInspectionCopyWithImpl(this._self, this._then);

  final _LocalInspection _self;
  final $Res Function(_LocalInspection) _then;

/// Create a copy of LocalInspection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = freezed,Object? status = null,Object? isCompleted = null,Object? inspectionId = freezed,Object? currentSection = null,Object? vehicleDetails = freezed,Object? inspectionTemplate = freezed,Object? itemValues = null,Object? itemRemarks = null,Object? textFieldValues = null,Object? itemImages = null,Object? itemVideos = null,Object? itemAudios = null,Object? itemFiles = null,Object? itemMultiImages = null,Object? itemFlaggedIssues = null,Object? submissionData = freezed,Object? pendingMedia = null,}) {
  return _then(_LocalInspection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LocalStatus,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,inspectionId: freezed == inspectionId ? _self.inspectionId : inspectionId // ignore: cast_nullable_to_non_nullable
as int?,currentSection: null == currentSection ? _self.currentSection : currentSection // ignore: cast_nullable_to_non_nullable
as int,vehicleDetails: freezed == vehicleDetails ? _self._vehicleDetails : vehicleDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,inspectionTemplate: freezed == inspectionTemplate ? _self._inspectionTemplate : inspectionTemplate // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,itemValues: null == itemValues ? _self._itemValues : itemValues // ignore: cast_nullable_to_non_nullable
as Map<String, String>,itemRemarks: null == itemRemarks ? _self._itemRemarks : itemRemarks // ignore: cast_nullable_to_non_nullable
as Map<String, String>,textFieldValues: null == textFieldValues ? _self._textFieldValues : textFieldValues // ignore: cast_nullable_to_non_nullable
as Map<String, String>,itemImages: null == itemImages ? _self._itemImages : itemImages // ignore: cast_nullable_to_non_nullable
as Map<String, String>,itemVideos: null == itemVideos ? _self._itemVideos : itemVideos // ignore: cast_nullable_to_non_nullable
as Map<String, String>,itemAudios: null == itemAudios ? _self._itemAudios : itemAudios // ignore: cast_nullable_to_non_nullable
as Map<String, String>,itemFiles: null == itemFiles ? _self._itemFiles : itemFiles // ignore: cast_nullable_to_non_nullable
as Map<String, String>,itemMultiImages: null == itemMultiImages ? _self._itemMultiImages : itemMultiImages // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,itemFlaggedIssues: null == itemFlaggedIssues ? _self._itemFlaggedIssues : itemFlaggedIssues // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,submissionData: freezed == submissionData ? _self._submissionData : submissionData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,pendingMedia: null == pendingMedia ? _self._pendingMedia : pendingMedia // ignore: cast_nullable_to_non_nullable
as List<PendingMedia>,
  ));
}


}


/// @nodoc
mixin _$PendingMedia {

 String get localPath; String get section; String get itemId; String get kind;
/// Create a copy of PendingMedia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingMediaCopyWith<PendingMedia> get copyWith => _$PendingMediaCopyWithImpl<PendingMedia>(this as PendingMedia, _$identity);

  /// Serializes this PendingMedia to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingMedia&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.section, section) || other.section == section)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.kind, kind) || other.kind == kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,localPath,section,itemId,kind);

@override
String toString() {
  return 'PendingMedia(localPath: $localPath, section: $section, itemId: $itemId, kind: $kind)';
}


}

/// @nodoc
abstract mixin class $PendingMediaCopyWith<$Res>  {
  factory $PendingMediaCopyWith(PendingMedia value, $Res Function(PendingMedia) _then) = _$PendingMediaCopyWithImpl;
@useResult
$Res call({
 String localPath, String section, String itemId, String kind
});




}
/// @nodoc
class _$PendingMediaCopyWithImpl<$Res>
    implements $PendingMediaCopyWith<$Res> {
  _$PendingMediaCopyWithImpl(this._self, this._then);

  final PendingMedia _self;
  final $Res Function(PendingMedia) _then;

/// Create a copy of PendingMedia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? localPath = null,Object? section = null,Object? itemId = null,Object? kind = null,}) {
  return _then(_self.copyWith(
localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingMedia].
extension PendingMediaPatterns on PendingMedia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingMedia value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingMedia() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingMedia value)  $default,){
final _that = this;
switch (_that) {
case _PendingMedia():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingMedia value)?  $default,){
final _that = this;
switch (_that) {
case _PendingMedia() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String localPath,  String section,  String itemId,  String kind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingMedia() when $default != null:
return $default(_that.localPath,_that.section,_that.itemId,_that.kind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String localPath,  String section,  String itemId,  String kind)  $default,) {final _that = this;
switch (_that) {
case _PendingMedia():
return $default(_that.localPath,_that.section,_that.itemId,_that.kind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String localPath,  String section,  String itemId,  String kind)?  $default,) {final _that = this;
switch (_that) {
case _PendingMedia() when $default != null:
return $default(_that.localPath,_that.section,_that.itemId,_that.kind);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingMedia implements PendingMedia {
  const _PendingMedia({required this.localPath, required this.section, required this.itemId, this.kind = 'image'});
  factory _PendingMedia.fromJson(Map<String, dynamic> json) => _$PendingMediaFromJson(json);

@override final  String localPath;
@override final  String section;
@override final  String itemId;
@override@JsonKey() final  String kind;

/// Create a copy of PendingMedia
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingMediaCopyWith<_PendingMedia> get copyWith => __$PendingMediaCopyWithImpl<_PendingMedia>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingMediaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingMedia&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.section, section) || other.section == section)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.kind, kind) || other.kind == kind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,localPath,section,itemId,kind);

@override
String toString() {
  return 'PendingMedia(localPath: $localPath, section: $section, itemId: $itemId, kind: $kind)';
}


}

/// @nodoc
abstract mixin class _$PendingMediaCopyWith<$Res> implements $PendingMediaCopyWith<$Res> {
  factory _$PendingMediaCopyWith(_PendingMedia value, $Res Function(_PendingMedia) _then) = __$PendingMediaCopyWithImpl;
@override @useResult
$Res call({
 String localPath, String section, String itemId, String kind
});




}
/// @nodoc
class __$PendingMediaCopyWithImpl<$Res>
    implements _$PendingMediaCopyWith<$Res> {
  __$PendingMediaCopyWithImpl(this._self, this._then);

  final _PendingMedia _self;
  final $Res Function(_PendingMedia) _then;

/// Create a copy of PendingMedia
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? localPath = null,Object? section = null,Object? itemId = null,Object? kind = null,}) {
  return _then(_PendingMedia(
localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
