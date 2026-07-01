// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InspectionStats {

 String? get period; String? get from; String? get to; InspectionStatsTotals get totals; List<InspectionStatsBucket> get buckets;
/// Create a copy of InspectionStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionStatsCopyWith<InspectionStats> get copyWith => _$InspectionStatsCopyWithImpl<InspectionStats>(this as InspectionStats, _$identity);

  /// Serializes this InspectionStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionStats&&(identical(other.period, period) || other.period == period)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.totals, totals) || other.totals == totals)&&const DeepCollectionEquality().equals(other.buckets, buckets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,from,to,totals,const DeepCollectionEquality().hash(buckets));

@override
String toString() {
  return 'InspectionStats(period: $period, from: $from, to: $to, totals: $totals, buckets: $buckets)';
}


}

/// @nodoc
abstract mixin class $InspectionStatsCopyWith<$Res>  {
  factory $InspectionStatsCopyWith(InspectionStats value, $Res Function(InspectionStats) _then) = _$InspectionStatsCopyWithImpl;
@useResult
$Res call({
 String? period, String? from, String? to, InspectionStatsTotals totals, List<InspectionStatsBucket> buckets
});


$InspectionStatsTotalsCopyWith<$Res> get totals;

}
/// @nodoc
class _$InspectionStatsCopyWithImpl<$Res>
    implements $InspectionStatsCopyWith<$Res> {
  _$InspectionStatsCopyWithImpl(this._self, this._then);

  final InspectionStats _self;
  final $Res Function(InspectionStats) _then;

/// Create a copy of InspectionStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = freezed,Object? from = freezed,Object? to = freezed,Object? totals = null,Object? buckets = null,}) {
  return _then(_self.copyWith(
period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String?,totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as InspectionStatsTotals,buckets: null == buckets ? _self.buckets : buckets // ignore: cast_nullable_to_non_nullable
as List<InspectionStatsBucket>,
  ));
}
/// Create a copy of InspectionStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InspectionStatsTotalsCopyWith<$Res> get totals {
  
  return $InspectionStatsTotalsCopyWith<$Res>(_self.totals, (value) {
    return _then(_self.copyWith(totals: value));
  });
}
}


