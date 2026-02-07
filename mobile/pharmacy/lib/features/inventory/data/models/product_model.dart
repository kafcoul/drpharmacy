import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product_entity.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  @JsonKey(name: 'stock_quantity')
  final int stockQuantity;
  @JsonKey(name: 'image')
  final String? imageUrl;
  final String category;
  final String? barcode;
  @JsonKey(name: 'requires_prescription')
  final bool requiresPrescription;
  @JsonKey(name: 'is_available')
  final bool isAvailable;

  final String? brand;
  final String? manufacturer;
  @JsonKey(name: 'active_ingredient')
  final String? activeIngredient;
  final String? unit;
  @JsonKey(name: 'expiry_date')
  final DateTime? expiryDate;
  @JsonKey(name: 'usage_instructions')
  final String? usageInstructions;
  @JsonKey(name: 'side_effects')
  final String? sideEffects;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    this.imageUrl,
    required this.category,
    this.barcode,
    required this.requiresPrescription,
    required this.isAvailable,
    this.brand,
    this.manufacturer,
    this.activeIngredient,
    this.unit,
    this.expiryDate,
    this.usageInstructions,
    this.sideEffects,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle String -> double conversion manually to be robust
    if (json['price'] is String) {
      json = Map<String, dynamic>.from(json); // Create mutable copy
      json['price'] = double.tryParse(json['price']) ?? 0.0;
    }
    if (json['stock_quantity'] is String) {
      json = Map<String, dynamic>.from(json);
      json['stock_quantity'] = int.tryParse(json['stock_quantity']) ?? 0;
    }
    // Handle Null description being passed as String expectation
    if (json['description'] == null) {
       json = Map<String, dynamic>.from(json);
       json['description'] = '';
    }
    // Handle Null category being passed as String expectation
    if (json['category'] == null) {
       json = Map<String, dynamic>.from(json);
       // Try lookup via relationship or fallback
       json['category'] = 'Non classé';
    } else if (json['category'] is Map) {
       // If category is returned as an object (JsonMap) because of serialization
       json = Map<String, dynamic>.from(json);
       json['category'] = json['category']['name'] ?? 'Non classé';
    }

    if (json['expiry_date'] == "") {
      json['expiry_date'] = null;
    }

    return _$ProductModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      stockQuantity: stockQuantity,
      imageUrl: imageUrl,
      category: category,
      barcode: barcode,
      requiresPrescription: requiresPrescription,
      isAvailable: isAvailable,
      brand: brand,
      manufacturer: manufacturer,
      activeIngredient: activeIngredient,
      unit: unit,
      expiryDate: expiryDate,
      usageInstructions: usageInstructions,
      sideEffects: sideEffects,
    );
  }
}
