import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<void> cacheUser(UserModel user);
  Future<String?> getToken();
  Future<UserModel?> getUser();
  Future<void> clearAuthData();
  Future<bool> hasToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheToken(String token) async {
    await sharedPreferences.setString(AppConstants.tokenKey, token);
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(
      AppConstants.userKey,
      json.encode(user.toJson()),
    );
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(AppConstants.tokenKey);
  }

  @override
  Future<UserModel?> getUser() async {
    final jsonString = sharedPreferences.getString(AppConstants.userKey);
    if (jsonString != null) {
      return UserModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> clearAuthData() async {
    await sharedPreferences.remove(AppConstants.tokenKey);
    await sharedPreferences.remove(AppConstants.userKey);
  }

  @override
  Future<bool> hasToken() async {
    return sharedPreferences.containsKey(AppConstants.tokenKey);
  }
}
