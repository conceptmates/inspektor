// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_template_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InspectionInitializationResponse {

@JsonKey(readValue: _readTemplateType) InspectionTemplate? get templateType;@JsonKey(readValue: _readVehicleInfo) VehicleInfo? get vehicleInfo; InspectionStructure get structure;// Resume payload: previously-saved answers + already-uploaded media URLs,
// flattened to `fieldKey -> {value, remarks, image, multiImages, video,
// audio, file}`. Read from BOTH `saved_sections` and a top-level `fields[]`
// (the server carries resumed data in either shape across versions).
@JsonKey(readValue: _readSaved, fromJson: _parseSavedFields) Map<String, Map<String, dynamic>> get savedFields;
/// Create a copy of InspectionInitializationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionInitializationResponseCopyWith<InspectionInitializationResponse> get copyWith => _$InspectionInitializationResponseCopyWithImpl<InspectionInitializationResponse>(this as InspectionInitializationResponse, _$identity);

  /// Serializes this InspectionInitializationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionInitializationResponse&&(identical(other.templateType, templateType) || other.templateType == templateType)&&(identical(other.vehicleInfo, vehicleInfo) || other.vehicleInfo == vehicleInfo)&&(identical(other.structure, structure) || other.structure == structure)&&const DeepCollectionEquality().equals(other.savedFields, savedFields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,templateType,vehicleInfo,structure,const DeepCollectionEquality().hash(savedFields));

@override
String toString() {
  return 'InspectionInitializationResponse(templateType: $templateType, vehicleInfo: $vehicleInfo, structure: $structure, savedFields: $savedFields)';
}


}

/// @nodoc
abstract mixin class $InspectionInitializationResponseCopyWith<$Res>  {
  factory $InspectionInitializationResponseCopyWith(InspectionInitializationResponse value, $Res Function(InspectionInitializationResponse) _then) = _$InspectionInitializationResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readTemplateType) InspectionTemplate? templateType,@JsonKey(readValue: _readVehicleInfo) VehicleInfo? vehicleInfo, InspectionStructure structure,@JsonKey(readValue: _readSaved, fromJson: _parseSavedFields) Map<String, Map<String, dynamic>> savedFields
});


$InspectionTemplateCopyWith<$Res>? get templateType;$VehicleInfoCopyWith<$Res>? get vehicleInfo;$InspectionStructureCopyWith<$Res> get structure;

}
/// @nodoc
class _$InspectionInitializationResponseCopyWithImpl<$Res>
    implements $InspectionInitializationResponseCopyWith<$Res> {
  _$InspectionInitializationResponseCopyWithImpl(this._self, this._then);

  final InspectionInitializationResponse _self;
  final $Res Function(InspectionInitializationResponse) _then;

/// Create a copy of InspectionInitializationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? templateType = freezed,Object? vehicleInfo = freezed,Object? structure = null,Object? savedFields = null,}) {
  return _then(_self.copyWith(
templateType: freezed == templateType ? _self.templateType : templateType // ignore: cast_nullable_to_non_nullable
as InspectionTemplate?,vehicleInfo: freezed == vehicleInfo ? _self.vehicleInfo : vehicleInfo // ignore: cast_nullable_to_non_nullable
as VehicleInfo?,structure: null == structure ? _self.structure : structure // ignore: cast_nullable_to_non_nullable
as InspectionStructure,savedFields: null == savedFields ? _self.savedFields : savedFields // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, dynamic>>,
  ));
}
/// Create a copy of InspectionInitializationResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InspectionTemplateCopyWith<$Res>? get templateType {
    if (_self.templateType == null) {
    return null;
  }

  return $InspectionTemplateCopyWith<$Res>(_self.templateType!, (value) {
    return _then(_self.copyWith(templateType: value));
  });
}/// Create a copy of InspectionInitializationResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleInfoCopyWith<$Res>? get vehicleInfo {
    if (_self.vehicleInfo == null) {
    return null;
  }

  return $VehicleInfoCopyWith<$Res>(_self.vehicleInfo!, (value) {
    return _then(_self.copyWith(vehicleInfo: value));
  });
}/// Create a copy of InspectionInitializationResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InspectionStructureCopyWith<$Res> get structure {
  
  return $InspectionStructureCopyWith<$Res>(_self.structure, (value) {
    return _then(_self.copyWith(structure: value));
  });
}
}


/// Adds pattern-matching-related methods to [InspectionInitializationResponse].
extension InspectionInitializationResponsePatterns on InspectionInitializationResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionInitializationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionInitializationResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionInitializationResponse value)  $default,){
final _that = this;
switch (_that) {
case _InspectionInitializationResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionInitializationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionInitializationResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readTemplateType)  InspectionTemplate? templateType, @JsonKey(readValue: _readVehicleInfo)  VehicleInfo? vehicleInfo,  InspectionStructure structure, @JsonKey(readValue: _readSaved, fromJson: _parseSavedFields)  Map<String, Map<String, dynamic>> savedFields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionInitializationResponse() when $default != null:
return $default(_that.templateType,_that.vehicleInfo,_that.structure,_that.savedFields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readTemplateType)  InspectionTemplate? templateType, @JsonKey(readValue: _readVehicleInfo)  VehicleInfo? vehicleInfo,  InspectionStructure structure, @JsonKey(readValue: _readSaved, fromJson: _parseSavedFields)  Map<String, Map<String, dynamic>> savedFields)  $default,) {final _that = this;
switch (_that) {
case _InspectionInitializationResponse():
return $default(_that.templateType,_that.vehicleInfo,_that.structure,_that.savedFields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readTemplateType)  InspectionTemplate? templateType, @JsonKey(readValue: _readVehicleInfo)  VehicleInfo? vehicleInfo,  InspectionStructure structure, @JsonKey(readValue: _readSaved, fromJson: _parseSavedFields)  Map<String, Map<String, dynamic>> savedFields)?  $default,) {final _that = this;
switch (_that) {
case _InspectionInitializationResponse() when $default != null:
return $default(_that.templateType,_that.vehicleInfo,_that.structure,_that.savedFields);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InspectionInitializationResponse implements InspectionInitializationResponse {
  const _InspectionInitializationResponse({@JsonKey(readValue: _readTemplateType) this.templateType, @JsonKey(readValue: _readVehicleInfo) this.vehicleInfo, this.structure = const InspectionStructure(), @JsonKey(readValue: _readSaved, fromJson: _parseSavedFields) final  Map<String, Map<String, dynamic>> savedFields = const <String, Map<String, dynamic>>{}}): _savedFields = savedFields;
  factory _InspectionInitializationResponse.fromJson(Map<String, dynamic> json) => _$InspectionInitializationResponseFromJson(json);

@override@JsonKey(readValue: _readTemplateType) final  InspectionTemplate? templateType;
@override@JsonKey(readValue: _readVehicleInfo) final  VehicleInfo? vehicleInfo;
@override@JsonKey() final  InspectionStructure structure;
// Resume payload: previously-saved answers + already-uploaded media URLs,
// flattened to `fieldKey -> {value, remarks, image, multiImages, video,
// audio, file}`. Read from BOTH `saved_sections` and a top-level `fields[]`
// (the server carries resumed data in either shape across versions).
 final  Map<String, Map<String, dynamic>> _savedFields;
// Resume payload: previously-saved answers + already-uploaded media URLs,
// flattened to `fieldKey -> {value, remarks, image, multiImages, video,
// audio, file}`. Read from BOTH `saved_sections` and a top-level `fields[]`
// (the server carries resumed data in either shape across versions).
@override@JsonKey(readValue: _readSaved, fromJson: _parseSavedFields) Map<String, Map<String, dynamic>> get savedFields {
  if (_savedFields is EqualUnmodifiableMapView) return _savedFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_savedFields);
}


/// Create a copy of InspectionInitializationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionInitializationResponseCopyWith<_InspectionInitializationResponse> get copyWith => __$InspectionInitializationResponseCopyWithImpl<_InspectionInitializationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionInitializationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionInitializationResponse&&(identical(other.templateType, templateType) || other.templateType == templateType)&&(identical(other.vehicleInfo, vehicleInfo) || other.vehicleInfo == vehicleInfo)&&(identical(other.structure, structure) || other.structure == structure)&&const DeepCollectionEquality().equals(other._savedFields, _savedFields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,templateType,vehicleInfo,structure,const DeepCollectionEquality().hash(_savedFields));

@override
String toString() {
  return 'InspectionInitializationResponse(templateType: $templateType, vehicleInfo: $vehicleInfo, structure: $structure, savedFields: $savedFields)';
}


}

/// @nodoc
abstract mixin class _$InspectionInitializationResponseCopyWith<$Res> implements $InspectionInitializationResponseCopyWith<$Res> {
  factory _$InspectionInitializationResponseCopyWith(_InspectionInitializationResponse value, $Res Function(_InspectionInitializationResponse) _then) = __$InspectionInitializationResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readTemplateType) InspectionTemplate? templateType,@JsonKey(readValue: _readVehicleInfo) VehicleInfo? vehicleInfo, InspectionStructure structure,@JsonKey(readValue: _readSaved, fromJson: _parseSavedFields) Map<String, Map<String, dynamic>> savedFields
});