/// Adds pattern-matching-related methods to [InspectionStats].
extension InspectionStatsPatterns on InspectionStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionStats value)  $default,){
final _that = this;
switch (_that) {
case _InspectionStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionStats value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? period,  String? from,  String? to,  InspectionStatsTotals totals,  List<InspectionStatsBucket> buckets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionStats() when $default != null:
return $default(_that.period,_that.from,_that.to,_that.totals,_that.buckets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? period,  String? from,  String? to,  InspectionStatsTotals totals,  List<InspectionStatsBucket> buckets)  $default,) {final _that = this;
switch (_that) {
case _InspectionStats():
return $default(_that.period,_that.from,_that.to,_that.totals,_that.buckets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? period,  String? from,  String? to,  InspectionStatsTotals totals,  List<InspectionStatsBucket> buckets)?  $default,) {final _that = this;
switch (_that) {
case _InspectionStats() when $default != null:
return $default(_that.period,_that.from,_that.to,_that.totals,_that.buckets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InspectionStats extends InspectionStats {
  const _InspectionStats({this.period, this.from, this.to, this.totals = const InspectionStatsTotals(), final  List<InspectionStatsBucket> buckets = const <InspectionStatsBucket>[]}): _buckets = buckets,super._();
  factory _InspectionStats.fromJson(Map<String, dynamic> json) => _$InspectionStatsFromJson(json);

@override final  String? period;
@override final  String? from;
@override final  String? to;
@override@JsonKey() final  InspectionStatsTotals totals;
 final  List<InspectionStatsBucket> _buckets;
@override@JsonKey() List<InspectionStatsBucket> get buckets {
  if (_buckets is EqualUnmodifiableListView) return _buckets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_buckets);
}


/// Create a copy of InspectionStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionStatsCopyWith<_InspectionStats> get copyWith => __$InspectionStatsCopyWithImpl<_InspectionStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionStats&&(identical(other.period, period) || other.period == period)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.totals, totals) || other.totals == totals)&&const DeepCollectionEquality().equals(other._buckets, _buckets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,from,to,totals,const DeepCollectionEquality().hash(_buckets));

@override
String toString() {
  return 'InspectionStats(period: $period, from: $from, to: $to, totals: $totals, buckets: $buckets)';
}


}

/// @nodoc
abstract mixin class _$InspectionStatsCopyWith<$Res> implements $InspectionStatsCopyWith<$Res> {
  factory _$InspectionStatsCopyWith(_InspectionStats value, $Res Function(_InspectionStats) _then) = __$InspectionStatsCopyWithImpl;
@override @useResult
$Res call({
 String? period, String? from, String? to, InspectionStatsTotals totals, List<InspectionStatsBucket> buckets
});


@override $InspectionStatsTotalsCopyWith<$Res> get totals;

}
/// @nodoc
class __$InspectionStatsCopyWithImpl<$Res>
    implements _$InspectionStatsCopyWith<$Res> {
  __$InspectionStatsCopyWithImpl(this._self, this._then);

  final _InspectionStats _self;
  final $Res Function(_InspectionStats) _then;

/// Create a copy of InspectionStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = freezed,Object? from = freezed,Object? to = freezed,Object? totals = null,Object? buckets = null,}) {
  return _then(_InspectionStats(
period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String?,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as String?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String?,totals: null == totals ? _self.totals : totals // ignore: cast_nullable_to_non_nullable
as InspectionStatsTotals,buckets: null == buckets ? _self._buckets : buckets // ignore: cast_nullable_to_non_nullable
as List<InspectionStatsBucket>,
  ));
}

/// Create a copy of InspectionStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InspectionStatsTotalsCopyWith<$Res> get totals {
  
  return $InspectionStatsTotalsCopyWith<$Res>(_self.totals, (value) {
    return _then(_self.copyWith(totals: value));
  });
}
}


/// @nodoc
mixin _$InspectionStatsTotals {

 int get total; int get approved; int get pending; int get rejected;
/// Create a copy of InspectionStatsTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionStatsTotalsCopyWith<InspectionStatsTotals> get copyWith => _$InspectionStatsTotalsCopyWithImpl<InspectionStatsTotals>(this as InspectionStatsTotals, _$identity);

  /// Serializes this InspectionStatsTotals to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionStatsTotals&&(identical(other.total, total) || other.total == total)&&(identical(other.approved, approved) || other.approved == approved)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.rejected, rejected) || other.rejected == rejected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,approved,pending,rejected);

@override
String toString() {
  return 'InspectionStatsTotals(total: $total, approved: $approved, pending: $pending, rejected: $rejected)';
}


}

/// @nodoc
abstract mixin class $InspectionStatsTotalsCopyWith<$Res>  {
  factory $InspectionStatsTotalsCopyWith(InspectionStatsTotals value, $Res Function(InspectionStatsTotals) _then) = _$InspectionStatsTotalsCopyWithImpl;
@useResult
$Res call({
 int total, int approved, int pending, int rejected
});




}
/// @nodoc
class _$InspectionStatsTotalsCopyWithImpl<$Res>
    implements $InspectionStatsTotalsCopyWith<$Res> {
  _$InspectionStatsTotalsCopyWithImpl(this._self, this._then);

  final InspectionStatsTotals _self;
  final $Res Function(InspectionStatsTotals) _then;

/// Create a copy of InspectionStatsTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? approved = null,Object? pending = null,Object? rejected = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [InspectionStatsTotals].
extension InspectionStatsTotalsPatterns on InspectionStatsTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionStatsTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionStatsTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionStatsTotals value)  $default,){
final _that = this;
switch (_that) {
case _InspectionStatsTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionStatsTotals value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionStatsTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  int approved,  int pending,  int rejected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionStatsTotals() when $default != null:
return $default(_that.total,_that.approved,_that.pending,_that.rejected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  int approved,  int pending,  int rejected)  $default,) {final _that = this;
switch (_that) {
case _InspectionStatsTotals():
return $default(_that.total,_that.approved,_that.pending,_that.rejected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  int approved,  int pending,  int rejected)?  $default,) {final _that = this;
switch (_that) {
case _InspectionStatsTotals() when $default != null:
return $default(_that.total,_that.approved,_that.pending,_that.rejected);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InspectionStatsTotals implements InspectionStatsTotals {
  const _InspectionStatsTotals({this.total = 0, this.approved = 0, this.pending = 0, this.rejected = 0});
  factory _InspectionStatsTotals.fromJson(Map<String, dynamic> json) => _$InspectionStatsTotalsFromJson(json);

@override@JsonKey() final  int total;
@override@JsonKey() final  int approved;
@override@JsonKey() final  int pending;
@override@JsonKey() final  int rejected;

/// Create a copy of InspectionStatsTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionStatsTotalsCopyWith<_InspectionStatsTotals> get copyWith => __$InspectionStatsTotalsCopyWithImpl<_InspectionStatsTotals>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionStatsTotalsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionStatsTotals&&(identical(other.total, total) || other.total == total)&&(identical(other.approved, approved) || other.approved == approved)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.rejected, rejected) || other.rejected == rejected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,approved,pending,rejected);

@override
String toString() {
  return 'InspectionStatsTotals(total: $total, approved: $approved, pending: $pending, rejected: $rejected)';
}


}

/// @nodoc
abstract mixin class _$InspectionStatsTotalsCopyWith<$Res> implements $InspectionStatsTotalsCopyWith<$Res> {
  factory _$InspectionStatsTotalsCopyWith(_InspectionStatsTotals value, $Res Function(_InspectionStatsTotals) _then) = __$InspectionStatsTotalsCopyWithImpl;
@override @useResult
$Res call({
 int total, int approved, int pending, int rejected
});




}
/// @nodoc
class __$InspectionStatsTotalsCopyWithImpl<$Res>
    implements _$InspectionStatsTotalsCopyWith<$Res> {
  __$InspectionStatsTotalsCopyWithImpl(this._self, this._then);

  final _InspectionStatsTotals _self;
  final $Res Function(_InspectionStatsTotals) _then;

/// Create a copy of InspectionStatsTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? approved = null,Object? pending = null,Object? rejected = null,}) {
  return _then(_InspectionStatsTotals(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$InspectionStatsBucket {

 String get bucket; int get total; int get approved; int get pending; int get rejected;
/// Create a copy of InspectionStatsBucket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionStatsBucketCopyWith<InspectionStatsBucket> get copyWith => _$InspectionStatsBucketCopyWithImpl<InspectionStatsBucket>(this as InspectionStatsBucket, _$identity);

  /// Serializes this InspectionStatsBucket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionStatsBucket&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.total, total) || other.total == total)&&(identical(other.approved, approved) || other.approved == approved)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.rejected, rejected) || other.rejected == rejected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bucket,total,approved,pending,rejected);

@override
String toString() {
  return 'InspectionStatsBucket(bucket: $bucket, total: $total, approved: $approved, pending: $pending, rejected: $rejected)';
}


}

/// @nodoc
abstract mixin class $InspectionStatsBucketCopyWith<$Res>  {
  factory $InspectionStatsBucketCopyWith(InspectionStatsBucket value, $Res Function(InspectionStatsBucket) _then) = _$InspectionStatsBucketCopyWithImpl;
@useResult
$Res call({
 String bucket, int total, int approved, int pending, int rejected
});




}
/// @nodoc
class _$InspectionStatsBucketCopyWithImpl<$Res>
    implements $InspectionStatsBucketCopyWith<$Res> {
  _$InspectionStatsBucketCopyWithImpl(this._self, this._then);

  final InspectionStatsBucket _self;
  final $Res Function(InspectionStatsBucket) _then;

/// Create a copy of InspectionStatsBucket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bucket = null,Object? total = null,Object? approved = null,Object? pending = null,Object? rejected = null,}) {
  return _then(_self.copyWith(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [InspectionStatsBucket].
extension InspectionStatsBucketPatterns on InspectionStatsBucket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionStatsBucket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionStatsBucket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionStatsBucket value)  $default,){
final _that = this;
switch (_that) {
case _InspectionStatsBucket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionStatsBucket value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionStatsBucket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bucket,  int total,  int approved,  int pending,  int rejected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionStatsBucket() when $default != null:
return $default(_that.bucket,_that.total,_that.approved,_that.pending,_that.rejected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bucket,  int total,  int approved,  int pending,  int rejected)  $default,) {final _that = this;
switch (_that) {
case _InspectionStatsBucket():
return $default(_that.bucket,_that.total,_that.approved,_that.pending,_that.rejected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bucket,  int total,  int approved,  int pending,  int rejected)?  $default,) {final _that = this;
switch (_that) {
case _InspectionStatsBucket() when $default != null:
return $default(_that.bucket,_that.total,_that.approved,_that.pending,_that.rejected);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InspectionStatsBucket implements InspectionStatsBucket {
  const _InspectionStatsBucket({this.bucket = '', this.total = 0, this.approved = 0, this.pending = 0, this.rejected = 0});
  factory _InspectionStatsBucket.fromJson(Map<String, dynamic> json) => _$InspectionStatsBucketFromJson(json);

@override@JsonKey() final  String bucket;
@override@JsonKey() final  int total;
@override@JsonKey() final  int approved;
@override@JsonKey() final  int pending;
@override@JsonKey() final  int rejected;

/// Create a copy of InspectionStatsBucket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionStatsBucketCopyWith<_InspectionStatsBucket> get copyWith => __$InspectionStatsBucketCopyWithImpl<_InspectionStatsBucket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionStatsBucketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionStatsBucket&&(identical(other.bucket, bucket) || other.bucket == bucket)&&(identical(other.total, total) || other.total == total)&&(identical(other.approved, approved) || other.approved == approved)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.rejected, rejected) || other.rejected == rejected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bucket,total,approved,pending,rejected);

@override
String toString() {
  return 'InspectionStatsBucket(bucket: $bucket, total: $total, approved: $approved, pending: $pending, rejected: $rejected)';
}


}

/// @nodoc
abstract mixin class _$InspectionStatsBucketCopyWith<$Res> implements $InspectionStatsBucketCopyWith<$Res> {
  factory _$InspectionStatsBucketCopyWith(_InspectionStatsBucket value, $Res Function(_InspectionStatsBucket) _then) = __$InspectionStatsBucketCopyWithImpl;
@override @useResult
$Res call({
 String bucket, int total, int approved, int pending, int rejected
});




}
/// @nodoc
class __$InspectionStatsBucketCopyWithImpl<$Res>
    implements _$InspectionStatsBucketCopyWith<$Res> {
  __$InspectionStatsBucketCopyWithImpl(this._self, this._then);

  final _InspectionStatsBucket _self;
  final $Res Function(_InspectionStatsBucket) _then;

/// Create a copy of InspectionStatsBucket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bucket = null,Object? total = null,Object? approved = null,Object? pending = null,Object? rejected = null,}) {
  return _then(_InspectionStatsBucket(
bucket: null == bucket ? _self.bucket : bucket // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
