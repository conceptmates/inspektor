// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AttendanceRecord {

 int? get id; int? get inspectorId; String get inspectorName; String? get inspectorEmail; String get type; DateTime? get date; DateTime? get checkIn; DateTime? get checkOut; double? get latitude; double? get longitude;
/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceRecordCopyWith<AttendanceRecord> get copyWith => _$AttendanceRecordCopyWithImpl<AttendanceRecord>(this as AttendanceRecord, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttendanceRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectorId, inspectorId) || other.inspectorId == inspectorId)&&(identical(other.inspectorName, inspectorName) || other.inspectorName == inspectorName)&&(identical(other.inspectorEmail, inspectorEmail) || other.inspectorEmail == inspectorEmail)&&(identical(other.type, type) || other.type == type)&&(identical(other.date, date) || other.date == date)&&(identical(other.checkIn, checkIn) || other.checkIn == checkIn)&&(identical(other.checkOut, checkOut) || other.checkOut == checkOut)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}


@override
int get hashCode => Object.hash(runtimeType,id,inspectorId,inspectorName,inspectorEmail,type,date,checkIn,checkOut,latitude,longitude);

@override
String toString() {
  return 'AttendanceRecord(id: $id, inspectorId: $inspectorId, inspectorName: $inspectorName, inspectorEmail: $inspectorEmail, type: $type, date: $date, checkIn: $checkIn, checkOut: $checkOut, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $AttendanceRecordCopyWith<$Res>  {
  factory $AttendanceRecordCopyWith(AttendanceRecord value, $Res Function(AttendanceRecord) _then) = _$AttendanceRecordCopyWithImpl;
@useResult
$Res call({
 int? id, int? inspectorId, String inspectorName, String? inspectorEmail, String type, DateTime? date, DateTime? checkIn, DateTime? checkOut, double? latitude, double? longitude
});




}
/// @nodoc
class _$AttendanceRecordCopyWithImpl<$Res>
    implements $AttendanceRecordCopyWith<$Res> {
  _$AttendanceRecordCopyWithImpl(this._self, this._then);

  final AttendanceRecord _self;
  final $Res Function(AttendanceRecord) _then;

/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? inspectorId = freezed,Object? inspectorName = null,Object? inspectorEmail = freezed,Object? type = null,Object? date = freezed,Object? checkIn = freezed,Object? checkOut = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,inspectorId: freezed == inspectorId ? _self.inspectorId : inspectorId // ignore: cast_nullable_to_non_nullable
as int?,inspectorName: null == inspectorName ? _self.inspectorName : inspectorName // ignore: cast_nullable_to_non_nullable
as String,inspectorEmail: freezed == inspectorEmail ? _self.inspectorEmail : inspectorEmail // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,checkIn: freezed == checkIn ? _self.checkIn : checkIn // ignore: cast_nullable_to_non_nullable
as DateTime?,checkOut: freezed == checkOut ? _self.checkOut : checkOut // ignore: cast_nullable_to_non_nullable
as DateTime?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [AttendanceRecord].
extension AttendanceRecordPatterns on AttendanceRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AttendanceRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AttendanceRecord value)  $default,){
final _that = this;
switch (_that) {
case _AttendanceRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AttendanceRecord value)?  $default,){
final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? inspectorId,  String inspectorName,  String? inspectorEmail,  String type,  DateTime? date,  DateTime? checkIn,  DateTime? checkOut,  double? latitude,  double? longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
return $default(_that.id,_that.inspectorId,_that.inspectorName,_that.inspectorEmail,_that.type,_that.date,_that.checkIn,_that.checkOut,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? inspectorId,  String inspectorName,  String? inspectorEmail,  String type,  DateTime? date,  DateTime? checkIn,  DateTime? checkOut,  double? latitude,  double? longitude)  $default,) {final _that = this;
switch (_that) {
case _AttendanceRecord():
return $default(_that.id,_that.inspectorId,_that.inspectorName,_that.inspectorEmail,_that.type,_that.date,_that.checkIn,_that.checkOut,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? inspectorId,  String inspectorName,  String? inspectorEmail,  String type,  DateTime? date,  DateTime? checkIn,  DateTime? checkOut,  double? latitude,  double? longitude)?  $default,) {final _that = this;
switch (_that) {
case _AttendanceRecord() when $default != null:
return $default(_that.id,_that.inspectorId,_that.inspectorName,_that.inspectorEmail,_that.type,_that.date,_that.checkIn,_that.checkOut,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc


class _AttendanceRecord extends AttendanceRecord {
  const _AttendanceRecord({this.id, this.inspectorId, this.inspectorName = 'Inspector', this.inspectorEmail, this.type = 'available', this.date, this.checkIn, this.checkOut, this.latitude, this.longitude}): super._();
  

@override final  int? id;
@override final  int? inspectorId;
@override@JsonKey() final  String inspectorName;
@override final  String? inspectorEmail;
@override@JsonKey() final  String type;
@override final  DateTime? date;
@override final  DateTime? checkIn;
@override final  DateTime? checkOut;
@override final  double? latitude;
@override final  double? longitude;

/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceRecordCopyWith<_AttendanceRecord> get copyWith => __$AttendanceRecordCopyWithImpl<_AttendanceRecord>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AttendanceRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectorId, inspectorId) || other.inspectorId == inspectorId)&&(identical(other.inspectorName, inspectorName) || other.inspectorName == inspectorName)&&(identical(other.inspectorEmail, inspectorEmail) || other.inspectorEmail == inspectorEmail)&&(identical(other.type, type) || other.type == type)&&(identical(other.date, date) || other.date == date)&&(identical(other.checkIn, checkIn) || other.checkIn == checkIn)&&(identical(other.checkOut, checkOut) || other.checkOut == checkOut)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}


@override
int get hashCode => Object.hash(runtimeType,id,inspectorId,inspectorName,inspectorEmail,type,date,checkIn,checkOut,latitude,longitude);

@override
String toString() {
  return 'AttendanceRecord(id: $id, inspectorId: $inspectorId, inspectorName: $inspectorName, inspectorEmail: $inspectorEmail, type: $type, date: $date, checkIn: $checkIn, checkOut: $checkOut, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$AttendanceRecordCopyWith<$Res> implements $AttendanceRecordCopyWith<$Res> {
  factory _$AttendanceRecordCopyWith(_AttendanceRecord value, $Res Function(_AttendanceRecord) _then) = __$AttendanceRecordCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? inspectorId, String inspectorName, String? inspectorEmail, String type, DateTime? date, DateTime? checkIn, DateTime? checkOut, double? latitude, double? longitude
});




}
/// @nodoc
class __$AttendanceRecordCopyWithImpl<$Res>
    implements _$AttendanceRecordCopyWith<$Res> {
  __$AttendanceRecordCopyWithImpl(this._self, this._then);

  final _AttendanceRecord _self;
  final $Res Function(_AttendanceRecord) _then;

/// Create a copy of AttendanceRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? inspectorId = freezed,Object? inspectorName = null,Object? inspectorEmail = freezed,Object? type = null,Object? date = freezed,Object? checkIn = freezed,Object? checkOut = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_AttendanceRecord(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,inspectorId: freezed == inspectorId ? _self.inspectorId : inspectorId // ignore: cast_nullable_to_non_nullable
as int?,inspectorName: null == inspectorName ? _self.inspectorName : inspectorName // ignore: cast_nullable_to_non_nullable
as String,inspectorEmail: freezed == inspectorEmail ? _self.inspectorEmail : inspectorEmail // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,checkIn: freezed == checkIn ? _self.checkIn : checkIn // ignore: cast_nullable_to_non_nullable
as DateTime?,checkOut: freezed == checkOut ? _self.checkOut : checkOut // ignore: cast_nullable_to_non_nullable
as DateTime?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
mixin _$InspectorLeave {

 int? get id; DateTime? get leaveDate; String? get reason; String get status; String? get adminNote; DateTime? get reviewedAt; String? get reviewedBy; DateTime? get createdAt;
/// Create a copy of InspectorLeave
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectorLeaveCopyWith<InspectorLeave> get copyWith => _$InspectorLeaveCopyWithImpl<InspectorLeave>(this as InspectorLeave, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectorLeave&&(identical(other.id, id) || other.id == id)&&(identical(other.leaveDate, leaveDate) || other.leaveDate == leaveDate)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.adminNote, adminNote) || other.adminNote == adminNote)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,leaveDate,reason,status,adminNote,reviewedAt,reviewedBy,createdAt);

