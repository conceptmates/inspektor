// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InspectionHistory {

 String get id; String get inspectorName; String get status; DateTime get date; Map<String, dynamic> get vehicleInfo; Map<String, String>? get links;
/// Create a copy of InspectionHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionHistoryCopyWith<InspectionHistory> get copyWith => _$InspectionHistoryCopyWithImpl<InspectionHistory>(this as InspectionHistory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectorName, inspectorName) || other.inspectorName == inspectorName)&&(identical(other.status, status) || other.status == status)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.vehicleInfo, vehicleInfo)&&const DeepCollectionEquality().equals(other.links, links));
}


@override
int get hashCode => Object.hash(runtimeType,id,inspectorName,status,date,const DeepCollectionEquality().hash(vehicleInfo),const DeepCollectionEquality().hash(links));

@override
String toString() {
  return 'InspectionHistory(id: $id, inspectorName: $inspectorName, status: $status, date: $date, vehicleInfo: $vehicleInfo, links: $links)';
}


}

/// @nodoc
abstract mixin class $InspectionHistoryCopyWith<$Res>  {
  factory $InspectionHistoryCopyWith(InspectionHistory value, $Res Function(InspectionHistory) _then) = _$InspectionHistoryCopyWithImpl;
@useResult
$Res call({
 String id, String inspectorName, String status, DateTime date, Map<String, dynamic> vehicleInfo, Map<String, String>? links
});




}
/// @nodoc
class _$InspectionHistoryCopyWithImpl<$Res>
    implements $InspectionHistoryCopyWith<$Res> {
  _$InspectionHistoryCopyWithImpl(this._self, this._then);

  final InspectionHistory _self;
  final $Res Function(InspectionHistory) _then;

/// Create a copy of InspectionHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? inspectorName = null,Object? status = null,Object? date = null,Object? vehicleInfo = null,Object? links = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectorName: null == inspectorName ? _self.inspectorName : inspectorName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,vehicleInfo: null == vehicleInfo ? _self.vehicleInfo : vehicleInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,links: freezed == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [InspectionHistory].
extension InspectionHistoryPatterns on InspectionHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionHistory value)  $default,){
final _that = this;
switch (_that) {
case _InspectionHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionHistory value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String inspectorName,  String status,  DateTime date,  Map<String, dynamic> vehicleInfo,  Map<String, String>? links)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionHistory() when $default != null:
return $default(_that.id,_that.inspectorName,_that.status,_that.date,_that.vehicleInfo,_that.links);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String inspectorName,  String status,  DateTime date,  Map<String, dynamic> vehicleInfo,  Map<String, String>? links)  $default,) {final _that = this;
switch (_that) {
case _InspectionHistory():
return $default(_that.id,_that.inspectorName,_that.status,_that.date,_that.vehicleInfo,_that.links);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String inspectorName,  String status,  DateTime date,  Map<String, dynamic> vehicleInfo,  Map<String, String>? links)?  $default,) {final _that = this;
switch (_that) {
case _InspectionHistory() when $default != null:
return $default(_that.id,_that.inspectorName,_that.status,_that.date,_that.vehicleInfo,_that.links);case _:
  return null;

}
}

}

/// @nodoc


class _InspectionHistory implements InspectionHistory {
  const _InspectionHistory({required this.id, required this.inspectorName, required this.status, required this.date, final  Map<String, dynamic> vehicleInfo = const <String, dynamic>{}, final  Map<String, String>? links}): _vehicleInfo = vehicleInfo,_links = links;
  

@override final  String id;
@override final  String inspectorName;
@override final  String status;
@override final  DateTime date;
 final  Map<String, dynamic> _vehicleInfo;
@override@JsonKey() Map<String, dynamic> get vehicleInfo {
  if (_vehicleInfo is EqualUnmodifiableMapView) return _vehicleInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_vehicleInfo);
}

 final  Map<String, String>? _links;
@override Map<String, String>? get links {
  final value = _links;
  if (value == null) return null;
  if (_links is EqualUnmodifiableMapView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of InspectionHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionHistoryCopyWith<_InspectionHistory> get copyWith => __$InspectionHistoryCopyWithImpl<_InspectionHistory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectorName, inspectorName) || other.inspectorName == inspectorName)&&(identical(other.status, status) || other.status == status)&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other._vehicleInfo, _vehicleInfo)&&const DeepCollectionEquality().equals(other._links, _links));
}


@override
int get hashCode => Object.hash(runtimeType,id,inspectorName,status,date,const DeepCollectionEquality().hash(_vehicleInfo),const DeepCollectionEquality().hash(_links));

@override
String toString() {
  return 'InspectionHistory(id: $id, inspectorName: $inspectorName, status: $status, date: $date, vehicleInfo: $vehicleInfo, links: $links)';
}


}

/// @nodoc
abstract mixin class _$InspectionHistoryCopyWith<$Res> implements $InspectionHistoryCopyWith<$Res> {
  factory _$InspectionHistoryCopyWith(_InspectionHistory value, $Res Function(_InspectionHistory) _then) = __$InspectionHistoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String inspectorName, String status, DateTime date, Map<String, dynamic> vehicleInfo, Map<String, String>? links
});




}
/// @nodoc
class __$InspectionHistoryCopyWithImpl<$Res>
    implements _$InspectionHistoryCopyWith<$Res> {
  __$InspectionHistoryCopyWithImpl(this._self, this._then);

  final _InspectionHistory _self;
  final $Res Function(_InspectionHistory) _then;

/// Create a copy of InspectionHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? inspectorName = null,Object? status = null,Object? date = null,Object? vehicleInfo = null,Object? links = freezed,}) {
  return _then(_InspectionHistory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,inspectorName: null == inspectorName ? _self.inspectorName : inspectorName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,vehicleInfo: null == vehicleInfo ? _self._vehicleInfo : vehicleInfo // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,links: freezed == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}

// dart format on
