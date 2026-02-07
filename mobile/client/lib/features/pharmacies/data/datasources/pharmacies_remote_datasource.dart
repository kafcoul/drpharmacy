import '../../../../core/network/api_client.dart';
import '../models/pharmacy_model.dart';

abstract class PharmaciesRemoteDataSource {
  Future<List<PharmacyModel>> getPharmacies({
    int page = 1,
    int perPage = 20,
  });

  Future<List<PharmacyModel>> getNearbyPharmacies({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  });

  Future<List<PharmacyModel>> getOnDutyPharmacies({
    double? latitude,
    double? longitude,
    double? radius,
  });

  Future<List<PharmacyModel>> getFeaturedPharmacies();

  Future<PharmacyModel> getPharmacyDetails(int id);
}

class PharmaciesRemoteDataSourceImpl implements PharmaciesRemoteDataSource {
  final ApiClient apiClient;

  PharmaciesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PharmacyModel>> getPharmacies({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await apiClient.get(
      '/customer/pharmacies',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );

    final data = response.data['data'] as List;
    return data.map((json) => PharmacyModel.fromJson(json)).toList();
  }

  @override
  Future<List<PharmacyModel>> getNearbyPharmacies({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  }) async {
    final response = await apiClient.get(
      '/customer/pharmacies/nearby',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      },
    );

    final data = response.data['data'] as List;
    return data.map((json) => PharmacyModel.fromJson(json)).toList();
  }

  @override
  Future<List<PharmacyModel>> getOnDutyPharmacies({
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (latitude != null) queryParams['latitude'] = latitude;
    if (longitude != null) queryParams['longitude'] = longitude;
    if (radius != null) queryParams['radius'] = radius;

    final response = await apiClient.get(
      '/customer/pharmacies/on-duty',
      queryParameters: queryParams,
    );

    final data = response.data['data'] as List;
    return data.map((json) => PharmacyModel.fromJson(json)).toList();
  }

  @override
  Future<PharmacyModel> getPharmacyDetails(int id) async {
    final response = await apiClient.get('/customer/pharmacies/$id');

    return PharmacyModel.fromJson(response.data['data']);
  }

  @override
  Future<List<PharmacyModel>> getFeaturedPharmacies() async {
    final response = await apiClient.get('/customer/pharmacies/featured');

    final data = response.data['data'] as List;
    return data.map((json) => PharmacyModel.fromJson(json)).toList();
  }
}
