class ProductEntity {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String? imageUrl;
  final String category;
  final String? barcode;
  final bool requiresPrescription;
  final bool isAvailable;
  
  // New fields
  final String? brand;
  final String? manufacturer;
  final String? activeIngredient;
  final String? unit;
  final DateTime? expiryDate;
  final String? usageInstructions;
  final String? sideEffects;

  const ProductEntity({
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

  ProductEntity copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    String? imageUrl,
    String? category,
    String? barcode,
    bool? requiresPrescription,
    bool? isAvailable,
    String? brand,
    String? manufacturer,
    String? activeIngredient,
    String? unit,
    DateTime? expiryDate,
    String? usageInstructions,
    String? sideEffects,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      requiresPrescription: requiresPrescription ?? this.requiresPrescription,
      isAvailable: isAvailable ?? this.isAvailable,
      brand: brand ?? this.brand,
      manufacturer: manufacturer ?? this.manufacturer,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      usageInstructions: usageInstructions ?? this.usageInstructions,
      sideEffects: sideEffects ?? this.sideEffects,
    );
  }

  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 5;

  bool get isOutOfStock => stockQuantity == 0;
}
