import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/domain/usecases/update_password_usecase.dart';
import '../features/products/data/datasources/products_local_datasource.dart';
import '../features/products/data/datasources/products_remote_datasource.dart';
import '../features/products/data/repositories/products_repository_impl.dart';
import '../features/products/domain/repositories/products_repository.dart';
import '../features/products/domain/usecases/get_product_details_usecase.dart';
import '../features/products/domain/usecases/get_products_usecase.dart';
import '../features/products/domain/usecases/search_products_usecase.dart';
import '../features/products/domain/usecases/get_products_by_category_usecase.dart';
import '../features/orders/data/datasources/orders_local_datasource.dart';
import '../features/orders/data/datasources/orders_remote_datasource.dart';
import '../features/orders/data/repositories/orders_repository_impl.dart';
import '../features/orders/domain/repositories/orders_repository.dart';
import '../features/orders/domain/usecases/get_orders_usecase.dart';
import '../features/orders/domain/usecases/get_order_details_usecase.dart';
import '../features/orders/domain/usecases/create_order_usecase.dart';
import '../features/orders/domain/usecases/cancel_order_usecase.dart';
import '../features/orders/domain/usecases/initiate_payment_usecase.dart';
import '../features/profile/data/datasources/profile_local_datasource.dart';
import '../features/profile/data/datasources/profile_remote_datasource.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/domain/usecases/get_profile_usecase.dart';
import '../features/profile/domain/usecases/update_profile_usecase.dart';
import '../features/profile/domain/usecases/upload_avatar_usecase.dart';
import '../features/profile/domain/usecases/delete_avatar_usecase.dart';
import '../features/pharmacies/data/datasources/pharmacies_remote_datasource.dart';
import '../features/pharmacies/data/repositories/pharmacies_repository_impl.dart';
import '../features/pharmacies/domain/repositories/pharmacies_repository.dart';
import '../features/pharmacies/domain/usecases/get_pharmacies_usecase.dart';
import '../features/pharmacies/domain/usecases/get_nearby_pharmacies_usecase.dart';
import '../features/pharmacies/domain/usecases/get_pharmacy_details_usecase.dart';
import '../features/pharmacies/domain/usecases/get_on_duty_pharmacies_usecase.dart';
import '../features/pharmacies/domain/usecases/get_featured_pharmacies_usecase.dart';
import '../features/pharmacies/presentation/providers/pharmacies_notifier.dart';
import '../features/pharmacies/presentation/providers/pharmacies_state.dart';
import '../core/services/notification_service.dart';

// Core Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

// Singleton ApiClient instance to ensure token is shared across all services
final _apiClientInstance = ApiClient();

final apiClientProvider = Provider<ApiClient>((ref) {
  return _apiClientInstance;
});

// Data Source Providers
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return AuthLocalDataSourceImpl(sharedPreferences: sharedPreferences);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient: apiClient);
});

// Repository Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    apiClient: apiClient,
  );
});

// Use Case Providers
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final updatePasswordUseCaseProvider = Provider<UpdatePasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return UpdatePasswordUseCase(repository);
});

// Auth Status Provider
final authStatusProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.isLoggedIn();
});

// ============================================================================
// PRODUCTS PROVIDERS
// ============================================================================

// Data Source Providers
final productsLocalDataSourceProvider = Provider<ProductsLocalDataSource>((
  ref,
) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return ProductsLocalDataSourceImpl(sharedPreferences: sharedPreferences);
});

final productsRemoteDataSourceProvider = Provider<ProductsRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductsRemoteDataSourceImpl(apiClient: apiClient);
});

// Repository Provider
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final localDataSource = ref.watch(productsLocalDataSourceProvider);
  final remoteDataSource = ref.watch(productsRemoteDataSourceProvider);
  return ProductsRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
});

// Use Case Providers
final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  final repository = ref.watch(productsRepositoryProvider);
  return GetProductsUseCase(repository);
});

final searchProductsUseCaseProvider = Provider<SearchProductsUseCase>((ref) {
  final repository = ref.watch(productsRepositoryProvider);
  return SearchProductsUseCase(repository);
});

final getProductDetailsUseCaseProvider = Provider<GetProductDetailsUseCase>((
  ref,
) {
  final repository = ref.watch(productsRepositoryProvider);
  return GetProductDetailsUseCase(repository);
});

final getProductsByCategoryUseCaseProvider =
    Provider<GetProductsByCategoryUseCase>((ref) {
      final repository = ref.watch(productsRepositoryProvider);
      return GetProductsByCategoryUseCase(repository);
    });

// ============================================================================
// ORDERS PROVIDERS
// ============================================================================

// Data Source Providers
final ordersLocalDataSourceProvider = Provider<OrdersLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return OrdersLocalDataSource(sharedPreferences);
});