@override
String toString() {
  return 'InspectorLeave(id: $id, leaveDate: $leaveDate, reason: $reason, status: $status, adminNote: $adminNote, reviewedAt: $reviewedAt, reviewedBy: $reviewedBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $InspectorLeaveCopyWith<$Res>  {
  factory $InspectorLeaveCopyWith(InspectorLeave value, $Res Function(InspectorLeave) _then) = _$InspectorLeaveCopyWithImpl;
@useResult
$Res call({
 int? id, DateTime? leaveDate, String? reason, String status, String? adminNote, DateTime? reviewedAt, String? reviewedBy, DateTime? createdAt
});




}
/// @nodoc
class _$InspectorLeaveCopyWithImpl<$Res>
    implements $InspectorLeaveCopyWith<$Res> {
  _$InspectorLeaveCopyWithImpl(this._self, this._then);

  final InspectorLeave _self;
  final $Res Function(InspectorLeave) _then;

/// Create a copy of InspectorLeave
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? leaveDate = freezed,Object? reason = freezed,Object? status = null,Object? adminNote = freezed,Object? reviewedAt = freezed,Object? reviewedBy = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,leaveDate: freezed == leaveDate ? _self.leaveDate : leaveDate // ignore: cast_nullable_to_non_nullable
as DateTime?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,adminNote: freezed == adminNote ? _self.adminNote : adminNote // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InspectorLeave].
extension InspectorLeavePatterns on InspectorLeave {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectorLeave value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectorLeave() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectorLeave value)  $default,){
final _that = this;
switch (_that) {
case _InspectorLeave():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectorLeave value)?  $default,){
final _that = this;
switch (_that) {
case _InspectorLeave() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  DateTime? leaveDate,  String? reason,  String status,  String? adminNote,  DateTime? reviewedAt,  String? reviewedBy,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectorLeave() when $default != null:
return $default(_that.id,_that.leaveDate,_that.reason,_that.status,_that.adminNote,_that.reviewedAt,_that.reviewedBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  DateTime? leaveDate,  String? reason,  String status,  String? adminNote,  DateTime? reviewedAt,  String? reviewedBy,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _InspectorLeave():
return $default(_that.id,_that.leaveDate,_that.reason,_that.status,_that.adminNote,_that.reviewedAt,_that.reviewedBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  DateTime? leaveDate,  String? reason,  String status,  String? adminNote,  DateTime? reviewedAt,  String? reviewedBy,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InspectorLeave() when $default != null:
return $default(_that.id,_that.leaveDate,_that.reason,_that.status,_that.adminNote,_that.reviewedAt,_that.reviewedBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _InspectorLeave extends InspectorLeave {
  const _InspectorLeave({this.id, this.leaveDate, this.reason, this.status = 'pending', this.adminNote, this.reviewedAt, this.reviewedBy, this.createdAt}): super._();
  

@override final  int? id;
@override final  DateTime? leaveDate;
@override final  String? reason;
@override@JsonKey() final  String status;
@override final  String? adminNote;
@override final  DateTime? reviewedAt;
@override final  String? reviewedBy;
@override final  DateTime? createdAt;

/// Create a copy of InspectorLeave
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectorLeaveCopyWith<_InspectorLeave> get copyWith => __$InspectorLeaveCopyWithImpl<_InspectorLeave>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectorLeave&&(identical(other.id, id) || other.id == id)&&(identical(other.leaveDate, leaveDate) || other.leaveDate == leaveDate)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status)&&(identical(other.adminNote, adminNote) || other.adminNote == adminNote)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.reviewedBy, reviewedBy) || other.reviewedBy == reviewedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,leaveDate,reason,status,adminNote,reviewedAt,reviewedBy,createdAt);

@override
String toString() {
  return 'InspectorLeave(id: $id, leaveDate: $leaveDate, reason: $reason, status: $status, adminNote: $adminNote, reviewedAt: $reviewedAt, reviewedBy: $reviewedBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InspectorLeaveCopyWith<$Res> implements $InspectorLeaveCopyWith<$Res> {
  factory _$InspectorLeaveCopyWith(_InspectorLeave value, $Res Function(_InspectorLeave) _then) = __$InspectorLeaveCopyWithImpl;
@override @useResult
$Res call({
 int? id, DateTime? leaveDate, String? reason, String status, String? adminNote, DateTime? reviewedAt, String? reviewedBy, DateTime? createdAt
});




}
/// @nodoc
class __$InspectorLeaveCopyWithImpl<$Res>
    implements _$InspectorLeaveCopyWith<$Res> {
  __$InspectorLeaveCopyWithImpl(this._self, this._then);

  final _InspectorLeave _self;
  final $Res Function(_InspectorLeave) _then;

/// Create a copy of InspectorLeave
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? leaveDate = freezed,Object? reason = freezed,Object? status = null,Object? adminNote = freezed,Object? reviewedAt = freezed,Object? reviewedBy = freezed,Object? createdAt = freezed,}) {
  return _then(_InspectorLeave(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,leaveDate: freezed == leaveDate ? _self.leaveDate : leaveDate // ignore: cast_nullable_to_non_nullable
as DateTime?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,adminNote: freezed == adminNote ? _self.adminNote : adminNote // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedBy: freezed == reviewedBy ? _self.reviewedBy : reviewedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$LeaveRequest {

 int? get id; int? get inspectorId; String get inspectorName; String? get inspectorEmail; String get status; DateTime? get leaveDate; String? get reason; String? get adminNote; DateTime? get createdAt; List<String> get conflictingBookings;
/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveRequestCopyWith<LeaveRequest> get copyWith => _$LeaveRequestCopyWithImpl<LeaveRequest>(this as LeaveRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectorId, inspectorId) || other.inspectorId == inspectorId)&&(identical(other.inspectorName, inspectorName) || other.inspectorName == inspectorName)&&(identical(other.inspectorEmail, inspectorEmail) || other.inspectorEmail == inspectorEmail)&&(identical(other.status, status) || other.status == status)&&(identical(other.leaveDate, leaveDate) || other.leaveDate == leaveDate)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.adminNote, adminNote) || other.adminNote == adminNote)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.conflictingBookings, conflictingBookings));
}


