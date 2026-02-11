import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/error_handler.dart';
import '../models/courier_profile.dart';
import '../models/delivery.dart';
import '../models/chat_message.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepository(ref.read(dioProvider));
});

class DeliveryRepository {
  final Dio _dio;

  DeliveryRepository(this._dio);

  Future<List<Delivery>> getDeliveries({String status = 'pending'}) async {
    try {
      final response = await _dio.get(
        ApiConstants.deliveries,
        queryParameters: {'status': status},
      );

      final data = response.data['data'] as List;
      return data.map((e) => Delivery.fromJson(e)).toList();
    } catch (e) {
      throw Exception(ErrorHandler.getDeliveryErrorMessage(e));
    }
  }

  Future<void> acceptDelivery(int id) async {
    try {
      await _dio.post(ApiConstants.acceptDelivery(id));
    } catch (e) {
      throw Exception(ErrorHandler.getDeliveryErrorMessage(e));
    }
  }

  Future<void> pickupDelivery(int id) async {
    try {
      await _dio.post(ApiConstants.pickupDelivery(id));
    } catch (e) {
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'];
        
        if (statusCode == 400) {
          throw Exception(message ?? 'Cette livraison ne peut pas être récupérée actuellement.');
        } else if (statusCode == 403) {
          throw Exception(message ?? 'Vous n\'êtes pas autorisé à récupérer cette livraison.');
        } else if (statusCode == 404) {
          throw Exception('Livraison introuvable.');
        }
      }
      throw Exception('Impossible de confirmer la récupération. Vérifiez votre connexion.');
    }
  }

  Future<void> completeDelivery(int id, String code) async {
    try {
      await _dio.post(
        ApiConstants.completeDelivery(id),
        data: {'confirmation_code': code},
      );
    } catch (e) {
      throw Exception(ErrorHandler.getDeliveryErrorMessage(e));
    }
  }

  /// Toggle ou définit la disponibilité du coursier
  /// [desiredStatus] : 'available' pour en ligne, 'offline' pour hors ligne
  /// Si null, fait un toggle basé sur l'état actuel du serveur
  Future<bool> toggleAvailability({String? desiredStatus}) async {
    try {
      final response = await _dio.post(
        ApiConstants.availability,
        data: desiredStatus != null ? {'status': desiredStatus} : null,
      );
      return response.data['data']['status'] == 'available';
    } catch (e) {
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'];
        final errorCode = e.response?.data?['error_code'];
        
        if (statusCode == 403) {
          if (errorCode == 'COURIER_PROFILE_NOT_FOUND') {
            throw Exception('Votre compte n\'est pas configuré comme coursier. Veuillez vous déconnecter et utiliser un compte coursier.');
          }
          throw Exception(message ?? 'Accès refusé. Veuillez vous reconnecter.');
        } else if (statusCode == 401) {
          throw Exception('Session expirée. Veuillez vous reconnecter.');
        }
      }
      throw Exception('Impossible de changer le statut. Vérifiez votre connexion.');
    }
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    try {
      await _dio.post(
        ApiConstants.location,
        data: {'latitude': latitude, 'longitude': longitude},
      );
    } catch (e) {
      throw Exception(ErrorHandler.getReadableMessage(e, defaultMessage: 'Impossible de mettre à jour la position.'));
    }
  }

  Future<CourierProfile> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      return CourierProfile.fromJson(response.data['data']);
    } catch (e) {
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'];
        final errorCode = e.response?.data?['error_code'];
        
        if (statusCode == 403) {
          if (errorCode == 'COURIER_PROFILE_NOT_FOUND') {
            throw Exception('Profil coursier non trouvé. Ce compte n\'est pas un compte livreur.');
          }
          throw Exception(message ?? 'Accès refusé.');
        } else if (statusCode == 401) {
          throw Exception('Session expirée. Veuillez vous reconnecter.');
        }
      }
      throw Exception('Impossible de charger le profil.');
    }
  }

  Future<List<ChatMessage>> getMessages(int orderId, String target) async {
    try {
      final response = await _dio.get(
        ApiConstants.messages(orderId),
        queryParameters: {'is_courier': 1, 'target': target},
      );
      final data = response.data['data'] as List;
      return data.map((e) => ChatMessage.fromJson(e)).toList();
    } catch (e) {
      throw Exception(ErrorHandler.getChatErrorMessage(e));
    }
  }

  Future<ChatMessage> sendMessage(int orderId, String content, String target) async {
    try {
      final response = await _dio.post(
        ApiConstants.messages(orderId),
        data: {
          'content': content, 
          'target': target
        },
      );
      return ChatMessage.fromJson(response.data['data']);
    } catch (e) {
      throw Exception(ErrorHandler.getChatErrorMessage(e));
    }
  }

  /// Accepter plusieurs livraisons en batch (max 5)
  Future<Map<String, dynamic>> batchAcceptDeliveries(List<int> deliveryIds) async {
    try {
      final response = await _dio.post(
        ApiConstants.batchAcceptDeliveries,
        data: {'delivery_ids': deliveryIds},
      );
      return response.data['data'];
    } catch (e) {
      throw Exception(ErrorHandler.getDeliveryErrorMessage(e));
    }
  }

  /// Récupérer l'itinéraire optimisé pour les livraisons actives
  Future<Map<String, dynamic>> getOptimizedRoute() async {
    try {
      final response = await _dio.get(ApiConstants.deliveriesRoute);
      return response.data['data'];
    } catch (e) {
      throw Exception(ErrorHandler.getReadableMessage(e, defaultMessage: 'Impossible de calculer l\'itinéraire.'));
    }
  }

  /// Noter un client après une livraison
  Future<void> rateCustomer({
    required int deliveryId,
    required int rating,
    String? comment,
    List<String>? tags,
  }) async {
    try {
      await _dio.post(
        '/courier/deliveries/$deliveryId/rate-customer',
        data: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
          if (tags != null && tags.isNotEmpty) 'tags': tags,
        },
      );
    } catch (e) {
      throw Exception(ErrorHandler.getReadableMessage(e, defaultMessage: 'Impossible d\'enregistrer la notation.'));
    }
  }

  Future<void> rejectDelivery(int id) async {
    try {
      await _dio.post('/courier/deliveries/$id/reject');
    } catch (e) {
      throw Exception(ErrorHandler.getDeliveryErrorMessage(e));
    }
  }
}
