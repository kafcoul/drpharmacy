import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart';
import 'products_notifier.dart';
import 'products_state.dart';

final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>(
  (ref) {
    final getProductsUseCase = ref.watch(getProductsUseCaseProvider);
    final searchProductsUseCase = ref.watch(searchProductsUseCaseProvider);
    final getProductDetailsUseCase = ref.watch(
      getProductDetailsUseCaseProvider,
    );
    final getProductsByCategoryUseCase = ref.watch(
      getProductsByCategoryUseCaseProvider,
    );

    return ProductsNotifier(
      getProductsUseCase: getProductsUseCase,
      searchProductsUseCase: searchProductsUseCase,
      getProductDetailsUseCase: getProductDetailsUseCase,
      getProductsByCategoryUseCase: getProductsByCategoryUseCase,
    );
  },
);
