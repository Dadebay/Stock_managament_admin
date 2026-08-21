import 'package:shared_preferences/shared_preferences.dart';

/// Thin, GetStorage-shaped wrapper over SharedPreferences.
///
/// get_storage has no wasm-compatible release — it still imports `dart:html`,
/// which `flutter build web --wasm` refuses to compile. shared_preferences
/// works on wasm, so this keeps the same `read`/`write`/`remove` call sites
/// while swapping the backing store.
class AppStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  T? read<T>(String key) {
    final value = _prefs?.get(key);
    return value is T ? value : null;
  }

  Future<void> write(String key, dynamic value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else {
      await prefs.setString(key, '$value');
    }
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }
}
