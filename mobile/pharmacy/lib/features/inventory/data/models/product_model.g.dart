// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  stockQuantity: (json['stock_quantity'] as num).toInt(),
  imageUrl: json['image'] as String?,
  category: json['category'] as String,
  barcode: json['barcode'] as String?,
  requiresPrescription: json['requires_prescription'] as bool,
  isAvailable: json['is_available'] as bool,
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'stock_quantity': instance.stockQuantity,
      'image': instance.imageUrl,
      'category': instance.category,
      'barcode': instance.barcode,
      'requires_prescription': instance.requiresPrescription,
      'is_available': instance.isAvailable,
    };