@override
int get hashCode => Object.hash(runtimeType,id,inspectorId,inspectorName,inspectorEmail,status,leaveDate,reason,adminNote,createdAt,const DeepCollectionEquality().hash(conflictingBookings));

@override
String toString() {
  return 'LeaveRequest(id: $id, inspectorId: $inspectorId, inspectorName: $inspectorName, inspectorEmail: $inspectorEmail, status: $status, leaveDate: $leaveDate, reason: $reason, adminNote: $adminNote, createdAt: $createdAt, conflictingBookings: $conflictingBookings)';
}


}

/// @nodoc
abstract mixin class $LeaveRequestCopyWith<$Res>  {
  factory $LeaveRequestCopyWith(LeaveRequest value, $Res Function(LeaveRequest) _then) = _$LeaveRequestCopyWithImpl;
@useResult
$Res call({
 int? id, int? inspectorId, String inspectorName, String? inspectorEmail, String status, DateTime? leaveDate, String? reason, String? adminNote, DateTime? createdAt, List<String> conflictingBookings
});




}
/// @nodoc
class _$LeaveRequestCopyWithImpl<$Res>
    implements $LeaveRequestCopyWith<$Res> {
  _$LeaveRequestCopyWithImpl(this._self, this._then);

  final LeaveRequest _self;
  final $Res Function(LeaveRequest) _then;

/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? inspectorId = freezed,Object? inspectorName = null,Object? inspectorEmail = freezed,Object? status = null,Object? leaveDate = freezed,Object? reason = freezed,Object? adminNote = freezed,Object? createdAt = freezed,Object? conflictingBookings = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,inspectorId: freezed == inspectorId ? _self.inspectorId : inspectorId // ignore: cast_nullable_to_non_nullable
as int?,inspectorName: null == inspectorName ? _self.inspectorName : inspectorName // ignore: cast_nullable_to_non_nullable
as String,inspectorEmail: freezed == inspectorEmail ? _self.inspectorEmail : inspectorEmail // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,leaveDate: freezed == leaveDate ? _self.leaveDate : leaveDate // ignore: cast_nullable_to_non_nullable
as DateTime?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,adminNote: freezed == adminNote ? _self.adminNote : adminNote // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,conflictingBookings: null == conflictingBookings ? _self.conflictingBookings : conflictingBookings // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaveRequest].
extension LeaveRequestPatterns on LeaveRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveRequest value)  $default,){
final _that = this;
switch (_that) {
case _LeaveRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveRequest value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? inspectorId,  String inspectorName,  String? inspectorEmail,  String status,  DateTime? leaveDate,  String? reason,  String? adminNote,  DateTime? createdAt,  List<String> conflictingBookings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
return $default(_that.id,_that.inspectorId,_that.inspectorName,_that.inspectorEmail,_that.status,_that.leaveDate,_that.reason,_that.adminNote,_that.createdAt,_that.conflictingBookings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? inspectorId,  String inspectorName,  String? inspectorEmail,  String status,  DateTime? leaveDate,  String? reason,  String? adminNote,  DateTime? createdAt,  List<String> conflictingBookings)  $default,) {final _that = this;
switch (_that) {
case _LeaveRequest():
return $default(_that.id,_that.inspectorId,_that.inspectorName,_that.inspectorEmail,_that.status,_that.leaveDate,_that.reason,_that.adminNote,_that.createdAt,_that.conflictingBookings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? inspectorId,  String inspectorName,  String? inspectorEmail,  String status,  DateTime? leaveDate,  String? reason,  String? adminNote,  DateTime? createdAt,  List<String> conflictingBookings)?  $default,) {final _that = this;
switch (_that) {
case _LeaveRequest() when $default != null:
return $default(_that.id,_that.inspectorId,_that.inspectorName,_that.inspectorEmail,_that.status,_that.leaveDate,_that.reason,_that.adminNote,_that.createdAt,_that.conflictingBookings);case _:
  return null;

}
}

}

/// @nodoc


class _LeaveRequest extends LeaveRequest {
  const _LeaveRequest({this.id, this.inspectorId, this.inspectorName = 'Inspector', this.inspectorEmail, this.status = 'pending', this.leaveDate, this.reason, this.adminNote, this.createdAt, final  List<String> conflictingBookings = const <String>[]}): _conflictingBookings = conflictingBookings,super._();
  

@override final  int? id;
@override final  int? inspectorId;
@override@JsonKey() final  String inspectorName;
@override final  String? inspectorEmail;
@override@JsonKey() final  String status;
@override final  DateTime? leaveDate;
@override final  String? reason;
@override final  String? adminNote;
@override final  DateTime? createdAt;
 final  List<String> _conflictingBookings;
@override@JsonKey() List<String> get conflictingBookings {
  if (_conflictingBookings is EqualUnmodifiableListView) return _conflictingBookings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conflictingBookings);
}


/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveRequestCopyWith<_LeaveRequest> get copyWith => __$LeaveRequestCopyWithImpl<_LeaveRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.inspectorId, inspectorId) || other.inspectorId == inspectorId)&&(identical(other.inspectorName, inspectorName) || other.inspectorName == inspectorName)&&(identical(other.inspectorEmail, inspectorEmail) || other.inspectorEmail == inspectorEmail)&&(identical(other.status, status) || other.status == status)&&(identical(other.leaveDate, leaveDate) || other.leaveDate == leaveDate)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.adminNote, adminNote) || other.adminNote == adminNote)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._conflictingBookings, _conflictingBookings));
}


