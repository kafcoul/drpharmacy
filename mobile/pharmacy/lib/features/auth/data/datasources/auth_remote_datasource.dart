import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String name,
    required String pName, // pharmacy name
    required String email,
    required String phone,
    required String password,
    required String licenseNumber,
    required String city,
    required String address,
  });

  Future<void> logout(String token);

  Future<UserModel> getCurrentUser(String token);

  Future<void> forgotPassword({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    // Normaliser l'email en minuscules pour éviter les problèmes de case sensitivity
    final normalizedEmail = email.toLowerCase().trim();
    
    debugPrint('🌐 [AuthRemoteDataSource] login() - email: $normalizedEmail');
    debugPrint('🌐 [AuthRemoteDataSource] Envoi requête POST vers /auth/login...');
    
    final response = await apiClient.post(
      '/auth/login', // Adjust endpoint if needed
      data: {
        'email': normalizedEmail,
        'password': password,
        'device_name': 'pharmacy-app',
        'role':
            'pharmacy', // Assuming backend filters or validates role if sent
      },
    );
    
    debugPrint('🌐 [AuthRemoteDataSource] Réponse reçue - status: ${response.statusCode}');
    debugPrint('🌐 [AuthRemoteDataSource] Données: ${response.data}');

    return AuthResponseModel.fromJson(response.data['data']);
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String pName,
    required String email,
    required String phone,
    required String password,
    required String licenseNumber,
    required String city,
    required String address,
  }) async {
    // Normaliser l'email en minuscules pour éviter les problèmes de case sensitivity
    final normalizedEmail = email.toLowerCase().trim();
    
    final response = await apiClient.post(
      '/auth/register/pharmacy',
      data: {
        'name': name,
        'pharmacy_name': pName,
        'pharmacy_license': licenseNumber,
        'pharmacy_address': address,
        'city': city,
        'email': normalizedEmail,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        'role': 'pharmacy',
      },
    );

    return AuthResponseModel.fromJson(response.data['data']);
  }

  @override
  Future<void> logout(String token) async {
    await apiClient.post(
      '/auth/logout',
      options: apiClient.authorizedOptions(token),
    );
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    final response = await apiClient.get(
      '/auth/me',
      options: apiClient.authorizedOptions(token),
    );

    return UserModel.fromJson(response.data['data']);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await apiClient.post(
      '/auth/forgot-password',
      data: {'email': email.toLowerCase().trim()},
    );
  }
}
