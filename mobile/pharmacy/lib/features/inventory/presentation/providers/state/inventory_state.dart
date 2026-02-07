import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/category_entity.dart';

enum InventoryStatus { initial, loading, loaded, error }

class InventoryState {
  final InventoryStatus status;
  final List<ProductEntity> products;
  final String? errorMessage;
  final String searchQuery;
  final List<CategoryEntity> categories;

  const InventoryState({
    this.status = InventoryStatus.initial,
    this.products = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.categories = const [],
  });

  InventoryState copyWith({
    InventoryStatus? status,
    List<ProductEntity>? products,
    String? errorMessage,
    String? searchQuery,
    List<CategoryEntity>? categories,
  }) {
    return InventoryState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      categories: categories ?? this.categories,
    );
  }
}
