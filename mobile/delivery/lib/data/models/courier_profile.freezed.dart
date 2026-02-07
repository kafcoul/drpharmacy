// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'courier_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CourierProfile {

 int get id; String get name; String get email; String? get avatar; String get status;@JsonKey(name: 'vehicle_type') String get vehicleType;@JsonKey(name: 'plate_number', defaultValue: '') String get plateNumber; double get rating;@JsonKey(name: 'completed_deliveries') int get completedDeliveries; double get earnings;
/// Create a copy of CourierProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourierProfileCopyWith<CourierProfile> get copyWith => _$CourierProfileCopyWithImpl<CourierProfile>(this as CourierProfile, _$identity);

  /// Serializes this CourierProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourierProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.status, status) || other.status == status)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.plateNumber, plateNumber) || other.plateNumber == plateNumber)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.completedDeliveries, completedDeliveries) || other.completedDeliveries == completedDeliveries)&&(identical(other.earnings, earnings) || other.earnings == earnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,avatar,status,vehicleType,plateNumber,rating,completedDeliveries,earnings);

@override
String toString() {
  return 'CourierProfile(id: $id, name: $name, email: $email, avatar: $avatar, status: $status, vehicleType: $vehicleType, plateNumber: $plateNumber, rating: $rating, completedDeliveries: $completedDeliveries, earnings: $earnings)';
}


}

/// @nodoc
abstract mixin class $CourierProfileCopyWith<$Res>  {
  factory $CourierProfileCopyWith(CourierProfile value, $Res Function(CourierProfile) _then) = _$CourierProfileCopyWithImpl;
@useResult
$Res call({
 int id, String name, String email, String? avatar, String status,@JsonKey(name: 'vehicle_type') String vehicleType,@JsonKey(name: 'plate_number', defaultValue: '') String plateNumber, double rating,@JsonKey(name: 'completed_deliveries') int completedDeliveries, double earnings
});




}
/// @nodoc
class _$CourierProfileCopyWithImpl<$Res>
    implements $CourierProfileCopyWith<$Res> {
  _$CourierProfileCopyWithImpl(this._self, this._then);

  final CourierProfile _self;
  final $Res Function(CourierProfile) _then;

/// Create a copy of CourierProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? avatar = freezed,Object? status = null,Object? vehicleType = null,Object? plateNumber = null,Object? rating = null,Object? completedDeliveries = null,Object? earnings = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,plateNumber: null == plateNumber ? _self.plateNumber : plateNumber // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,completedDeliveries: null == completedDeliveries ? _self.completedDeliveries : completedDeliveries // ignore: cast_nullable_to_non_nullable
as int,earnings: null == earnings ? _self.earnings : earnings // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CourierProfile].
extension CourierProfilePatterns on CourierProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CourierProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CourierProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CourierProfile value)  $default,){
final _that = this;
switch (_that) {
case _CourierProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CourierProfile value)?  $default,){
final _that = this;
switch (_that) {
case _CourierProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String email,  String? avatar,  String status, @JsonKey(name: 'vehicle_type')  String vehicleType, @JsonKey(name: 'plate_number', defaultValue: '')  String plateNumber,  double rating, @JsonKey(name: 'completed_deliveries')  int completedDeliveries,  double earnings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CourierProfile() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.avatar,_that.status,_that.vehicleType,_that.plateNumber,_that.rating,_that.completedDeliveries,_that.earnings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String email,  String? avatar,  String status, @JsonKey(name: 'vehicle_type')  String vehicleType, @JsonKey(name: 'plate_number', defaultValue: '')  String plateNumber,  double rating, @JsonKey(name: 'completed_deliveries')  int completedDeliveries,  double earnings)  $default,) {final _that = this;
switch (_that) {
case _CourierProfile():
return $default(_that.id,_that.name,_that.email,_that.avatar,_that.status,_that.vehicleType,_that.plateNumber,_that.rating,_that.completedDeliveries,_that.earnings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String email,  String? avatar,  String status, @JsonKey(name: 'vehicle_type')  String vehicleType, @JsonKey(name: 'plate_number', defaultValue: '')  String plateNumber,  double rating, @JsonKey(name: 'completed_deliveries')  int completedDeliveries,  double earnings)?  $default,) {final _that = this;
switch (_that) {
case _CourierProfile() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.avatar,_that.status,_that.vehicleType,_that.plateNumber,_that.rating,_that.completedDeliveries,_that.earnings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CourierProfile implements CourierProfile {
  const _CourierProfile({required this.id, required this.name, required this.email, this.avatar, required this.status, @JsonKey(name: 'vehicle_type') required this.vehicleType, @JsonKey(name: 'plate_number', defaultValue: '') required this.plateNumber, required this.rating, @JsonKey(name: 'completed_deliveries') required this.completedDeliveries, required this.earnings});
  factory _CourierProfile.fromJson(Map<String, dynamic> json) => _$CourierProfileFromJson(json);

@override final  int id;
@override final  String name;
@override final  String email;
@override final  String? avatar;
@override final  String status;
@override@JsonKey(name: 'vehicle_type') final  String vehicleType;
@override@JsonKey(name: 'plate_number', defaultValue: '') final  String plateNumber;
@override final  double rating;
@override@JsonKey(name: 'completed_deliveries') final  int completedDeliveries;
@override final  double earnings;

/// Create a copy of CourierProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourierProfileCopyWith<_CourierProfile> get copyWith => __$CourierProfileCopyWithImpl<_CourierProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourierProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CourierProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.status, status) || other.status == status)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.plateNumber, plateNumber) || other.plateNumber == plateNumber)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.completedDeliveries, completedDeliveries) || other.completedDeliveries == completedDeliveries)&&(identical(other.earnings, earnings) || other.earnings == earnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,avatar,status,vehicleType,plateNumber,rating,completedDeliveries,earnings);

@override
String toString() {
  return 'CourierProfile(id: $id, name: $name, email: $email, avatar: $avatar, status: $status, vehicleType: $vehicleType, plateNumber: $plateNumber, rating: $rating, completedDeliveries: $completedDeliveries, earnings: $earnings)';
}


}

/// @nodoc
abstract mixin class _$CourierProfileCopyWith<$Res> implements $CourierProfileCopyWith<$Res> {
  factory _$CourierProfileCopyWith(_CourierProfile value, $Res Function(_CourierProfile) _then) = __$CourierProfileCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String email, String? avatar, String status,@JsonKey(name: 'vehicle_type') String vehicleType,@JsonKey(name: 'plate_number', defaultValue: '') String plateNumber, double rating,@JsonKey(name: 'completed_deliveries') int completedDeliveries, double earnings
});




}
/// @nodoc
class __$CourierProfileCopyWithImpl<$Res>
    implements _$CourierProfileCopyWith<$Res> {
  __$CourierProfileCopyWithImpl(this._self, this._then);

  final _CourierProfile _self;
  final $Res Function(_CourierProfile) _then;

/// Create a copy of CourierProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? avatar = freezed,Object? status = null,Object? vehicleType = null,Object? plateNumber = null,Object? rating = null,Object? completedDeliveries = null,Object? earnings = null,}) {
  return _then(_CourierProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,plateNumber: null == plateNumber ? _self.plateNumber : plateNumber // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,completedDeliveries: null == completedDeliveries ? _self.completedDeliveries : completedDeliveries // ignore: cast_nullable_to_non_nullable
as int,earnings: null == earnings ? _self.earnings : earnings // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
