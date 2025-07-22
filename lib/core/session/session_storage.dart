import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract interface for session storage
/// Provides a clean contract for session management
abstract class SessionStorage {
  Future<void> saveUserId(String userId);
  Future<String?> getUserId(); // Now async to prevent race conditions
  Future<void> clearUserId();
  Future<void> clearAll();
  void debugPrintAllValues();

  // Methods for offline credentials
  Future<void> setBool(String key, bool value);
  Future<void> setString(String key, String value);
  Future<String?> getString(String key); // Also make async for consistency
  Future<bool?> getBool(String key); // Also make async for consistency
  Future<void> remove(String key);
}

@LazySingleton(as: SessionStorage)
class SessionStorageImpl implements SessionStorage {
  final SharedPreferences _prefs;
  final Completer<void> _initializationCompleter = Completer<void>();

  SessionStorageImpl({required SharedPreferences prefs}) : _prefs = prefs {
    // Mark as initialized immediately since SharedPreferences is already ready
    _initializationCompleter.complete();
  }

  @override
  Future<void> saveUserId(String userId) async {
    await _initializationCompleter.future; // Ensure initialization
    await _prefs.setString('user_id', userId);
  }

  @override
  Future<String?> getUserId() async {
    // Wait for initialization to complete - prevents race conditions
    await _initializationCompleter.future;
    return _prefs.getString('user_id');
  }

  @override
  Future<void> clearUserId() async {
    await _initializationCompleter.future; // Ensure initialization
    await _prefs.remove('user_id');
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
    await _initializationCompleter.future; // Ensure initialization
    await _prefs.clear();
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _initializationCompleter.future; // Ensure initialization
    await _prefs.setBool(key, value);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _initializationCompleter.future; // Ensure initialization
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    await _initializationCompleter.future; // Ensure initialization
    return _prefs.getString(key);
  }

  @override
  Future<bool?> getBool(String key) async {
    await _initializationCompleter.future; // Ensure initialization
    return _prefs.getBool(key);
  }

  @override
  Future<void> remove(String key) async {
    await _initializationCompleter.future; // Ensure initialization
    await _prefs.remove(key);
  }
}
