import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/data/models/pharmacy_model.dart';

abstract class ProfileRemoteDataSource {
  Future<PharmacyModel> updatePharmacy(int id, dynamic data);
  Future<void> updateProfile(Map<String, dynamic> data);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _client;

  ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<PharmacyModel> updatePharmacy(int id, dynamic data) async {
    final response = await _client.post(
      '/pharmacy/profile/$id',
      data: data,
    );
    // Depending on backend, it might return the updated pharmacy directly or wrapped
    // My backend controller returns: { success: true, message: '...', data: pharmacy }
    return PharmacyModel.fromJson(response.data['data']);
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _client.post(
      '/auth/me/update',
      data: data,
    );
  }
}

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRemoteDataSourceImpl(apiClient);
});
