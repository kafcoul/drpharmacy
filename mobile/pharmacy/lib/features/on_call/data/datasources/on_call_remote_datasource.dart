import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/core_providers.dart';
import '../models/on_call_model.dart';

abstract class OnCallRemoteDataSource {
  Future<List<OnCallModel>> getOnCalls();
  Future<OnCallModel> createOnCall(Map<String, dynamic> data);
  Future<void> deleteOnCall(int id);
}

class OnCallRemoteDataSourceImpl implements OnCallRemoteDataSource {
  final ApiClient _client;

  OnCallRemoteDataSourceImpl(this._client);

  @override
  Future<List<OnCallModel>> getOnCalls() async {
    final response = await _client.get('/pharmacy/on-calls');
    // Expecting { status: 'success', data: { data: [...] } } because of paginate()
    // Or just { status: 'success', data: [...] } if not paginated.
    // The controller uses paginate(20). So structure is data.data
    final data = response.data['data']['data'] as List;
    return data.map((json) => OnCallModel.fromJson(json)).toList();
  }

  @override
  Future<OnCallModel> createOnCall(Map<String, dynamic> data) async {
    final response = await _client.post('/pharmacy/on-calls', data: data);
    return OnCallModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteOnCall(int id) async {
    await _client.delete('/pharmacy/on-calls/$id');
  }
}

final onCallRemoteDataSourceProvider = Provider<OnCallRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return OnCallRemoteDataSourceImpl(client);
});
