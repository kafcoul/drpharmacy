import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(Map<String, dynamic> profileData);
  Future<String> uploadAvatar(Uint8List imageBytes);
  Future<void> deleteAvatar();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ProfileModel> getProfile() async {
    final response = await apiClient.get(ApiConstants.profile);
    return ProfileModel.fromJson(response.data['data']);
  }

  @override
  Future<ProfileModel> updateProfile(Map<String, dynamic> profileData) async {
    final response = await apiClient.post(
      ApiConstants.updateProfile,
      data: profileData,
    );
    return ProfileModel.fromJson(response.data['data']);
  }

  @override
  Future<String> uploadAvatar(Uint8List imageBytes) async {
    // Create FormData with the image
    final formData = FormData.fromMap({
      'avatar': MultipartFile.fromBytes(
        imageBytes,
        filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    });

    final response = await apiClient.uploadMultipart(
      ApiConstants.uploadAvatar,
      formData: formData,
    );

    // Return the avatar URL from response
    return response.data['data']['avatar_url'] as String;
  }

  @override
  Future<void> deleteAvatar() async {
    await apiClient.delete(ApiConstants.deleteAvatar);
  }
}
