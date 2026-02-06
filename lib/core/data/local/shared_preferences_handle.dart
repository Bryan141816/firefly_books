import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  PrefsService._(); // private constructor

  static final PrefsService instance = PrefsService._();

  late SharedPreferences _prefs;

  /// Call this ONCE at app startup
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // -----------------------------
  // Generic helpers
  // -----------------------------
  String? getString(String key) => _prefs.getString(key);
  bool? getBool(String key) => _prefs.getBool(key);
  int? getInt(String key) => _prefs.getInt(key);
  double? getDouble(String key) => _prefs.getDouble(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);

  Future<bool> clear() => _prefs.clear();

  // -----------------------------
  // App-specific shortcuts
  // -----------------------------
  static const _booksDirectoryKey = 'booksDirectory';
  static const _setupCompleteKey = 'setupComplete';

  String get booksDirectory => _prefs.getString(_booksDirectoryKey) ?? "";

  Future<void> setBooksDirectory(String value) =>
      _prefs.setString(_booksDirectoryKey, value);

  bool get setupComplete => _prefs.getBool(_setupCompleteKey) ?? false;

  Future<void> setSetupComplete(bool value) =>
      _prefs.setBool(_setupCompleteKey, value);
}
