import 'package:namaz/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  ProfileRepository(this._prefs);

  static const _profileKey = 'user_profile';

  final SharedPreferences _prefs;

  Future<UserProfile?> loadProfile() async {
    final raw = _prefs.getString(_profileKey);
    return UserProfile.fromJsonString(raw);
  }

  Future<UserProfile> saveProfile(UserProfile profile) async {
    await _prefs.setString(_profileKey, profile.toJsonString());
    return profile;
  }

  Future<void> clear() async {
    await _prefs.remove(_profileKey);
  }
}
