import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/error_handler.dart';

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository(ref.read(dioProvider));
});

class ChallengeRepository {
  final Dio _dio;

  ChallengeRepository(this._dio);

  /// Récupérer les challenges et bonus actifs
  Future<Map<String, dynamic>> getChallenges() async {
    try {
      final response = await _dio.get(ApiConstants.challenges);
      return response.data['data'];
    } catch (e) {
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'];
        
        if (statusCode == 403 || statusCode == 404) {
          throw Exception(message ?? 'Profil coursier non trouvé. Veuillez vous connecter avec un compte livreur.');
        } else if (statusCode == 401) {
          throw Exception('Session expirée. Veuillez vous reconnecter.');
        } else if (message != null) {
          throw Exception(message);
        }
      }
      throw Exception('Impossible de charger les défis. Vérifiez votre connexion.');
    }
  }

  /// Réclamer la récompense d'un défi complété
  Future<Map<String, dynamic>> claimReward(int challengeId) async {
    try {
      final response = await _dio.post('${ApiConstants.challenges}/$challengeId/claim');
      return response.data['data'];
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Erreur lors de la réclamation');
      }
      throw Exception(ErrorHandler.getReadableMessage(e, defaultMessage: 'Impossible de réclamer la récompense.'));
    }
  }

  /// Récupérer les bonus actifs
  Future<List<Map<String, dynamic>>> getActiveBonuses() async {
    try {
      final response = await _dio.get(ApiConstants.bonuses);
      return (response.data['data'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception(ErrorHandler.getReadableMessage(e, defaultMessage: 'Impossible de charger les bonus.'));
    }
  }

  /// Calculer le bonus potentiel pour une livraison
  Future<Map<String, dynamic>> calculateBonus(double baseEarnings) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.bonuses}/calculate',
        data: {'base_earnings': baseEarnings},
      );
      return response.data['data'];
    } catch (e) {
      throw Exception(ErrorHandler.getReadableMessage(e, defaultMessage: 'Impossible de calculer le bonus.'));
    }
  }
}
