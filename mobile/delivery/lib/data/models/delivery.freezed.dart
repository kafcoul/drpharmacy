// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Delivery {

 int get id; String get reference;@JsonKey(name: 'pharmacy_name') String get pharmacyName;@JsonKey(name: 'pharmacy_address') String get pharmacyAddress;@JsonKey(name: 'pharmacy_phone') String? get pharmacyPhone;@JsonKey(name: 'customer_name') String get customerName;@JsonKey(name: 'customer_phone') String? get customerPhone;@JsonKey(name: 'delivery_address') String get deliveryAddress;@JsonKey(name: 'pharmacy_latitude') double? get pharmacyLat;@JsonKey(name: 'pharmacy_longitude') double? get pharmacyLng;@JsonKey(name: 'delivery_latitude') double? get deliveryLat;@JsonKey(name: 'delivery_longitude') double? get deliveryLng;@JsonKey(name: 'total_amount') double get totalAmount;@JsonKey(name: 'delivery_fee') double? get deliveryFee;@JsonKey(name: 'commission') double? get commission;@JsonKey(name: 'estimated_earnings') double? get estimatedEarnings;@JsonKey(name: 'distance_km') double? get distanceKm; String get status;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of Delivery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeliveryCopyWith<Delivery> get copyWith => _$DeliveryCopyWithImpl<Delivery>(this as Delivery, _$identity);

  /// Serializes this Delivery to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Delivery&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.pharmacyName, pharmacyName) || other.pharmacyName == pharmacyName)&&(identical(other.pharmacyAddress, pharmacyAddress) || other.pharmacyAddress == pharmacyAddress)&&(identical(other.pharmacyPhone, pharmacyPhone) || other.pharmacyPhone == pharmacyPhone)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.pharmacyLat, pharmacyLat) || other.pharmacyLat == pharmacyLat)&&(identical(other.pharmacyLng, pharmacyLng) || other.pharmacyLng == pharmacyLng)&&(identical(other.deliveryLat, deliveryLat) || other.deliveryLat == deliveryLat)&&(identical(other.deliveryLng, deliveryLng) || other.deliveryLng == deliveryLng)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.estimatedEarnings, estimatedEarnings) || other.estimatedEarnings == estimatedEarnings)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reference,pharmacyName,pharmacyAddress,pharmacyPhone,customerName,customerPhone,deliveryAddress,pharmacyLat,pharmacyLng,deliveryLat,deliveryLng,totalAmount,deliveryFee,commission,estimatedEarnings,distanceKm,status,createdAt]);