@override
int get hashCode => Object.hash(runtimeType,id,inspectorId,inspectorName,inspectorEmail,status,leaveDate,reason,adminNote,createdAt,const DeepCollectionEquality().hash(_conflictingBookings));

@override
String toString() {
  return 'LeaveRequest(id: $id, inspectorId: $inspectorId, inspectorName: $inspectorName, inspectorEmail: $inspectorEmail, status: $status, leaveDate: $leaveDate, reason: $reason, adminNote: $adminNote, createdAt: $createdAt, conflictingBookings: $conflictingBookings)';
}


}

/// @nodoc
abstract mixin class _$LeaveRequestCopyWith<$Res> implements $LeaveRequestCopyWith<$Res> {
  factory _$LeaveRequestCopyWith(_LeaveRequest value, $Res Function(_LeaveRequest) _then) = __$LeaveRequestCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? inspectorId, String inspectorName, String? inspectorEmail, String status, DateTime? leaveDate, String? reason, String? adminNote, DateTime? createdAt, List<String> conflictingBookings
});




}
/// @nodoc
class __$LeaveRequestCopyWithImpl<$Res>
    implements _$LeaveRequestCopyWith<$Res> {
  __$LeaveRequestCopyWithImpl(this._self, this._then);

  final _LeaveRequest _self;
  final $Res Function(_LeaveRequest) _then;

/// Create a copy of LeaveRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? inspectorId = freezed,Object? inspectorName = null,Object? inspectorEmail = freezed,Object? status = null,Object? leaveDate = freezed,Object? reason = freezed,Object? adminNote = freezed,Object? createdAt = freezed,Object? conflictingBookings = null,}) {
  return _then(_LeaveRequest(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,inspectorId: freezed == inspectorId ? _self.inspectorId : inspectorId // ignore: cast_nullable_to_non_nullable
as int?,inspectorName: null == inspectorName ? _self.inspectorName : inspectorName // ignore: cast_nullable_to_non_nullable
as String,inspectorEmail: freezed == inspectorEmail ? _self.inspectorEmail : inspectorEmail // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,leaveDate: freezed == leaveDate ? _self.leaveDate : leaveDate // ignore: cast_nullable_to_non_nullable
as DateTime?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,adminNote: freezed == adminNote ? _self.adminNote : adminNote // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,conflictingBookings: null == conflictingBookings ? _self._conflictingBookings : conflictingBookings // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