@override $InspectionTemplateCopyWith<$Res>? get templateType;@override $VehicleInfoCopyWith<$Res>? get vehicleInfo;@override $InspectionStructureCopyWith<$Res> get structure;

}
/// @nodoc
class __$InspectionInitializationResponseCopyWithImpl<$Res>
    implements _$InspectionInitializationResponseCopyWith<$Res> {
  __$InspectionInitializationResponseCopyWithImpl(this._self, this._then);

  final _InspectionInitializationResponse _self;
  final $Res Function(_InspectionInitializationResponse) _then;

/// Create a copy of InspectionInitializationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? templateType = freezed,Object? vehicleInfo = freezed,Object? structure = null,Object? savedFields = null,}) {
  return _then(_InspectionInitializationResponse(
templateType: freezed == templateType ? _self.templateType : templateType // ignore: cast_nullable_to_non_nullable
as InspectionTemplate?,vehicleInfo: freezed == vehicleInfo ? _self.vehicleInfo : vehicleInfo // ignore: cast_nullable_to_non_nullable
as VehicleInfo?,structure: null == structure ? _self.structure : structure // ignore: cast_nullable_to_non_nullable
as InspectionStructure,savedFields: null == savedFields ? _self._savedFields : savedFields // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, dynamic>>,
  ));
}

/// Create a copy of InspectionInitializationResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InspectionTemplateCopyWith<$Res>? get templateType {
    if (_self.templateType == null) {
    return null;
  }

  return $InspectionTemplateCopyWith<$Res>(_self.templateType!, (value) {
    return _then(_self.copyWith(templateType: value));
  });
}/// Create a copy of InspectionInitializationResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleInfoCopyWith<$Res>? get vehicleInfo {
    if (_self.vehicleInfo == null) {
    return null;
  }

  return $VehicleInfoCopyWith<$Res>(_self.vehicleInfo!, (value) {
    return _then(_self.copyWith(vehicleInfo: value));
  });
}/// Create a copy of InspectionInitializationResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InspectionStructureCopyWith<$Res> get structure {
  
  return $InspectionStructureCopyWith<$Res>(_self.structure, (value) {
    return _then(_self.copyWith(structure: value));
  });
}
}


/// @nodoc
mixin _$InspectionTemplate {

 int? get id; String? get name;@JsonKey(name: 'display_name') String? get displayName; String? get description;@JsonKey(name: 'country_code') String? get countryCode;@JsonKey(name: 'has_government_api') bool get hasGovernmentApi;@JsonKey(name: 'government_api_type') String? get governmentApiType;
/// Create a copy of InspectionTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionTemplateCopyWith<InspectionTemplate> get copyWith => _$InspectionTemplateCopyWithImpl<InspectionTemplate>(this as InspectionTemplate, _$identity);

  /// Serializes this InspectionTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.hasGovernmentApi, hasGovernmentApi) || other.hasGovernmentApi == hasGovernmentApi)&&(identical(other.governmentApiType, governmentApiType) || other.governmentApiType == governmentApiType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,displayName,description,countryCode,hasGovernmentApi,governmentApiType);

@override
String toString() {
  return 'InspectionTemplate(id: $id, name: $name, displayName: $displayName, description: $description, countryCode: $countryCode, hasGovernmentApi: $hasGovernmentApi, governmentApiType: $governmentApiType)';
}


}