@override
String toString() {
  return 'Delivery(id: $id, reference: $reference, pharmacyName: $pharmacyName, pharmacyAddress: $pharmacyAddress, pharmacyPhone: $pharmacyPhone, customerName: $customerName, customerPhone: $customerPhone, deliveryAddress: $deliveryAddress, pharmacyLat: $pharmacyLat, pharmacyLng: $pharmacyLng, deliveryLat: $deliveryLat, deliveryLng: $deliveryLng, totalAmount: $totalAmount, deliveryFee: $deliveryFee, commission: $commission, estimatedEarnings: $estimatedEarnings, distanceKm: $distanceKm, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DeliveryCopyWith<$Res>  {
  factory $DeliveryCopyWith(Delivery value, $Res Function(Delivery) _then) = _$DeliveryCopyWithImpl;
@useResult
$Res call({
 int id, String reference,@JsonKey(name: 'pharmacy_name') String pharmacyName,@JsonKey(name: 'pharmacy_address') String pharmacyAddress,@JsonKey(name: 'pharmacy_phone') String? pharmacyPhone,@JsonKey(name: 'customer_name') String customerName,@JsonKey(name: 'customer_phone') String? customerPhone,@JsonKey(name: 'delivery_address') String deliveryAddress,@JsonKey(name: 'pharmacy_latitude') double? pharmacyLat,@JsonKey(name: 'pharmacy_longitude') double? pharmacyLng,@JsonKey(name: 'delivery_latitude') double? deliveryLat,@JsonKey(name: 'delivery_longitude') double? deliveryLng,@JsonKey(name: 'total_amount') double totalAmount,@JsonKey(name: 'delivery_fee') double? deliveryFee,@JsonKey(name: 'commission') double? commission,@JsonKey(name: 'estimated_earnings') double? estimatedEarnings,@JsonKey(name: 'distance_km') double? distanceKm, String status,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$DeliveryCopyWithImpl<$Res>
    implements $DeliveryCopyWith<$Res> {
  _$DeliveryCopyWithImpl(this._self, this._then);

  final Delivery _self;
  final $Res Function(Delivery) _then;

/// Create a copy of Delivery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reference = null,Object? pharmacyName = null,Object? pharmacyAddress = null,Object? pharmacyPhone = freezed,Object? customerName = null,Object? customerPhone = freezed,Object? deliveryAddress = null,Object? pharmacyLat = freezed,Object? pharmacyLng = freezed,Object? deliveryLat = freezed,Object? deliveryLng = freezed,Object? totalAmount = null,Object? deliveryFee = freezed,Object? commission = freezed,Object? estimatedEarnings = freezed,Object? distanceKm = freezed,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,pharmacyName: null == pharmacyName ? _self.pharmacyName : pharmacyName // ignore: cast_nullable_to_non_nullable
as String,pharmacyAddress: null == pharmacyAddress ? _self.pharmacyAddress : pharmacyAddress // ignore: cast_nullable_to_non_nullable
as String,pharmacyPhone: freezed == pharmacyPhone ? _self.pharmacyPhone : pharmacyPhone // ignore: cast_nullable_to_non_nullable
as String?,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,deliveryAddress: null == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as String,pharmacyLat: freezed == pharmacyLat ? _self.pharmacyLat : pharmacyLat // ignore: cast_nullable_to_non_nullable
as double?,pharmacyLng: freezed == pharmacyLng ? _self.pharmacyLng : pharmacyLng // ignore: cast_nullable_to_non_nullable
as double?,deliveryLat: freezed == deliveryLat ? _self.deliveryLat : deliveryLat // ignore: cast_nullable_to_non_nullable
as double?,deliveryLng: freezed == deliveryLng ? _self.deliveryLng : deliveryLng // ignore: cast_nullable_to_non_nullable
as double?,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,deliveryFee: freezed == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double?,commission: freezed == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double?,estimatedEarnings: freezed == estimatedEarnings ? _self.estimatedEarnings : estimatedEarnings // ignore: cast_nullable_to_non_nullable
as double?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Delivery].
extension DeliveryPatterns on Delivery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Delivery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Delivery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Delivery value)  $default,){
final _that = this;
switch (_that) {
case _Delivery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Delivery value)?  $default,){
final _that = this;
switch (_that) {
case _Delivery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String reference, @JsonKey(name: 'pharmacy_name')  String pharmacyName, @JsonKey(name: 'pharmacy_address')  String pharmacyAddress, @JsonKey(name: 'pharmacy_phone')  String? pharmacyPhone, @JsonKey(name: 'customer_name')  String customerName, @JsonKey(name: 'customer_phone')  String? customerPhone, @JsonKey(name: 'delivery_address')  String deliveryAddress, @JsonKey(name: 'pharmacy_latitude')  double? pharmacyLat, @JsonKey(name: 'pharmacy_longitude')  double? pharmacyLng, @JsonKey(name: 'delivery_latitude')  double? deliveryLat, @JsonKey(name: 'delivery_longitude')  double? deliveryLng, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'delivery_fee')  double? deliveryFee, @JsonKey(name: 'commission')  double? commission, @JsonKey(name: 'estimated_earnings')  double? estimatedEarnings, @JsonKey(name: 'distance_km')  double? distanceKm,  String status, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Delivery() when $default != null:
return $default(_that.id,_that.reference,_that.pharmacyName,_that.pharmacyAddress,_that.pharmacyPhone,_that.customerName,_that.customerPhone,_that.deliveryAddress,_that.pharmacyLat,_that.pharmacyLng,_that.deliveryLat,_that.deliveryLng,_that.totalAmount,_that.deliveryFee,_that.commission,_that.estimatedEarnings,_that.distanceKm,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String reference, @JsonKey(name: 'pharmacy_name')  String pharmacyName, @JsonKey(name: 'pharmacy_address')  String pharmacyAddress, @JsonKey(name: 'pharmacy_phone')  String? pharmacyPhone, @JsonKey(name: 'customer_name')  String customerName, @JsonKey(name: 'customer_phone')  String? customerPhone, @JsonKey(name: 'delivery_address')  String deliveryAddress, @JsonKey(name: 'pharmacy_latitude')  double? pharmacyLat, @JsonKey(name: 'pharmacy_longitude')  double? pharmacyLng, @JsonKey(name: 'delivery_latitude')  double? deliveryLat, @JsonKey(name: 'delivery_longitude')  double? deliveryLng, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'delivery_fee')  double? deliveryFee, @JsonKey(name: 'commission')  double? commission, @JsonKey(name: 'estimated_earnings')  double? estimatedEarnings, @JsonKey(name: 'distance_km')  double? distanceKm,  String status, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Delivery():
return $default(_that.id,_that.reference,_that.pharmacyName,_that.pharmacyAddress,_that.pharmacyPhone,_that.customerName,_that.customerPhone,_that.deliveryAddress,_that.pharmacyLat,_that.pharmacyLng,_that.deliveryLat,_that.deliveryLng,_that.totalAmount,_that.deliveryFee,_that.commission,_that.estimatedEarnings,_that.distanceKm,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String reference, @JsonKey(name: 'pharmacy_name')  String pharmacyName, @JsonKey(name: 'pharmacy_address')  String pharmacyAddress, @JsonKey(name: 'pharmacy_phone')  String? pharmacyPhone, @JsonKey(name: 'customer_name')  String customerName, @JsonKey(name: 'customer_phone')  String? customerPhone, @JsonKey(name: 'delivery_address')  String deliveryAddress, @JsonKey(name: 'pharmacy_latitude')  double? pharmacyLat, @JsonKey(name: 'pharmacy_longitude')  double? pharmacyLng, @JsonKey(name: 'delivery_latitude')  double? deliveryLat, @JsonKey(name: 'delivery_longitude')  double? deliveryLng, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'delivery_fee')  double? deliveryFee, @JsonKey(name: 'commission')  double? commission, @JsonKey(name: 'estimated_earnings')  double? estimatedEarnings, @JsonKey(name: 'distance_km')  double? distanceKm,  String status, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Delivery() when $default != null:
return $default(_that.id,_that.reference,_that.pharmacyName,_that.pharmacyAddress,_that.pharmacyPhone,_that.customerName,_that.customerPhone,_that.deliveryAddress,_that.pharmacyLat,_that.pharmacyLng,_that.deliveryLat,_that.deliveryLng,_that.totalAmount,_that.deliveryFee,_that.commission,_that.estimatedEarnings,_that.distanceKm,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Delivery implements Delivery {
  const _Delivery({required this.id, required this.reference, @JsonKey(name: 'pharmacy_name') required this.pharmacyName, @JsonKey(name: 'pharmacy_address') required this.pharmacyAddress, @JsonKey(name: 'pharmacy_phone') this.pharmacyPhone, @JsonKey(name: 'customer_name') required this.customerName, @JsonKey(name: 'customer_phone') this.customerPhone, @JsonKey(name: 'delivery_address') required this.deliveryAddress, @JsonKey(name: 'pharmacy_latitude') this.pharmacyLat, @JsonKey(name: 'pharmacy_longitude') this.pharmacyLng, @JsonKey(name: 'delivery_latitude') this.deliveryLat, @JsonKey(name: 'delivery_longitude') this.deliveryLng, @JsonKey(name: 'total_amount') required this.totalAmount, @JsonKey(name: 'delivery_fee') this.deliveryFee, @JsonKey(name: 'commission') this.commission, @JsonKey(name: 'estimated_earnings') this.estimatedEarnings, @JsonKey(name: 'distance_km') this.distanceKm, required this.status, @JsonKey(name: 'created_at') this.createdAt});
  factory _Delivery.fromJson(Map<String, dynamic> json) => _$DeliveryFromJson(json);

@override final  int id;
@override final  String reference;
@override@JsonKey(name: 'pharmacy_name') final  String pharmacyName;
@override@JsonKey(name: 'pharmacy_address') final  String pharmacyAddress;
@override@JsonKey(name: 'pharmacy_phone') final  String? pharmacyPhone;
@override@JsonKey(name: 'customer_name') final  String customerName;
@override@JsonKey(name: 'customer_phone') final  String? customerPhone;
@override@JsonKey(name: 'delivery_address') final  String deliveryAddress;
@override@JsonKey(name: 'pharmacy_latitude') final  double? pharmacyLat;
@override@JsonKey(name: 'pharmacy_longitude') final  double? pharmacyLng;
@override@JsonKey(name: 'delivery_latitude') final  double? deliveryLat;
@override@JsonKey(name: 'delivery_longitude') final  double? deliveryLng;
@override@JsonKey(name: 'total_amount') final  double totalAmount;
@override@JsonKey(name: 'delivery_fee') final  double? deliveryFee;
@override@JsonKey(name: 'commission') final  double? commission;
@override@JsonKey(name: 'estimated_earnings') final  double? estimatedEarnings;
@override@JsonKey(name: 'distance_km') final  double? distanceKm;
@override final  String status;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of Delivery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeliveryCopyWith<_Delivery> get copyWith => __$DeliveryCopyWithImpl<_Delivery>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeliveryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Delivery&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.pharmacyName, pharmacyName) || other.pharmacyName == pharmacyName)&&(identical(other.pharmacyAddress, pharmacyAddress) || other.pharmacyAddress == pharmacyAddress)&&(identical(other.pharmacyPhone, pharmacyPhone) || other.pharmacyPhone == pharmacyPhone)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.pharmacyLat, pharmacyLat) || other.pharmacyLat == pharmacyLat)&&(identical(other.pharmacyLng, pharmacyLng) || other.pharmacyLng == pharmacyLng)&&(identical(other.deliveryLat, deliveryLat) || other.deliveryLat == deliveryLat)&&(identical(other.deliveryLng, deliveryLng) || other.deliveryLng == deliveryLng)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.commission, commission) || other.commission == commission)&&(identical(other.estimatedEarnings, estimatedEarnings) || other.estimatedEarnings == estimatedEarnings)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reference,pharmacyName,pharmacyAddress,pharmacyPhone,customerName,customerPhone,deliveryAddress,pharmacyLat,pharmacyLng,deliveryLat,deliveryLng,totalAmount,deliveryFee,commission,estimatedEarnings,distanceKm,status,createdAt]);

