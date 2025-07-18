import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SessionStorage {
  final SharedPreferences _prefs;

  SessionStorage({required SharedPreferences prefs}) : _prefs = prefs;

  Future<void> saveUserId(String userId) async {
    print('SessionStorage: Saving userId: $userId');
    await _prefs.setString('user_id', userId);
    print('SessionStorage: userId saved successfully');
  }

  String? getUserId() {
    final userId = _prefs.getString('user_id');
    print('SessionStorage: Getting userId: $userId');
    return userId;
  }

  Future<void> clearUserId() async {
    print('SessionStorage: Clearing userId');
    await _prefs.remove('user_id');
    print('SessionStorage: userId cleared successfully');
  }

  // Debug method to check all stored values
  void debugPrintAllValues() {
    print('SessionStorage: All stored values:');
    final keys = _prefs.getKeys();
    for (final key in keys) {
      final value = _prefs.get(key);
      print('  $key: $value');
    }
  }

  // Clear all session data
  Future<void> clearAll() async {
    print('SessionStorage: Clearing all session data');
    await _prefs.clear();
    print('SessionStorage: All session data cleared');
  }
}