final ordersRemoteDataSourceProvider = Provider<OrdersRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OrdersRemoteDataSource(apiClient);
});

// Repository Provider
final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final localDataSource = ref.watch(ordersLocalDataSourceProvider);
  final remoteDataSource = ref.watch(ordersRemoteDataSourceProvider);
  return OrdersRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
  );
});

// Use Case Providers
final getOrdersUseCaseProvider = Provider<GetOrdersUseCase>((ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return GetOrdersUseCase(repository);
});

final getOrderDetailsUseCaseProvider = Provider<GetOrderDetailsUseCase>((ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return GetOrderDetailsUseCase(repository);
});

final createOrderUseCaseProvider = Provider<CreateOrderUseCase>((ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return CreateOrderUseCase(repository);
});

final cancelOrderUseCaseProvider = Provider<CancelOrderUseCase>((ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return CancelOrderUseCase(repository);
});

final initiatePaymentUseCaseProvider = Provider<InitiatePaymentUseCase>((ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return InitiatePaymentUseCase(repository);
});

// Profile Providers
final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return ProfileLocalDataSourceImpl(sharedPreferences: sharedPreferences);
});

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRemoteDataSourceImpl(apiClient: apiClient);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  final localDataSource = ref.watch(profileLocalDataSourceProvider);
  return ProfileRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetProfileUseCase(repository: repository);
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UpdateProfileUseCase(repository: repository);
});

final uploadAvatarUseCaseProvider = Provider<UploadAvatarUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UploadAvatarUseCase(repository: repository);
});

final deleteAvatarUseCaseProvider = Provider<DeleteAvatarUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return DeleteAvatarUseCase(repository: repository);
});

// ============================================================================
// PHARMACIES PROVIDERS
// ============================================================================

final pharmaciesRemoteDataSourceProvider = Provider<PharmaciesRemoteDataSource>(
  (ref) {
    final apiClient = ref.watch(apiClientProvider);
    return PharmaciesRemoteDataSourceImpl(apiClient: apiClient);
  },
);

final pharmaciesRepositoryProvider = Provider<PharmaciesRepository>((ref) {
  final remoteDataSource = ref.watch(pharmaciesRemoteDataSourceProvider);
  return PharmaciesRepositoryImpl(remoteDataSource: remoteDataSource);
});

final getPharmaciesUseCaseProvider = Provider<GetPharmaciesUseCase>((ref) {
  final repository = ref.watch(pharmaciesRepositoryProvider);
  return GetPharmaciesUseCase(repository);
});

final getNearbyPharmaciesUseCaseProvider = Provider<GetNearbyPharmaciesUseCase>(
  (ref) {
    final repository = ref.watch(pharmaciesRepositoryProvider);
    return GetNearbyPharmaciesUseCase(repository);
  },
);

final getPharmacyDetailsUseCaseProvider = Provider<GetPharmacyDetailsUseCase>((
  ref,
) {
  final repository = ref.watch(pharmaciesRepositoryProvider);
  return GetPharmacyDetailsUseCase(repository);
});

final getOnDutyPharmaciesUseCaseProvider = Provider<GetOnDutyPharmaciesUseCase>((
  ref,
) {
  final repository = ref.watch(pharmaciesRepositoryProvider);
  return GetOnDutyPharmaciesUseCase(repository);
});

final getFeaturedPharmaciesUseCaseProvider = Provider<GetFeaturedPharmaciesUseCase>((
  ref,
) {
  final repository = ref.watch(pharmaciesRepositoryProvider);
  return GetFeaturedPharmaciesUseCase(repository);
});

final pharmaciesProvider =
    StateNotifierProvider<PharmaciesNotifier, PharmaciesState>((ref) {
      final getPharmaciesUseCase = ref.watch(getPharmaciesUseCaseProvider);
      final getNearbyPharmaciesUseCase = ref.watch(
        getNearbyPharmaciesUseCaseProvider,
      );
      final getOnDutyPharmaciesUseCase = ref.watch(getOnDutyPharmaciesUseCaseProvider);
      final getPharmacyDetailsUseCase = ref.watch(
        getPharmacyDetailsUseCaseProvider,
      );
      final getFeaturedPharmaciesUseCase = ref.watch(
        getFeaturedPharmaciesUseCaseProvider,
      );

      return PharmaciesNotifier(
        getPharmaciesUseCase: getPharmaciesUseCase,
        getNearbyPharmaciesUseCase: getNearbyPharmaciesUseCase,
        getOnDutyPharmaciesUseCase: getOnDutyPharmaciesUseCase,
        getPharmacyDetailsUseCase: getPharmacyDetailsUseCase,
        getFeaturedPharmaciesUseCase: getFeaturedPharmaciesUseCase,
      );
    });

// Service Providers
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationService(apiClient);
});