@override
String toString() {
  return 'Delivery(id: $id, reference: $reference, pharmacyName: $pharmacyName, pharmacyAddress: $pharmacyAddress, pharmacyPhone: $pharmacyPhone, customerName: $customerName, customerPhone: $customerPhone, deliveryAddress: $deliveryAddress, pharmacyLat: $pharmacyLat, pharmacyLng: $pharmacyLng, deliveryLat: $deliveryLat, deliveryLng: $deliveryLng, totalAmount: $totalAmount, deliveryFee: $deliveryFee, commission: $commission, estimatedEarnings: $estimatedEarnings, distanceKm: $distanceKm, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DeliveryCopyWith<$Res> implements $DeliveryCopyWith<$Res> {
  factory _$DeliveryCopyWith(_Delivery value, $Res Function(_Delivery) _then) = __$DeliveryCopyWithImpl;
@override @useResult
$Res call({
 int id, String reference,@JsonKey(name: 'pharmacy_name') String pharmacyName,@JsonKey(name: 'pharmacy_address') String pharmacyAddress,@JsonKey(name: 'pharmacy_phone') String? pharmacyPhone,@JsonKey(name: 'customer_name') String customerName,@JsonKey(name: 'customer_phone') String? customerPhone,@JsonKey(name: 'delivery_address') String deliveryAddress,@JsonKey(name: 'pharmacy_latitude') double? pharmacyLat,@JsonKey(name: 'pharmacy_longitude') double? pharmacyLng,@JsonKey(name: 'delivery_latitude') double? deliveryLat,@JsonKey(name: 'delivery_longitude') double? deliveryLng,@JsonKey(name: 'total_amount') double totalAmount,@JsonKey(name: 'delivery_fee') double? deliveryFee,@JsonKey(name: 'commission') double? commission,@JsonKey(name: 'estimated_earnings') double? estimatedEarnings,@JsonKey(name: 'distance_km') double? distanceKm, String status,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$DeliveryCopyWithImpl<$Res>
    implements _$DeliveryCopyWith<$Res> {
  __$DeliveryCopyWithImpl(this._self, this._then);

  final _Delivery _self;
  final $Res Function(_Delivery) _then;

/// Create a copy of Delivery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reference = null,Object? pharmacyName = null,Object? pharmacyAddress = null,Object? pharmacyPhone = freezed,Object? customerName = null,Object? customerPhone = freezed,Object? deliveryAddress = null,Object? pharmacyLat = freezed,Object? pharmacyLng = freezed,Object? deliveryLat = freezed,Object? deliveryLng = freezed,Object? totalAmount = null,Object? deliveryFee = freezed,Object? commission = freezed,Object? estimatedEarnings = freezed,Object? distanceKm = freezed,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_Delivery(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,pharmacyName: null == pharmacyName ? _self.pharmacyName : pharmacyName // ignore: cast_nullable_to_non_nullable
as String,pharmacyAddress: null == pharmacyAddress ? _self.pharmacyAddress : pharmacyAddress // ignore: cast_nullable_to_non_nullable
as String,pharmacyPhone: freezed == pharmacyPhone ? _self.pharmacyPhone : pharmacyPhone // ignore: cast_nullable_to_non_nullable
as String?,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,deliveryAddress: null == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as String,pharmacyLat: freezed == pharmacyLat ? _self.pharmacyLat : pharmacyLat // ignore: cast_nullable_to_non_nullable
as double?,pharmacyLng: freezed == pharmacyLng ? _self.pharmacyLng : pharmacyLng // ignore: cast_nullable_to_non_nullable
as double?,deliveryLat: freezed == deliveryLat ? _self.deliveryLat : deliveryLat // ignore: cast_nullable_to_non_nullable
as double?,deliveryLng: freezed == deliveryLng ? _self.deliveryLng : deliveryLng // ignore: cast_nullable_to_non_nullable
as double?,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,deliveryFee: freezed == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double?,commission: freezed == commission ? _self.commission : commission // ignore: cast_nullable_to_non_nullable
as double?,estimatedEarnings: freezed == estimatedEarnings ? _self.estimatedEarnings : estimatedEarnings // ignore: cast_nullable_to_non_nullable
as double?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
