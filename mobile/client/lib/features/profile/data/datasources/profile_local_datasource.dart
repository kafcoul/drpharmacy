import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileModel?> getCachedProfile();
  Future<void> cacheProfile(ProfileModel profile);
  Future<void> clearCache();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cachedProfileKey = 'CACHED_PROFILE';

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<ProfileModel?> getCachedProfile() async {
    final jsonString = sharedPreferences.getString(_cachedProfileKey);
    if (jsonString != null) {
      return ProfileModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    await sharedPreferences.setString(
      _cachedProfileKey,
      json.encode(profile.toJson()),
    );
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_cachedProfileKey);
  }
}
