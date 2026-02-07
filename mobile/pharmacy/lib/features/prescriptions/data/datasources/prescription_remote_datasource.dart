import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/prescription_model.dart';

abstract class PrescriptionRemoteDataSource {
  Future<List<PrescriptionModel>> getPrescriptions();
  Future<PrescriptionModel> getPrescription(int id);
  Future<PrescriptionModel> updateStatus(int id, String status, {String? notes, double? quoteAmount});
}

class PrescriptionRemoteDataSourceImpl implements PrescriptionRemoteDataSource {
  final ApiClient _client;

  PrescriptionRemoteDataSourceImpl(this._client);

  @override
  Future<List<PrescriptionModel>> getPrescriptions() async {
    final response = await _client.get('/pharmacy/prescriptions');
    final data = response.data['data'] as List;
    return data.map((json) => PrescriptionModel.fromJson(json)).toList();
  }

  @override
  Future<PrescriptionModel> getPrescription(int id) async {
    final response = await _client.get('/pharmacy/prescriptions/$id');
    return PrescriptionModel.fromJson(response.data['data']);
  }

  @override
  Future<PrescriptionModel> updateStatus(int id, String status, {String? notes, double? quoteAmount}) async {
    final response = await _client.post(
      '/pharmacy/prescriptions/$id/status',
      data: {
        'status': status,
        if (notes != null) 'pharmacy_notes': notes,
        if (quoteAmount != null) 'quote_amount': quoteAmount,
      },
    );
    return PrescriptionModel.fromJson(response.data['data']);
  }
}

final prescriptionRemoteDataSourceProvider = Provider<PrescriptionRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PrescriptionRemoteDataSourceImpl(apiClient);
});
