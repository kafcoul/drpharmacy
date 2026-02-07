import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider));
});

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Clés pour le stockage sécurisé
  static const String _credentialsKey = 'biometric_credentials';

  AuthRepository(this._dio);

  Future<User> login(String email, String password) async {
    try {
      // Normaliser l'email en minuscules pour éviter les problèmes de case sensitivity
      final normalizedEmail = email.toLowerCase().trim();
      
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': normalizedEmail,
          'password': password,
          'role': 'courier', // Indiquer que c'est l'app coursier
          'device_name': 'courier-app',
        },
      );

      // Handle wrapped response structure: { success: true, data: { token: ..., user: ... } }
      final responseData = response.data;
      final data = responseData['data'];
      
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      
      // Stocker les credentials de manière sécurisée pour la biométrie (email normalisé)
      await _storeCredentials(normalizedEmail, password);

      return User.fromJson(data['user']);
    } on DioException catch (e) {
      // Gérer les erreurs de validation Laravel (422)
      if (e.response?.statusCode == 422) {
        final data = e.response?.data;
        if (data is Map) {
          // Erreur de validation Laravel
          if (data.containsKey('message')) {
            throw Exception(data['message']);
          }
          if (data.containsKey('errors')) {
            final errors = data['errors'] as Map;
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              throw Exception(firstError.first);
            }
          }
        }
        throw Exception('Identifiants incorrects');
      }
      // Erreur réseau ou serveur
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connexion au serveur impossible. Vérifiez votre connexion internet.');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Email ou mot de passe incorrect');
      }
      if (e.response?.statusCode == 500) {
        throw Exception('Erreur serveur. Réessayez plus tard.');
      }
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
  
  /// Stocker les credentials de manière sécurisée
  Future<void> _storeCredentials(String email, String password) async {
    final credentials = jsonEncode({
      'email': email,
      'password': password,
    });
    await _secureStorage.write(key: _credentialsKey, value: credentials);
  }
  
  /// Vérifier si des credentials sont stockés
  Future<bool> hasStoredCredentials() async {
    final credentials = await _secureStorage.read(key: _credentialsKey);
    return credentials != null;
  }
  
  /// Connexion avec les credentials stockés (pour biométrie)
  Future<User> loginWithStoredCredentials() async {
    final credentialsJson = await _secureStorage.read(key: _credentialsKey);
    if (credentialsJson == null) {
      throw Exception('Aucun credential stocké');
    }
    
    final credentials = jsonDecode(credentialsJson);
    return login(credentials['email'], credentials['password']);
  }
  
  /// Supprimer les credentials stockés
  Future<void> clearStoredCredentials() async {
    await _secureStorage.delete(key: _credentialsKey);
  }

  /// Inscription d'un nouveau coursier avec documents KYC (recto/verso)
  Future<User> registerCourier({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String vehicleType,
    required String vehicleRegistration,
    String? licenseNumber,
    File? idCardFrontImage,      // CNI Recto
    File? idCardBackImage,       // CNI Verso
    File? selfieImage,
    File? drivingLicenseFrontImage,  // Permis Recto
    File? drivingLicenseBackImage,   // Permis Verso
  }) async {
    try {
      // Normaliser l'email en minuscules pour éviter les problèmes de case sensitivity
      final normalizedEmail = email.toLowerCase().trim();
      
      // Créer le FormData pour l'upload multipart
      final formData = FormData.fromMap({
        'name': name,
        'email': normalizedEmail,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        'vehicle_type': vehicleType,
        'vehicle_registration': vehicleRegistration,
        if (licenseNumber != null && licenseNumber.isNotEmpty)
          'license_number': licenseNumber,
        // CNI Recto
        if (idCardFrontImage != null)
          'id_card_front_document': await MultipartFile.fromFile(
            idCardFrontImage.path,
            filename: 'id_card_front_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        // CNI Verso
        if (idCardBackImage != null)
          'id_card_back_document': await MultipartFile.fromFile(
            idCardBackImage.path,
            filename: 'id_card_back_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        // Selfie
        if (selfieImage != null)
          'selfie_document': await MultipartFile.fromFile(
            selfieImage.path,
            filename: 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        // Permis Recto
        if (drivingLicenseFrontImage != null)
          'driving_license_front_document': await MultipartFile.fromFile(
            drivingLicenseFrontImage.path,
            filename: 'license_front_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        // Permis Verso
        if (drivingLicenseBackImage != null)
          'driving_license_back_document': await MultipartFile.fromFile(
            drivingLicenseBackImage.path,
            filename: 'license_back_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
      });

      final response = await _dio.post(
        ApiConstants.registerCourier,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final responseData = response.data;
      
      if (responseData['success'] != true) {
        throw Exception(responseData['message'] ?? 'Inscription échouée');
      }

      final data = responseData['data'];
      
      // NE PAS stocker de token pour les coursiers en attente d'approbation
      // Le coursier doit attendre l'approbation admin avant de pouvoir se connecter
      // Le token sera créé uniquement lors de la connexion après approbation

      return User.fromJson(data['user']);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          if (data.containsKey('message')) {
            throw Exception(data['message']);
          }
          if (data.containsKey('errors')) {
            final errors = data['errors'] as Map;
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              throw Exception(firstError.first);
            }
          }
        }
      }
      throw Exception('Inscription échouée: ${e.message}');
    } catch (e) {
      throw Exception('Inscription échouée: $e');
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      final responseData = response.data;
      final data = responseData['data'];
      
      // Vérifier le statut du coursier
      if (data['courier'] != null) {
        final courierStatus = data['courier']['status'];
        if (courierStatus == 'pending_approval') {
          // Supprimer le token stocké car le coursier n'est pas encore approuvé
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
          throw Exception('PENDING_APPROVAL:Votre compte est en attente d\'approbation par l\'administrateur.');
        }
        if (courierStatus == 'suspended') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
          throw Exception('SUSPENDED:Votre compte a été suspendu. Veuillez contacter le support.');
        }
        if (courierStatus == 'rejected') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
          throw Exception('REJECTED:Votre demande d\'inscription a été refusée.');
        }
      }
      
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  /// Mettre à jour le profil utilisateur (nom, téléphone, etc.)
  Future<User> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null && name.isNotEmpty) data['name'] = name;
      if (phone != null && phone.isNotEmpty) data['phone'] = phone;
      
      if (data.isEmpty) {
        throw Exception('Aucune donnée à mettre à jour');
      }
      
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/auth/me/update',
        data: data,
      );
      
      // Handle wrapped response structure
      final responseData = response.data;
      final userData = responseData['data'] ?? responseData;
      
      return User.fromJson(userData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
        if (data is Map && data.containsKey('errors')) {
          final errors = data['errors'] as Map;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first);
          }
        }
      }
      throw Exception('Erreur lors de la mise à jour: ${e.message}');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (e) {
      // Ignore network errors on logout
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      // Ne pas effacer les credentials biométriques pour permettre reconnexion rapide
      // Pour les effacer complètement: await clearStoredCredentials();
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      await _dio.post(ApiConstants.updatePassword, data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      });
    } catch (e) {
      // Extract specific message if possible (Laravel validation errors)
      if (e is DioException && e.response?.data != null) {
         final data = e.response?.data;
         if (data is Map && data.containsKey('message')) {
            throw Exception(data['message']);
         }
      }
      throw Exception('Failed to update password: $e');
    }
  }
}
