// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_lists_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaginatedInspections {

 List<InspectionHistory> get items; PaginationData get pagination; bool get isLoadingMore;
/// Create a copy of PaginatedInspections
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedInspectionsCopyWith<PaginatedInspections> get copyWith => _$PaginatedInspectionsCopyWithImpl<PaginatedInspections>(this as PaginatedInspections, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedInspections&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.pagination, pagination) || other.pagination == pagination)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),pagination,isLoadingMore);

@override
String toString() {
  return 'PaginatedInspections(items: $items, pagination: $pagination, isLoadingMore: $isLoadingMore)';
}


}

/// @nodoc
abstract mixin class $PaginatedInspectionsCopyWith<$Res>  {
  factory $PaginatedInspectionsCopyWith(PaginatedInspections value, $Res Function(PaginatedInspections) _then) = _$PaginatedInspectionsCopyWithImpl;
@useResult
$Res call({
 List<InspectionHistory> items, PaginationData pagination, bool isLoadingMore
});


$PaginationDataCopyWith<$Res> get pagination;

}
/// @nodoc
class _$PaginatedInspectionsCopyWithImpl<$Res>
    implements $PaginatedInspectionsCopyWith<$Res> {
  _$PaginatedInspectionsCopyWithImpl(this._self, this._then);

  final PaginatedInspections _self;
  final $Res Function(PaginatedInspections) _then;

/// Create a copy of PaginatedInspections
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? pagination = null,Object? isLoadingMore = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<InspectionHistory>,pagination: null == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationData,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PaginatedInspections
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginationDataCopyWith<$Res> get pagination {
  
  return $PaginationDataCopyWith<$Res>(_self.pagination, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}
}


/// Adds pattern-matching-related methods to [PaginatedInspections].
extension PaginatedInspectionsPatterns on PaginatedInspections {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedInspections value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedInspections() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedInspections value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedInspections():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedInspections value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedInspections() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<InspectionHistory> items,  PaginationData pagination,  bool isLoadingMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedInspections() when $default != null:
return $default(_that.items,_that.pagination,_that.isLoadingMore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<InspectionHistory> items,  PaginationData pagination,  bool isLoadingMore)  $default,) {final _that = this;
switch (_that) {
case _PaginatedInspections():
return $default(_that.items,_that.pagination,_that.isLoadingMore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<InspectionHistory> items,  PaginationData pagination,  bool isLoadingMore)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedInspections() when $default != null:
return $default(_that.items,_that.pagination,_that.isLoadingMore);case _:
  return null;

}
}

}

/// @nodoc


class _PaginatedInspections implements PaginatedInspections {
  const _PaginatedInspections({final  List<InspectionHistory> items = const <InspectionHistory>[], this.pagination = const PaginationData(), this.isLoadingMore = false}): _items = items;
  

 final  List<InspectionHistory> _items;
@override@JsonKey() List<InspectionHistory> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  PaginationData pagination;
@override@JsonKey() final  bool isLoadingMore;

/// Create a copy of PaginatedInspections
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedInspectionsCopyWith<_PaginatedInspections> get copyWith => __$PaginatedInspectionsCopyWithImpl<_PaginatedInspections>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedInspections&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.pagination, pagination) || other.pagination == pagination)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),pagination,isLoadingMore);

@override
String toString() {
  return 'PaginatedInspections(items: $items, pagination: $pagination, isLoadingMore: $isLoadingMore)';
}


}

/// @nodoc
abstract mixin class _$PaginatedInspectionsCopyWith<$Res> implements $PaginatedInspectionsCopyWith<$Res> {
  factory _$PaginatedInspectionsCopyWith(_PaginatedInspections value, $Res Function(_PaginatedInspections) _then) = __$PaginatedInspectionsCopyWithImpl;
@override @useResult
$Res call({
 List<InspectionHistory> items, PaginationData pagination, bool isLoadingMore
});


@override $PaginationDataCopyWith<$Res> get pagination;

}
/// @nodoc
class __$PaginatedInspectionsCopyWithImpl<$Res>
    implements _$PaginatedInspectionsCopyWith<$Res> {
  __$PaginatedInspectionsCopyWithImpl(this._self, this._then);

  final _PaginatedInspections _self;
  final $Res Function(_PaginatedInspections) _then;

/// Create a copy of PaginatedInspections
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? pagination = null,Object? isLoadingMore = null,}) {
  return _then(_PaginatedInspections(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<InspectionHistory>,pagination: null == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationData,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PaginatedInspections
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaginationDataCopyWith<$Res> get pagination {
  
  return $PaginationDataCopyWith<$Res>(_self.pagination, (value) {
    return _then(_self.copyWith(pagination: value));
  });
}
}

// dart format on
