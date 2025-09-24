import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const String _keyName = 'myStringKey';

  /// Save a string value
  static Future<void> saveString(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, value);
  }

  /// Get the saved string (returns null if not found)
  static Future<String?> getString() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  /// Remove the saved string
  static Future<void> clearString() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
  }

  /// Save a bool value with a given key
  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Get a bool value (returns false if not found)
  static Future<bool> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  /// Remove a bool value
  static Future<void> clearBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