/// @nodoc
abstract mixin class $InspectionTemplateCopyWith<$Res>  {
  factory $InspectionTemplateCopyWith(InspectionTemplate value, $Res Function(InspectionTemplate) _then) = _$InspectionTemplateCopyWithImpl;
@useResult
$Res call({
 int? id, String? name,@JsonKey(name: 'display_name') String? displayName, String? description,@JsonKey(name: 'country_code') String? countryCode,@JsonKey(name: 'has_government_api') bool hasGovernmentApi,@JsonKey(name: 'government_api_type') String? governmentApiType
});




}
/// @nodoc
class _$InspectionTemplateCopyWithImpl<$Res>
    implements $InspectionTemplateCopyWith<$Res> {
  _$InspectionTemplateCopyWithImpl(this._self, this._then);

  final InspectionTemplate _self;
  final $Res Function(InspectionTemplate) _then;

/// Create a copy of InspectionTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? displayName = freezed,Object? description = freezed,Object? countryCode = freezed,Object? hasGovernmentApi = null,Object? governmentApiType = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,hasGovernmentApi: null == hasGovernmentApi ? _self.hasGovernmentApi : hasGovernmentApi // ignore: cast_nullable_to_non_nullable
as bool,governmentApiType: freezed == governmentApiType ? _self.governmentApiType : governmentApiType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InspectionTemplate].
extension InspectionTemplatePatterns on InspectionTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionTemplate value)  $default,){
final _that = this;
switch (_that) {
case _InspectionTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? name, @JsonKey(name: 'display_name')  String? displayName,  String? description, @JsonKey(name: 'country_code')  String? countryCode, @JsonKey(name: 'has_government_api')  bool hasGovernmentApi, @JsonKey(name: 'government_api_type')  String? governmentApiType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionTemplate() when $default != null:
return $default(_that.id,_that.name,_that.displayName,_that.description,_that.countryCode,_that.hasGovernmentApi,_that.governmentApiType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? name, @JsonKey(name: 'display_name')  String? displayName,  String? description, @JsonKey(name: 'country_code')  String? countryCode, @JsonKey(name: 'has_government_api')  bool hasGovernmentApi, @JsonKey(name: 'government_api_type')  String? governmentApiType)  $default,) {final _that = this;
switch (_that) {
case _InspectionTemplate():
return $default(_that.id,_that.name,_that.displayName,_that.description,_that.countryCode,_that.hasGovernmentApi,_that.governmentApiType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? name, @JsonKey(name: 'display_name')  String? displayName,  String? description, @JsonKey(name: 'country_code')  String? countryCode, @JsonKey(name: 'has_government_api')  bool hasGovernmentApi, @JsonKey(name: 'government_api_type')  String? governmentApiType)?  $default,) {final _that = this;
switch (_that) {
case _InspectionTemplate() when $default != null:
return $default(_that.id,_that.name,_that.displayName,_that.description,_that.countryCode,_that.hasGovernmentApi,_that.governmentApiType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InspectionTemplate implements InspectionTemplate {
  const _InspectionTemplate({this.id, this.name, @JsonKey(name: 'display_name') this.displayName, this.description, @JsonKey(name: 'country_code') this.countryCode, @JsonKey(name: 'has_government_api') this.hasGovernmentApi = false, @JsonKey(name: 'government_api_type') this.governmentApiType});
  factory _InspectionTemplate.fromJson(Map<String, dynamic> json) => _$InspectionTemplateFromJson(json);

@override final  int? id;
@override final  String? name;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override final  String? description;
@override@JsonKey(name: 'country_code') final  String? countryCode;
@override@JsonKey(name: 'has_government_api') final  bool hasGovernmentApi;
@override@JsonKey(name: 'government_api_type') final  String? governmentApiType;

/// Create a copy of InspectionTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionTemplateCopyWith<_InspectionTemplate> get copyWith => __$InspectionTemplateCopyWithImpl<_InspectionTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.description, description) || other.description == description)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.hasGovernmentApi, hasGovernmentApi) || other.hasGovernmentApi == hasGovernmentApi)&&(identical(other.governmentApiType, governmentApiType) || other.governmentApiType == governmentApiType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,displayName,description,countryCode,hasGovernmentApi,governmentApiType);

@override
String toString() {
  return 'InspectionTemplate(id: $id, name: $name, displayName: $displayName, description: $description, countryCode: $countryCode, hasGovernmentApi: $hasGovernmentApi, governmentApiType: $governmentApiType)';
}


}

/// @nodoc
abstract mixin class _$InspectionTemplateCopyWith<$Res> implements $InspectionTemplateCopyWith<$Res> {
  factory _$InspectionTemplateCopyWith(_InspectionTemplate value, $Res Function(_InspectionTemplate) _then) = __$InspectionTemplateCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? name,@JsonKey(name: 'display_name') String? displayName, String? description,@JsonKey(name: 'country_code') String? countryCode,@JsonKey(name: 'has_government_api') bool hasGovernmentApi,@JsonKey(name: 'government_api_type') String? governmentApiType
});




}
/// @nodoc
class __$InspectionTemplateCopyWithImpl<$Res>
    implements _$InspectionTemplateCopyWith<$Res> {
  __$InspectionTemplateCopyWithImpl(this._self, this._then);

  final _InspectionTemplate _self;
  final $Res Function(_InspectionTemplate) _then;

/// Create a copy of InspectionTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? displayName = freezed,Object? description = freezed,Object? countryCode = freezed,Object? hasGovernmentApi = null,Object? governmentApiType = freezed,}) {
  return _then(_InspectionTemplate(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,hasGovernmentApi: null == hasGovernmentApi ? _self.hasGovernmentApi : hasGovernmentApi // ignore: cast_nullable_to_non_nullable
as bool,governmentApiType: freezed == governmentApiType ? _self.governmentApiType : governmentApiType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VehicleInfo {

 String? get brand; String? get model; String? get category; String? get year; String? get variant;@JsonKey(readValue: _readColour) String? get colour; String? get transmission;
/// Create a copy of VehicleInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleInfoCopyWith<VehicleInfo> get copyWith => _$VehicleInfoCopyWithImpl<VehicleInfo>(this as VehicleInfo, _$identity);

  /// Serializes this VehicleInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleInfo&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.category, category) || other.category == category)&&(identical(other.year, year) || other.year == year)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.colour, colour) || other.colour == colour)&&(identical(other.transmission, transmission) || other.transmission == transmission));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,brand,model,category,year,variant,colour,transmission);

@override
String toString() {
  return 'VehicleInfo(brand: $brand, model: $model, category: $category, year: $year, variant: $variant, colour: $colour, transmission: $transmission)';
}


}

/// @nodoc
abstract mixin class $VehicleInfoCopyWith<$Res>  {
  factory $VehicleInfoCopyWith(VehicleInfo value, $Res Function(VehicleInfo) _then) = _$VehicleInfoCopyWithImpl;
@useResult
$Res call({
 String? brand, String? model, String? category, String? year, String? variant,@JsonKey(readValue: _readColour) String? colour, String? transmission
});




}
/// @nodoc
class _$VehicleInfoCopyWithImpl<$Res>
    implements $VehicleInfoCopyWith<$Res> {
  _$VehicleInfoCopyWithImpl(this._self, this._then);

  final VehicleInfo _self;
  final $Res Function(VehicleInfo) _then;

/// Create a copy of VehicleInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? brand = freezed,Object? model = freezed,Object? category = freezed,Object? year = freezed,Object? variant = freezed,Object? colour = freezed,Object? transmission = freezed,}) {
  return _then(_self.copyWith(
brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String?,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,colour: freezed == colour ? _self.colour : colour // ignore: cast_nullable_to_non_nullable
as String?,transmission: freezed == transmission ? _self.transmission : transmission // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VehicleInfo].
extension VehicleInfoPatterns on VehicleInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleInfo value)  $default,){
final _that = this;
switch (_that) {
case _VehicleInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleInfo value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? brand,  String? model,  String? category,  String? year,  String? variant, @JsonKey(readValue: _readColour)  String? colour,  String? transmission)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleInfo() when $default != null:
return $default(_that.brand,_that.model,_that.category,_that.year,_that.variant,_that.colour,_that.transmission);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? brand,  String? model,  String? category,  String? year,  String? variant, @JsonKey(readValue: _readColour)  String? colour,  String? transmission)  $default,) {final _that = this;
switch (_that) {
case _VehicleInfo():
return $default(_that.brand,_that.model,_that.category,_that.year,_that.variant,_that.colour,_that.transmission);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? brand,  String? model,  String? category,  String? year,  String? variant, @JsonKey(readValue: _readColour)  String? colour,  String? transmission)?  $default,) {final _that = this;
switch (_that) {
case _VehicleInfo() when $default != null:
return $default(_that.brand,_that.model,_that.category,_that.year,_that.variant,_that.colour,_that.transmission);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VehicleInfo implements VehicleInfo {
  const _VehicleInfo({this.brand, this.model, this.category, this.year, this.variant, @JsonKey(readValue: _readColour) this.colour, this.transmission});
  factory _VehicleInfo.fromJson(Map<String, dynamic> json) => _$VehicleInfoFromJson(json);

@override final  String? brand;
@override final  String? model;
@override final  String? category;
@override final  String? year;
@override final  String? variant;
@override@JsonKey(readValue: _readColour) final  String? colour;
@override final  String? transmission;

/// Create a copy of VehicleInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleInfoCopyWith<_VehicleInfo> get copyWith => __$VehicleInfoCopyWithImpl<_VehicleInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleInfo&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.category, category) || other.category == category)&&(identical(other.year, year) || other.year == year)&&(identical(other.variant, variant) || other.variant == variant)&&(identical(other.colour, colour) || other.colour == colour)&&(identical(other.transmission, transmission) || other.transmission == transmission));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,brand,model,category,year,variant,colour,transmission);

@override
String toString() {
  return 'VehicleInfo(brand: $brand, model: $model, category: $category, year: $year, variant: $variant, colour: $colour, transmission: $transmission)';
}


}

/// @nodoc
abstract mixin class _$VehicleInfoCopyWith<$Res> implements $VehicleInfoCopyWith<$Res> {
  factory _$VehicleInfoCopyWith(_VehicleInfo value, $Res Function(_VehicleInfo) _then) = __$VehicleInfoCopyWithImpl;
@override @useResult
$Res call({
 String? brand, String? model, String? category, String? year, String? variant,@JsonKey(readValue: _readColour) String? colour, String? transmission
});




}
/// @nodoc
class __$VehicleInfoCopyWithImpl<$Res>
    implements _$VehicleInfoCopyWith<$Res> {
  __$VehicleInfoCopyWithImpl(this._self, this._then);

  final _VehicleInfo _self;
  final $Res Function(_VehicleInfo) _then;

/// Create a copy of VehicleInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? brand = freezed,Object? model = freezed,Object? category = freezed,Object? year = freezed,Object? variant = freezed,Object? colour = freezed,Object? transmission = freezed,}) {
  return _then(_VehicleInfo(
brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String?,variant: freezed == variant ? _self.variant : variant // ignore: cast_nullable_to_non_nullable
as String?,colour: freezed == colour ? _self.colour : colour // ignore: cast_nullable_to_non_nullable
as String?,transmission: freezed == transmission ? _self.transmission : transmission // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$InspectionStructure {

 List<InspectionSection> get sections;
/// Create a copy of InspectionStructure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionStructureCopyWith<InspectionStructure> get copyWith => _$InspectionStructureCopyWithImpl<InspectionStructure>(this as InspectionStructure, _$identity);

  /// Serializes this InspectionStructure to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionStructure&&const DeepCollectionEquality().equals(other.sections, sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(sections));

@override
String toString() {
  return 'InspectionStructure(sections: $sections)';
}


}

/// @nodoc
abstract mixin class $InspectionStructureCopyWith<$Res>  {
  factory $InspectionStructureCopyWith(InspectionStructure value, $Res Function(InspectionStructure) _then) = _$InspectionStructureCopyWithImpl;
@useResult
$Res call({
 List<InspectionSection> sections
});




}
/// @nodoc
class _$InspectionStructureCopyWithImpl<$Res>
    implements $InspectionStructureCopyWith<$Res> {
  _$InspectionStructureCopyWithImpl(this._self, this._then);

  final InspectionStructure _self;
  final $Res Function(InspectionStructure) _then;

/// Create a copy of InspectionStructure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sections = null,}) {
  return _then(_self.copyWith(
sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<InspectionSection>,
  ));
}

}


/// Adds pattern-matching-related methods to [InspectionStructure].
extension InspectionStructurePatterns on InspectionStructure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionStructure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionStructure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionStructure value)  $default,){
final _that = this;
switch (_that) {
case _InspectionStructure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionStructure value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionStructure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<InspectionSection> sections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionStructure() when $default != null:
return $default(_that.sections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<InspectionSection> sections)  $default,) {final _that = this;
switch (_that) {
case _InspectionStructure():
return $default(_that.sections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<InspectionSection> sections)?  $default,) {final _that = this;
switch (_that) {
case _InspectionStructure() when $default != null:
return $default(_that.sections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InspectionStructure implements InspectionStructure {
  const _InspectionStructure({final  List<InspectionSection> sections = const <InspectionSection>[]}): _sections = sections;
  factory _InspectionStructure.fromJson(Map<String, dynamic> json) => _$InspectionStructureFromJson(json);

 final  List<InspectionSection> _sections;
@override@JsonKey() List<InspectionSection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}


/// Create a copy of InspectionStructure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionStructureCopyWith<_InspectionStructure> get copyWith => __$InspectionStructureCopyWithImpl<_InspectionStructure>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionStructureToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionStructure&&const DeepCollectionEquality().equals(other._sections, _sections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sections));

@override
String toString() {
  return 'InspectionStructure(sections: $sections)';
}


}

/// @nodoc
abstract mixin class _$InspectionStructureCopyWith<$Res> implements $InspectionStructureCopyWith<$Res> {
  factory _$InspectionStructureCopyWith(_InspectionStructure value, $Res Function(_InspectionStructure) _then) = __$InspectionStructureCopyWithImpl;
@override @useResult
$Res call({
 List<InspectionSection> sections
});




}
/// @nodoc
class __$InspectionStructureCopyWithImpl<$Res>
    implements _$InspectionStructureCopyWith<$Res> {
  __$InspectionStructureCopyWithImpl(this._self, this._then);

  final _InspectionStructure _self;
  final $Res Function(_InspectionStructure) _then;

/// Create a copy of InspectionStructure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sections = null,}) {
  return _then(_InspectionStructure(
sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<InspectionSection>,
  ));
}


}


/// @nodoc
mixin _$InspectionSection {

 int? get id; String? get name; String? get title; String? get description; int get order; List<InspectionField> get fields;
/// Create a copy of InspectionSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionSectionCopyWith<InspectionSection> get copyWith => _$InspectionSectionCopyWithImpl<InspectionSection>(this as InspectionSection, _$identity);

  /// Serializes this InspectionSection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionSection&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.order, order) || other.order == order)&&const DeepCollectionEquality().equals(other.fields, fields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,title,description,order,const DeepCollectionEquality().hash(fields));

@override
String toString() {
  return 'InspectionSection(id: $id, name: $name, title: $title, description: $description, order: $order, fields: $fields)';
}


}

/// @nodoc
abstract mixin class $InspectionSectionCopyWith<$Res>  {
  factory $InspectionSectionCopyWith(InspectionSection value, $Res Function(InspectionSection) _then) = _$InspectionSectionCopyWithImpl;
@useResult
$Res call({
 int? id, String? name, String? title, String? description, int order, List<InspectionField> fields
});




}
/// @nodoc
class _$InspectionSectionCopyWithImpl<$Res>
    implements $InspectionSectionCopyWith<$Res> {
  _$InspectionSectionCopyWithImpl(this._self, this._then);

  final InspectionSection _self;
  final $Res Function(InspectionSection) _then;

/// Create a copy of InspectionSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? title = freezed,Object? description = freezed,Object? order = null,Object? fields = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<InspectionField>,
  ));
}

}


/// Adds pattern-matching-related methods to [InspectionSection].
extension InspectionSectionPatterns on InspectionSection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionSection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionSection value)  $default,){
final _that = this;
switch (_that) {
case _InspectionSection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionSection value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionSection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? name,  String? title,  String? description,  int order,  List<InspectionField> fields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionSection() when $default != null:
return $default(_that.id,_that.name,_that.title,_that.description,_that.order,_that.fields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? name,  String? title,  String? description,  int order,  List<InspectionField> fields)  $default,) {final _that = this;
switch (_that) {
case _InspectionSection():
return $default(_that.id,_that.name,_that.title,_that.description,_that.order,_that.fields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? name,  String? title,  String? description,  int order,  List<InspectionField> fields)?  $default,) {final _that = this;
switch (_that) {
case _InspectionSection() when $default != null:
return $default(_that.id,_that.name,_that.title,_that.description,_that.order,_that.fields);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InspectionSection implements InspectionSection {
  const _InspectionSection({this.id, this.name, this.title, this.description, this.order = 0, final  List<InspectionField> fields = const <InspectionField>[]}): _fields = fields;
  factory _InspectionSection.fromJson(Map<String, dynamic> json) => _$InspectionSectionFromJson(json);

@override final  int? id;
@override final  String? name;
@override final  String? title;
@override final  String? description;
@override@JsonKey() final  int order;
 final  List<InspectionField> _fields;
@override@JsonKey() List<InspectionField> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}


/// Create a copy of InspectionSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionSectionCopyWith<_InspectionSection> get copyWith => __$InspectionSectionCopyWithImpl<_InspectionSection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionSectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionSection&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.order, order) || other.order == order)&&const DeepCollectionEquality().equals(other._fields, _fields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,title,description,order,const DeepCollectionEquality().hash(_fields));

@override
String toString() {
  return 'InspectionSection(id: $id, name: $name, title: $title, description: $description, order: $order, fields: $fields)';
}


}

/// @nodoc
abstract mixin class _$InspectionSectionCopyWith<$Res> implements $InspectionSectionCopyWith<$Res> {
  factory _$InspectionSectionCopyWith(_InspectionSection value, $Res Function(_InspectionSection) _then) = __$InspectionSectionCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? name, String? title, String? description, int order, List<InspectionField> fields
});




}
/// @nodoc
class __$InspectionSectionCopyWithImpl<$Res>
    implements _$InspectionSectionCopyWith<$Res> {
  __$InspectionSectionCopyWithImpl(this._self, this._then);

  final _InspectionSection _self;
  final $Res Function(_InspectionSection) _then;

/// Create a copy of InspectionSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? title = freezed,Object? description = freezed,Object? order = null,Object? fields = null,}) {
  return _then(_InspectionSection(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<InspectionField>,
  ));
}


}


/// @nodoc
mixin _$InspectionField {

 int? get id;@JsonKey(name: 'field_id') String? get fieldId; String? get title;@JsonKey(name: 'field_type') String get fieldType;@JsonKey(name: 'is_required') bool get isRequired;@JsonKey(name: 'has_remarks') bool get hasRemarks;@JsonKey(name: 'has_image') bool get hasImage;@JsonKey(name: 'has_video') bool get hasVideo;@JsonKey(name: 'has_file') bool get hasFile;@JsonKey(name: 'has_multiple_images') bool get hasMultipleImages; int get order; Map<String, dynamic>? get metadata; List<DropdownOption> get options;@JsonKey(name: 'reference_media') List<ReferenceMedia> get referenceMedia;// Resume pre-fill (server's saved answer for this field). Empty on a fresh
// initialize; populated by GET /{id}/resume so the merge can re-hydrate.
@JsonKey(name: 'initial_value', fromJson: _asStr) String? get initialValue;@JsonKey(name: 'initial_remarks', fromJson: _asStr) String? get initialRemarks;@JsonKey(name: 'initial_image', fromJson: _mediaStr) String? get initialImage;@JsonKey(name: 'initial_video', fromJson: _mediaStr) String? get initialVideo;@JsonKey(name: 'initial_audio', fromJson: _mediaStr) String? get initialAudio;@JsonKey(name: 'initial_file', fromJson: _mediaStr) String? get initialFile;@JsonKey(name: 'initial_multi_images', fromJson: _mediaStrList) List<String> get initialMultiImages;
/// Create a copy of InspectionField
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionFieldCopyWith<InspectionField> get copyWith => _$InspectionFieldCopyWithImpl<InspectionField>(this as InspectionField, _$identity);

  /// Serializes this InspectionField to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionField&&(identical(other.id, id) || other.id == id)&&(identical(other.fieldId, fieldId) || other.fieldId == fieldId)&&(identical(other.title, title) || other.title == title)&&(identical(other.fieldType, fieldType) || other.fieldType == fieldType)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.hasRemarks, hasRemarks) || other.hasRemarks == hasRemarks)&&(identical(other.hasImage, hasImage) || other.hasImage == hasImage)&&(identical(other.hasVideo, hasVideo) || other.hasVideo == hasVideo)&&(identical(other.hasFile, hasFile) || other.hasFile == hasFile)&&(identical(other.hasMultipleImages, hasMultipleImages) || other.hasMultipleImages == hasMultipleImages)&&(identical(other.order, order) || other.order == order)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&const DeepCollectionEquality().equals(other.options, options)&&const DeepCollectionEquality().equals(other.referenceMedia, referenceMedia)&&(identical(other.initialValue, initialValue) || other.initialValue == initialValue)&&(identical(other.initialRemarks, initialRemarks) || other.initialRemarks == initialRemarks)&&(identical(other.initialImage, initialImage) || other.initialImage == initialImage)&&(identical(other.initialVideo, initialVideo) || other.initialVideo == initialVideo)&&(identical(other.initialAudio, initialAudio) || other.initialAudio == initialAudio)&&(identical(other.initialFile, initialFile) || other.initialFile == initialFile)&&const DeepCollectionEquality().equals(other.initialMultiImages, initialMultiImages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,fieldId,title,fieldType,isRequired,hasRemarks,hasImage,hasVideo,hasFile,hasMultipleImages,order,const DeepCollectionEquality().hash(metadata),const DeepCollectionEquality().hash(options),const DeepCollectionEquality().hash(referenceMedia),initialValue,initialRemarks,initialImage,initialVideo,initialAudio,initialFile,const DeepCollectionEquality().hash(initialMultiImages)]);

@override
String toString() {
  return 'InspectionField(id: $id, fieldId: $fieldId, title: $title, fieldType: $fieldType, isRequired: $isRequired, hasRemarks: $hasRemarks, hasImage: $hasImage, hasVideo: $hasVideo, hasFile: $hasFile, hasMultipleImages: $hasMultipleImages, order: $order, metadata: $metadata, options: $options, referenceMedia: $referenceMedia, initialValue: $initialValue, initialRemarks: $initialRemarks, initialImage: $initialImage, initialVideo: $initialVideo, initialAudio: $initialAudio, initialFile: $initialFile, initialMultiImages: $initialMultiImages)';
}


}

/// @nodoc
abstract mixin class $InspectionFieldCopyWith<$Res>  {
  factory $InspectionFieldCopyWith(InspectionField value, $Res Function(InspectionField) _then) = _$InspectionFieldCopyWithImpl;
@useResult
$Res call({
 int? id,@JsonKey(name: 'field_id') String? fieldId, String? title,@JsonKey(name: 'field_type') String fieldType,@JsonKey(name: 'is_required') bool isRequired,@JsonKey(name: 'has_remarks') bool hasRemarks,@JsonKey(name: 'has_image') bool hasImage,@JsonKey(name: 'has_video') bool hasVideo,@JsonKey(name: 'has_file') bool hasFile,@JsonKey(name: 'has_multiple_images') bool hasMultipleImages, int order, Map<String, dynamic>? metadata, List<DropdownOption> options,@JsonKey(name: 'reference_media') List<ReferenceMedia> referenceMedia,@JsonKey(name: 'initial_value', fromJson: _asStr) String? initialValue,@JsonKey(name: 'initial_remarks', fromJson: _asStr) String? initialRemarks,@JsonKey(name: 'initial_image', fromJson: _mediaStr) String? initialImage,@JsonKey(name: 'initial_video', fromJson: _mediaStr) String? initialVideo,@JsonKey(name: 'initial_audio', fromJson: _mediaStr) String? initialAudio,@JsonKey(name: 'initial_file', fromJson: _mediaStr) String? initialFile,@JsonKey(name: 'initial_multi_images', fromJson: _mediaStrList) List<String> initialMultiImages
});




}
/// @nodoc
class _$InspectionFieldCopyWithImpl<$Res>
    implements $InspectionFieldCopyWith<$Res> {
  _$InspectionFieldCopyWithImpl(this._self, this._then);

  final InspectionField _self;
  final $Res Function(InspectionField) _then;

/// Create a copy of InspectionField
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? fieldId = freezed,Object? title = freezed,Object? fieldType = null,Object? isRequired = null,Object? hasRemarks = null,Object? hasImage = null,Object? hasVideo = null,Object? hasFile = null,Object? hasMultipleImages = null,Object? order = null,Object? metadata = freezed,Object? options = null,Object? referenceMedia = null,Object? initialValue = freezed,Object? initialRemarks = freezed,Object? initialImage = freezed,Object? initialVideo = freezed,Object? initialAudio = freezed,Object? initialFile = freezed,Object? initialMultiImages = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,fieldId: freezed == fieldId ? _self.fieldId : fieldId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,fieldType: null == fieldType ? _self.fieldType : fieldType // ignore: cast_nullable_to_non_nullable
as String,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,hasRemarks: null == hasRemarks ? _self.hasRemarks : hasRemarks // ignore: cast_nullable_to_non_nullable
as bool,hasImage: null == hasImage ? _self.hasImage : hasImage // ignore: cast_nullable_to_non_nullable
as bool,hasVideo: null == hasVideo ? _self.hasVideo : hasVideo // ignore: cast_nullable_to_non_nullable
as bool,hasFile: null == hasFile ? _self.hasFile : hasFile // ignore: cast_nullable_to_non_nullable
as bool,hasMultipleImages: null == hasMultipleImages ? _self.hasMultipleImages : hasMultipleImages // ignore: cast_nullable_to_non_nullable
as bool,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<DropdownOption>,referenceMedia: null == referenceMedia ? _self.referenceMedia : referenceMedia // ignore: cast_nullable_to_non_nullable
as List<ReferenceMedia>,initialValue: freezed == initialValue ? _self.initialValue : initialValue // ignore: cast_nullable_to_non_nullable
as String?,initialRemarks: freezed == initialRemarks ? _self.initialRemarks : initialRemarks // ignore: cast_nullable_to_non_nullable
as String?,initialImage: freezed == initialImage ? _self.initialImage : initialImage // ignore: cast_nullable_to_non_nullable
as String?,initialVideo: freezed == initialVideo ? _self.initialVideo : initialVideo // ignore: cast_nullable_to_non_nullable
as String?,initialAudio: freezed == initialAudio ? _self.initialAudio : initialAudio // ignore: cast_nullable_to_non_nullable
as String?,initialFile: freezed == initialFile ? _self.initialFile : initialFile // ignore: cast_nullable_to_non_nullable
as String?,initialMultiImages: null == initialMultiImages ? _self.initialMultiImages : initialMultiImages // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [InspectionField].
extension InspectionFieldPatterns on InspectionField {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionField value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionField() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionField value)  $default,){
final _that = this;
switch (_that) {
case _InspectionField():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionField value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionField() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'field_id')  String? fieldId,  String? title, @JsonKey(name: 'field_type')  String fieldType, @JsonKey(name: 'is_required')  bool isRequired, @JsonKey(name: 'has_remarks')  bool hasRemarks, @JsonKey(name: 'has_image')  bool hasImage, @JsonKey(name: 'has_video')  bool hasVideo, @JsonKey(name: 'has_file')  bool hasFile, @JsonKey(name: 'has_multiple_images')  bool hasMultipleImages,  int order,  Map<String, dynamic>? metadata,  List<DropdownOption> options, @JsonKey(name: 'reference_media')  List<ReferenceMedia> referenceMedia, @JsonKey(name: 'initial_value', fromJson: _asStr)  String? initialValue, @JsonKey(name: 'initial_remarks', fromJson: _asStr)  String? initialRemarks, @JsonKey(name: 'initial_image', fromJson: _mediaStr)  String? initialImage, @JsonKey(name: 'initial_video', fromJson: _mediaStr)  String? initialVideo, @JsonKey(name: 'initial_audio', fromJson: _mediaStr)  String? initialAudio, @JsonKey(name: 'initial_file', fromJson: _mediaStr)  String? initialFile, @JsonKey(name: 'initial_multi_images', fromJson: _mediaStrList)  List<String> initialMultiImages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionField() when $default != null:
return $default(_that.id,_that.fieldId,_that.title,_that.fieldType,_that.isRequired,_that.hasRemarks,_that.hasImage,_that.hasVideo,_that.hasFile,_that.hasMultipleImages,_that.order,_that.metadata,_that.options,_that.referenceMedia,_that.initialValue,_that.initialRemarks,_that.initialImage,_that.initialVideo,_that.initialAudio,_that.initialFile,_that.initialMultiImages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id, @JsonKey(name: 'field_id')  String? fieldId,  String? title, @JsonKey(name: 'field_type')  String fieldType, @JsonKey(name: 'is_required')  bool isRequired, @JsonKey(name: 'has_remarks')  bool hasRemarks, @JsonKey(name: 'has_image')  bool hasImage, @JsonKey(name: 'has_video')  bool hasVideo, @JsonKey(name: 'has_file')  bool hasFile, @JsonKey(name: 'has_multiple_images')  bool hasMultipleImages,  int order,  Map<String, dynamic>? metadata,  List<DropdownOption> options, @JsonKey(name: 'reference_media')  List<ReferenceMedia> referenceMedia, @JsonKey(name: 'initial_value', fromJson: _asStr)  String? initialValue, @JsonKey(name: 'initial_remarks', fromJson: _asStr)  String? initialRemarks, @JsonKey(name: 'initial_image', fromJson: _mediaStr)  String? initialImage, @JsonKey(name: 'initial_video', fromJson: _mediaStr)  String? initialVideo, @JsonKey(name: 'initial_audio', fromJson: _mediaStr)  String? initialAudio, @JsonKey(name: 'initial_file', fromJson: _mediaStr)  String? initialFile, @JsonKey(name: 'initial_multi_images', fromJson: _mediaStrList)  List<String> initialMultiImages)  $default,) {final _that = this;
switch (_that) {
case _InspectionField():
return $default(_that.id,_that.fieldId,_that.title,_that.fieldType,_that.isRequired,_that.hasRemarks,_that.hasImage,_that.hasVideo,_that.hasFile,_that.hasMultipleImages,_that.order,_that.metadata,_that.options,_that.referenceMedia,_that.initialValue,_that.initialRemarks,_that.initialImage,_that.initialVideo,_that.initialAudio,_that.initialFile,_that.initialMultiImages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id, @JsonKey(name: 'field_id')  String? fieldId,  String? title, @JsonKey(name: 'field_type')  String fieldType, @JsonKey(name: 'is_required')  bool isRequired, @JsonKey(name: 'has_remarks')  bool hasRemarks, @JsonKey(name: 'has_image')  bool hasImage, @JsonKey(name: 'has_video')  bool hasVideo, @JsonKey(name: 'has_file')  bool hasFile, @JsonKey(name: 'has_multiple_images')  bool hasMultipleImages,  int order,  Map<String, dynamic>? metadata,  List<DropdownOption> options, @JsonKey(name: 'reference_media')  List<ReferenceMedia> referenceMedia, @JsonKey(name: 'initial_value', fromJson: _asStr)  String? initialValue, @JsonKey(name: 'initial_remarks', fromJson: _asStr)  String? initialRemarks, @JsonKey(name: 'initial_image', fromJson: _mediaStr)  String? initialImage, @JsonKey(name: 'initial_video', fromJson: _mediaStr)  String? initialVideo, @JsonKey(name: 'initial_audio', fromJson: _mediaStr)  String? initialAudio, @JsonKey(name: 'initial_file', fromJson: _mediaStr)  String? initialFile, @JsonKey(name: 'initial_multi_images', fromJson: _mediaStrList)  List<String> initialMultiImages)?  $default,) {final _that = this;
switch (_that) {
case _InspectionField() when $default != null:
return $default(_that.id,_that.fieldId,_that.title,_that.fieldType,_that.isRequired,_that.hasRemarks,_that.hasImage,_that.hasVideo,_that.hasFile,_that.hasMultipleImages,_that.order,_that.metadata,_that.options,_that.referenceMedia,_that.initialValue,_that.initialRemarks,_that.initialImage,_that.initialVideo,_that.initialAudio,_that.initialFile,_that.initialMultiImages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InspectionField implements InspectionField {
  const _InspectionField({this.id, @JsonKey(name: 'field_id') this.fieldId, this.title, @JsonKey(name: 'field_type') this.fieldType = 'text', @JsonKey(name: 'is_required') this.isRequired = false, @JsonKey(name: 'has_remarks') this.hasRemarks = false, @JsonKey(name: 'has_image') this.hasImage = false, @JsonKey(name: 'has_video') this.hasVideo = false, @JsonKey(name: 'has_file') this.hasFile = false, @JsonKey(name: 'has_multiple_images') this.hasMultipleImages = false, this.order = 0, final  Map<String, dynamic>? metadata, final  List<DropdownOption> options = const <DropdownOption>[], @JsonKey(name: 'reference_media') final  List<ReferenceMedia> referenceMedia = const <ReferenceMedia>[], @JsonKey(name: 'initial_value', fromJson: _asStr) this.initialValue, @JsonKey(name: 'initial_remarks', fromJson: _asStr) this.initialRemarks, @JsonKey(name: 'initial_image', fromJson: _mediaStr) this.initialImage, @JsonKey(name: 'initial_video', fromJson: _mediaStr) this.initialVideo, @JsonKey(name: 'initial_audio', fromJson: _mediaStr) this.initialAudio, @JsonKey(name: 'initial_file', fromJson: _mediaStr) this.initialFile, @JsonKey(name: 'initial_multi_images', fromJson: _mediaStrList) final  List<String> initialMultiImages = const <String>[]}): _metadata = metadata,_options = options,_referenceMedia = referenceMedia,_initialMultiImages = initialMultiImages;
  factory _InspectionField.fromJson(Map<String, dynamic> json) => _$InspectionFieldFromJson(json);

@override final  int? id;
@override@JsonKey(name: 'field_id') final  String? fieldId;
@override final  String? title;
@override@JsonKey(name: 'field_type') final  String fieldType;
@override@JsonKey(name: 'is_required') final  bool isRequired;
@override@JsonKey(name: 'has_remarks') final  bool hasRemarks;
@override@JsonKey(name: 'has_image') final  bool hasImage;
@override@JsonKey(name: 'has_video') final  bool hasVideo;
@override@JsonKey(name: 'has_file') final  bool hasFile;
@override@JsonKey(name: 'has_multiple_images') final  bool hasMultipleImages;
@override@JsonKey() final  int order;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<DropdownOption> _options;
@override@JsonKey() List<DropdownOption> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

 final  List<ReferenceMedia> _referenceMedia;
@override@JsonKey(name: 'reference_media') List<ReferenceMedia> get referenceMedia {
  if (_referenceMedia is EqualUnmodifiableListView) return _referenceMedia;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_referenceMedia);
}

// Resume pre-fill (server's saved answer for this field). Empty on a fresh
// initialize; populated by GET /{id}/resume so the merge can re-hydrate.
@override@JsonKey(name: 'initial_value', fromJson: _asStr) final  String? initialValue;
@override@JsonKey(name: 'initial_remarks', fromJson: _asStr) final  String? initialRemarks;
@override@JsonKey(name: 'initial_image', fromJson: _mediaStr) final  String? initialImage;
@override@JsonKey(name: 'initial_video', fromJson: _mediaStr) final  String? initialVideo;
@override@JsonKey(name: 'initial_audio', fromJson: _mediaStr) final  String? initialAudio;
@override@JsonKey(name: 'initial_file', fromJson: _mediaStr) final  String? initialFile;
 final  List<String> _initialMultiImages;
@override@JsonKey(name: 'initial_multi_images', fromJson: _mediaStrList) List<String> get initialMultiImages {
  if (_initialMultiImages is EqualUnmodifiableListView) return _initialMultiImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_initialMultiImages);
}


/// Create a copy of InspectionField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionFieldCopyWith<_InspectionField> get copyWith => __$InspectionFieldCopyWithImpl<_InspectionField>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionFieldToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionField&&(identical(other.id, id) || other.id == id)&&(identical(other.fieldId, fieldId) || other.fieldId == fieldId)&&(identical(other.title, title) || other.title == title)&&(identical(other.fieldType, fieldType) || other.fieldType == fieldType)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.hasRemarks, hasRemarks) || other.hasRemarks == hasRemarks)&&(identical(other.hasImage, hasImage) || other.hasImage == hasImage)&&(identical(other.hasVideo, hasVideo) || other.hasVideo == hasVideo)&&(identical(other.hasFile, hasFile) || other.hasFile == hasFile)&&(identical(other.hasMultipleImages, hasMultipleImages) || other.hasMultipleImages == hasMultipleImages)&&(identical(other.order, order) || other.order == order)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&const DeepCollectionEquality().equals(other._options, _options)&&const DeepCollectionEquality().equals(other._referenceMedia, _referenceMedia)&&(identical(other.initialValue, initialValue) || other.initialValue == initialValue)&&(identical(other.initialRemarks, initialRemarks) || other.initialRemarks == initialRemarks)&&(identical(other.initialImage, initialImage) || other.initialImage == initialImage)&&(identical(other.initialVideo, initialVideo) || other.initialVideo == initialVideo)&&(identical(other.initialAudio, initialAudio) || other.initialAudio == initialAudio)&&(identical(other.initialFile, initialFile) || other.initialFile == initialFile)&&const DeepCollectionEquality().equals(other._initialMultiImages, _initialMultiImages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,fieldId,title,fieldType,isRequired,hasRemarks,hasImage,hasVideo,hasFile,hasMultipleImages,order,const DeepCollectionEquality().hash(_metadata),const DeepCollectionEquality().hash(_options),const DeepCollectionEquality().hash(_referenceMedia),initialValue,initialRemarks,initialImage,initialVideo,initialAudio,initialFile,const DeepCollectionEquality().hash(_initialMultiImages)]);

@override
String toString() {
  return 'InspectionField(id: $id, fieldId: $fieldId, title: $title, fieldType: $fieldType, isRequired: $isRequired, hasRemarks: $hasRemarks, hasImage: $hasImage, hasVideo: $hasVideo, hasFile: $hasFile, hasMultipleImages: $hasMultipleImages, order: $order, metadata: $metadata, options: $options, referenceMedia: $referenceMedia, initialValue: $initialValue, initialRemarks: $initialRemarks, initialImage: $initialImage, initialVideo: $initialVideo, initialAudio: $initialAudio, initialFile: $initialFile, initialMultiImages: $initialMultiImages)';
}


}

/// @nodoc
abstract mixin class _$InspectionFieldCopyWith<$Res> implements $InspectionFieldCopyWith<$Res> {
  factory _$InspectionFieldCopyWith(_InspectionField value, $Res Function(_InspectionField) _then) = __$InspectionFieldCopyWithImpl;
@override @useResult
$Res call({
 int? id,@JsonKey(name: 'field_id') String? fieldId, String? title,@JsonKey(name: 'field_type') String fieldType,@JsonKey(name: 'is_required') bool isRequired,@JsonKey(name: 'has_remarks') bool hasRemarks,@JsonKey(name: 'has_image') bool hasImage,@JsonKey(name: 'has_video') bool hasVideo,@JsonKey(name: 'has_file') bool hasFile,@JsonKey(name: 'has_multiple_images') bool hasMultipleImages, int order, Map<String, dynamic>? metadata, List<DropdownOption> options,@JsonKey(name: 'reference_media') List<ReferenceMedia> referenceMedia,@JsonKey(name: 'initial_value', fromJson: _asStr) String? initialValue,@JsonKey(name: 'initial_remarks', fromJson: _asStr) String? initialRemarks,@JsonKey(name: 'initial_image', fromJson: _mediaStr) String? initialImage,@JsonKey(name: 'initial_video', fromJson: _mediaStr) String? initialVideo,@JsonKey(name: 'initial_audio', fromJson: _mediaStr) String? initialAudio,@JsonKey(name: 'initial_file', fromJson: _mediaStr) String? initialFile,@JsonKey(name: 'initial_multi_images', fromJson: _mediaStrList) List<String> initialMultiImages
});




}
/// @nodoc
class __$InspectionFieldCopyWithImpl<$Res>
    implements _$InspectionFieldCopyWith<$Res> {
  __$InspectionFieldCopyWithImpl(this._self, this._then);

  final _InspectionField _self;
  final $Res Function(_InspectionField) _then;

/// Create a copy of InspectionField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? fieldId = freezed,Object? title = freezed,Object? fieldType = null,Object? isRequired = null,Object? hasRemarks = null,Object? hasImage = null,Object? hasVideo = null,Object? hasFile = null,Object? hasMultipleImages = null,Object? order = null,Object? metadata = freezed,Object? options = null,Object? referenceMedia = null,Object? initialValue = freezed,Object? initialRemarks = freezed,Object? initialImage = freezed,Object? initialVideo = freezed,Object? initialAudio = freezed,Object? initialFile = freezed,Object? initialMultiImages = null,}) {
  return _then(_InspectionField(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,fieldId: freezed == fieldId ? _self.fieldId : fieldId // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,fieldType: null == fieldType ? _self.fieldType : fieldType // ignore: cast_nullable_to_non_nullable
as String,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,hasRemarks: null == hasRemarks ? _self.hasRemarks : hasRemarks // ignore: cast_nullable_to_non_nullable
as bool,hasImage: null == hasImage ? _self.hasImage : hasImage // ignore: cast_nullable_to_non_nullable
as bool,hasVideo: null == hasVideo ? _self.hasVideo : hasVideo // ignore: cast_nullable_to_non_nullable
as bool,hasFile: null == hasFile ? _self.hasFile : hasFile // ignore: cast_nullable_to_non_nullable
as bool,hasMultipleImages: null == hasMultipleImages ? _self.hasMultipleImages : hasMultipleImages // ignore: cast_nullable_to_non_nullable
as bool,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<DropdownOption>,referenceMedia: null == referenceMedia ? _self._referenceMedia : referenceMedia // ignore: cast_nullable_to_non_nullable
as List<ReferenceMedia>,initialValue: freezed == initialValue ? _self.initialValue : initialValue // ignore: cast_nullable_to_non_nullable
as String?,initialRemarks: freezed == initialRemarks ? _self.initialRemarks : initialRemarks // ignore: cast_nullable_to_non_nullable
as String?,initialImage: freezed == initialImage ? _self.initialImage : initialImage // ignore: cast_nullable_to_non_nullable
as String?,initialVideo: freezed == initialVideo ? _self.initialVideo : initialVideo // ignore: cast_nullable_to_non_nullable
as String?,initialAudio: freezed == initialAudio ? _self.initialAudio : initialAudio // ignore: cast_nullable_to_non_nullable
as String?,initialFile: freezed == initialFile ? _self.initialFile : initialFile // ignore: cast_nullable_to_non_nullable
as String?,initialMultiImages: null == initialMultiImages ? _self._initialMultiImages : initialMultiImages // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$DropdownOption {

 int? get id; String? get value; String? get label;@JsonKey(name: 'color_name') String? get colorName;@JsonKey(name: 'color_code') String get colorCode; int get order;
/// Create a copy of DropdownOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DropdownOptionCopyWith<DropdownOption> get copyWith => _$DropdownOptionCopyWithImpl<DropdownOption>(this as DropdownOption, _$identity);

  /// Serializes this DropdownOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DropdownOption&&(identical(other.id, id) || other.id == id)&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label)&&(identical(other.colorName, colorName) || other.colorName == colorName)&&(identical(other.colorCode, colorCode) || other.colorCode == colorCode)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,value,label,colorName,colorCode,order);

@override
String toString() {
  return 'DropdownOption(id: $id, value: $value, label: $label, colorName: $colorName, colorCode: $colorCode, order: $order)';
}


}

/// @nodoc
abstract mixin class $DropdownOptionCopyWith<$Res>  {
  factory $DropdownOptionCopyWith(DropdownOption value, $Res Function(DropdownOption) _then) = _$DropdownOptionCopyWithImpl;
@useResult
$Res call({
 int? id, String? value, String? label,@JsonKey(name: 'color_name') String? colorName,@JsonKey(name: 'color_code') String colorCode, int order
});




}
/// @nodoc
class _$DropdownOptionCopyWithImpl<$Res>
    implements $DropdownOptionCopyWith<$Res> {
  _$DropdownOptionCopyWithImpl(this._self, this._then);

  final DropdownOption _self;
  final $Res Function(DropdownOption) _then;

/// Create a copy of DropdownOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? value = freezed,Object? label = freezed,Object? colorName = freezed,Object? colorCode = null,Object? order = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,colorName: freezed == colorName ? _self.colorName : colorName // ignore: cast_nullable_to_non_nullable
as String?,colorCode: null == colorCode ? _self.colorCode : colorCode // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DropdownOption].
extension DropdownOptionPatterns on DropdownOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DropdownOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DropdownOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DropdownOption value)  $default,){
final _that = this;
switch (_that) {
case _DropdownOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DropdownOption value)?  $default,){
final _that = this;
switch (_that) {
case _DropdownOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? value,  String? label, @JsonKey(name: 'color_name')  String? colorName, @JsonKey(name: 'color_code')  String colorCode,  int order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DropdownOption() when $default != null:
return $default(_that.id,_that.value,_that.label,_that.colorName,_that.colorCode,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? value,  String? label, @JsonKey(name: 'color_name')  String? colorName, @JsonKey(name: 'color_code')  String colorCode,  int order)  $default,) {final _that = this;
switch (_that) {
case _DropdownOption():
return $default(_that.id,_that.value,_that.label,_that.colorName,_that.colorCode,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? value,  String? label, @JsonKey(name: 'color_name')  String? colorName, @JsonKey(name: 'color_code')  String colorCode,  int order)?  $default,) {final _that = this;
switch (_that) {
case _DropdownOption() when $default != null:
return $default(_that.id,_that.value,_that.label,_that.colorName,_that.colorCode,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DropdownOption implements DropdownOption {
  const _DropdownOption({this.id, this.value, this.label, @JsonKey(name: 'color_name') this.colorName, @JsonKey(name: 'color_code') this.colorCode = '#000000', this.order = 0});
  factory _DropdownOption.fromJson(Map<String, dynamic> json) => _$DropdownOptionFromJson(json);

@override final  int? id;
@override final  String? value;
@override final  String? label;
@override@JsonKey(name: 'color_name') final  String? colorName;
@override@JsonKey(name: 'color_code') final  String colorCode;
@override@JsonKey() final  int order;

/// Create a copy of DropdownOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DropdownOptionCopyWith<_DropdownOption> get copyWith => __$DropdownOptionCopyWithImpl<_DropdownOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DropdownOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DropdownOption&&(identical(other.id, id) || other.id == id)&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label)&&(identical(other.colorName, colorName) || other.colorName == colorName)&&(identical(other.colorCode, colorCode) || other.colorCode == colorCode)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,value,label,colorName,colorCode,order);

@override
String toString() {
  return 'DropdownOption(id: $id, value: $value, label: $label, colorName: $colorName, colorCode: $colorCode, order: $order)';
}


}

/// @nodoc
abstract mixin class _$DropdownOptionCopyWith<$Res> implements $DropdownOptionCopyWith<$Res> {
  factory _$DropdownOptionCopyWith(_DropdownOption value, $Res Function(_DropdownOption) _then) = __$DropdownOptionCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? value, String? label,@JsonKey(name: 'color_name') String? colorName,@JsonKey(name: 'color_code') String colorCode, int order
});




}
/// @nodoc
class __$DropdownOptionCopyWithImpl<$Res>
    implements _$DropdownOptionCopyWith<$Res> {
  __$DropdownOptionCopyWithImpl(this._self, this._then);

  final _DropdownOption _self;
  final $Res Function(_DropdownOption) _then;

/// Create a copy of DropdownOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? value = freezed,Object? label = freezed,Object? colorName = freezed,Object? colorCode = null,Object? order = null,}) {
  return _then(_DropdownOption(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,colorName: freezed == colorName ? _self.colorName : colorName // ignore: cast_nullable_to_non_nullable
as String?,colorCode: null == colorCode ? _self.colorCode : colorCode // ignore: cast_nullable_to_non_nullable
as String,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ReferenceMedia {

 int? get id;@JsonKey(readValue: _readMediaType) String? get mediaType;@JsonKey(name: 'file_path') String? get filePath; String? get url; String? get description; int get order;
/// Create a copy of ReferenceMedia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReferenceMediaCopyWith<ReferenceMedia> get copyWith => _$ReferenceMediaCopyWithImpl<ReferenceMedia>(this as ReferenceMedia, _$identity);

  /// Serializes this ReferenceMedia to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReferenceMedia&&(identical(other.id, id) || other.id == id)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.url, url) || other.url == url)&&(identical(other.description, description) || other.description == description)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,mediaType,filePath,url,description,order);

@override
String toString() {
  return 'ReferenceMedia(id: $id, mediaType: $mediaType, filePath: $filePath, url: $url, description: $description, order: $order)';
}


}

/// @nodoc
abstract mixin class $ReferenceMediaCopyWith<$Res>  {
  factory $ReferenceMediaCopyWith(ReferenceMedia value, $Res Function(ReferenceMedia) _then) = _$ReferenceMediaCopyWithImpl;
@useResult
$Res call({
 int? id,@JsonKey(readValue: _readMediaType) String? mediaType,@JsonKey(name: 'file_path') String? filePath, String? url, String? description, int order
});




}
/// @nodoc
class _$ReferenceMediaCopyWithImpl<$Res>
    implements $ReferenceMediaCopyWith<$Res> {
  _$ReferenceMediaCopyWithImpl(this._self, this._then);

  final ReferenceMedia _self;
  final $Res Function(ReferenceMedia) _then;

/// Create a copy of ReferenceMedia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? mediaType = freezed,Object? filePath = freezed,Object? url = freezed,Object? description = freezed,Object? order = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String?,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReferenceMedia].
extension ReferenceMediaPatterns on ReferenceMedia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReferenceMedia value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReferenceMedia() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReferenceMedia value)  $default,){
final _that = this;
switch (_that) {
case _ReferenceMedia():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReferenceMedia value)?  $default,){
final _that = this;
switch (_that) {
case _ReferenceMedia() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id, @JsonKey(readValue: _readMediaType)  String? mediaType, @JsonKey(name: 'file_path')  String? filePath,  String? url,  String? description,  int order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReferenceMedia() when $default != null:
return $default(_that.id,_that.mediaType,_that.filePath,_that.url,_that.description,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id, @JsonKey(readValue: _readMediaType)  String? mediaType, @JsonKey(name: 'file_path')  String? filePath,  String? url,  String? description,  int order)  $default,) {final _that = this;
switch (_that) {
case _ReferenceMedia():
return $default(_that.id,_that.mediaType,_that.filePath,_that.url,_that.description,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id, @JsonKey(readValue: _readMediaType)  String? mediaType, @JsonKey(name: 'file_path')  String? filePath,  String? url,  String? description,  int order)?  $default,) {final _that = this;
switch (_that) {
case _ReferenceMedia() when $default != null:
return $default(_that.id,_that.mediaType,_that.filePath,_that.url,_that.description,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReferenceMedia implements ReferenceMedia {
  const _ReferenceMedia({this.id, @JsonKey(readValue: _readMediaType) this.mediaType, @JsonKey(name: 'file_path') this.filePath, this.url, this.description, this.order = 0});
  factory _ReferenceMedia.fromJson(Map<String, dynamic> json) => _$ReferenceMediaFromJson(json);

@override final  int? id;
@override@JsonKey(readValue: _readMediaType) final  String? mediaType;
@override@JsonKey(name: 'file_path') final  String? filePath;
@override final  String? url;
@override final  String? description;
@override@JsonKey() final  int order;

/// Create a copy of ReferenceMedia
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReferenceMediaCopyWith<_ReferenceMedia> get copyWith => __$ReferenceMediaCopyWithImpl<_ReferenceMedia>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReferenceMediaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReferenceMedia&&(identical(other.id, id) || other.id == id)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.url, url) || other.url == url)&&(identical(other.description, description) || other.description == description)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,mediaType,filePath,url,description,order);

@override
String toString() {
  return 'ReferenceMedia(id: $id, mediaType: $mediaType, filePath: $filePath, url: $url, description: $description, order: $order)';
}


}

/// @nodoc
abstract mixin class _$ReferenceMediaCopyWith<$Res> implements $ReferenceMediaCopyWith<$Res> {
  factory _$ReferenceMediaCopyWith(_ReferenceMedia value, $Res Function(_ReferenceMedia) _then) = __$ReferenceMediaCopyWithImpl;
@override @useResult
$Res call({
 int? id,@JsonKey(readValue: _readMediaType) String? mediaType,@JsonKey(name: 'file_path') String? filePath, String? url, String? description, int order
});




}
/// @nodoc
class __$ReferenceMediaCopyWithImpl<$Res>
    implements _$ReferenceMediaCopyWith<$Res> {
  __$ReferenceMediaCopyWithImpl(this._self, this._then);

  final _ReferenceMedia _self;
  final $Res Function(_ReferenceMedia) _then;

/// Create a copy of ReferenceMedia
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? mediaType = freezed,Object? filePath = freezed,Object? url = freezed,Object? description = freezed,Object? order = null,}) {
  return _then(_ReferenceMedia(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String?,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
