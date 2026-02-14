import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../constants/api_constants.dart';
import 'dio_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: AppConfig.connectionTimeout,
    receiveTimeout: AppConfig.receiveTimeout,
  ));

  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
});
