import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract interface for session storage
/// Provides a clean contract for session management
abstract class SessionStorage {
  Future<void> saveUserId(String userId);
  String? getUserId();
  Future<void> clearUserId();
  Future<void> clearAll();
  void debugPrintAllValues();

  // Methods for offline credentials
  Future<void> setBool(String key, bool value);
  Future<void> setString(String key, String value);
  String? getString(String key);
  bool? getBool(String key);
  Future<void> remove(String key);
}

@LazySingleton(as: SessionStorage)
class SessionStorageImpl implements SessionStorage {
  final SharedPreferences _prefs;

  SessionStorageImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<void> saveUserId(String userId) async {
    print('SessionStorage: Saving userId: $userId');
    await _prefs.setString('user_id', userId);
    print('SessionStorage: userId saved successfully');
  }

  @override
  String? getUserId() {
    final userId = _prefs.getString('user_id');
    print('SessionStorage: Getting userId: $userId');
    return userId;
  }

  @override
  Future<void> clearUserId() async {
    print('SessionStorage: Clearing userId');
    await _prefs.remove('user_id');
    print('SessionStorage: userId cleared successfully');
  }

  @override
  void debugPrintAllValues() {
    print('SessionStorage: All stored values:');
    final keys = _prefs.getKeys();
    for (final key in keys) {
      final value = _prefs.get(key);
      print('  $key: $value');
    }
  }

  @override
  Future<void> clearAll() async {
    print('SessionStorage: Clearing all session data');
    await _prefs.clear();
    print('SessionStorage: All session data cleared');
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  String? getString(String key) {
    return _prefs.getString(key);
  }

  @override
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
