import 'package:shared_preferences/shared_preferences.dart';

class PrefsManager {
  static const String keyLevel = 'level';
  static const String keyDistance = 'distance';
  static const String keyTotalCorrect = 'totalCorrect';
  static const String keyTotalWrong = 'totalWrong';
  static const String keyIgnoredGestures = 'ignoredGestures';

  static Future<void> save({
    required int level,
    required double distance,
    required int totalCorrect,
    required int totalWrong,
    required int ignoredGestures,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyLevel, level);
    await prefs.setDouble(keyDistance, distance);
    await prefs.setInt(keyTotalCorrect, totalCorrect);
    await prefs.setInt(keyTotalWrong, totalWrong);
    await prefs.setInt(keyIgnoredGestures, ignoredGestures);
  }

  static Future<Map<String, dynamic>> loadDefaults({
    required int defaultLevel,
    required double defaultDistance,
    required int defaultCorrect,
    required int defaultWrong,
    required int defaultIgnored,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return {
      keyLevel: prefs.getInt(keyLevel) ?? defaultLevel,
      keyDistance: prefs.getDouble(keyDistance) ?? defaultDistance,
      keyTotalCorrect: prefs.getInt(keyTotalCorrect) ?? defaultCorrect,
      keyTotalWrong: prefs.getInt(keyTotalWrong) ?? defaultWrong,
      keyIgnoredGestures: prefs.getInt(keyIgnoredGestures) ?? defaultIgnored,
    };
  }
}
