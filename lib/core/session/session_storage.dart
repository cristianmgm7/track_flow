import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SessionStorage {
  final SharedPreferences _prefs;

  SessionStorage({required SharedPreferences prefs}) : _prefs = prefs;

  Future<void> saveUserId(String userId) async {
    await _prefs.setString('user_id', userId);
  }

  Future<String?> getUserId() async {
    return _prefs.getString('user_id');
  }

  Future<void> clearUserId() async {
    await _prefs.remove('user_id');
  }
}
