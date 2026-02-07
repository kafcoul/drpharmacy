import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/inventory_remote_datasource.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/repositories/inventory_repository.dart';

final inventoryRemoteDataSourceProvider = Provider<InventoryRemoteDataSource>((ref) {
  return InventoryRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
  );
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(
    remoteDataSource: ref.watch(inventoryRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});
