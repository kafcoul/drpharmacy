import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/models/duty_zone_model.dart';
import 'package:dio/dio.dart';

final dutyZonesProvider = FutureProvider.autoDispose<List<DutyZoneModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  
  try {
    final response = await apiClient.get('/duty-zones');
    // Assuming API follows standard response: { status: 'success', data: [...] }
    final List<dynamic> data = response.data['data'];
    return data.map((json) => DutyZoneModel.fromJson(json)).toList();
  } on DioException catch (e) {
    throw e.message ?? 'Erreur lors du chargement des zones de garde';
  } catch (e) {
    throw 'Erreur inattendue: $e';
  }
});
