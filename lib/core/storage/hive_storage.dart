import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

/// Provider for HiveStorage instance.
final hiveStorageProvider = Provider<HiveStorage>((ref) {
  return HiveStorage();
});

/// Hive local storage management for caching and offline data.
class HiveStorage {
  /// Initialize Hive and open required boxes.
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Open all required boxes
    await Future.wait([
      Hive.openBox<dynamic>(AppConstants.userBox),
      Hive.openBox<dynamic>(AppConstants.settingsBox),
      Hive.openBox<dynamic>(AppConstants.cacheBox),
      Hive.openBox<dynamic>(AppConstants.matchesBox),
      Hive.openBox<dynamic>(AppConstants.tournamentsBox),
    ]);
  }

  // User Box Operations

  /// Get user data from local storage.
  Box<dynamic> get userBox => Hive.box<dynamic>(AppConstants.userBox);

  /// Save user data to local storage.
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await userBox.put('current_user', userData);
  }

  /// Get cached user data.
  Map<String, dynamic>? getUser() {
    final data = userBox.get('current_user');
    if (data != null) {
      return Map<String, dynamic>.from(data as Map);
    }
    return null;
  }

  /// Clear user data on logout.
  Future<void> clearUser() async {
    await userBox.clear();
  }

  // Settings Box Operations

  /// Get settings box.
  Box<dynamic> get settingsBox => Hive.box<dynamic>(AppConstants.settingsBox);

  /// Save a setting value.
  Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  /// Get a setting value.
  T? getSetting<T>(String key) {
    return settingsBox.get(key) as T?;
  }

  /// Check if onboarding is completed.
  bool get isOnboardingComplete =>
      settingsBox.get('onboarding_complete', defaultValue: false) as bool;

  /// Mark onboarding as complete.
  Future<void> completeOnboarding() async {
    await settingsBox.put('onboarding_complete', true);
  }

  // Cache Box Operations

  /// Get cache box.
  Box<dynamic> get cacheBox => Hive.box<dynamic>(AppConstants.cacheBox);

  /// Cache data with a key and optional expiry.
  Future<void> cacheData(
    String key,
    dynamic data, {
    Duration? expiry,
  }) async {
    final cacheEntry = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };
    await cacheBox.put(key, cacheEntry);
  }

  /// Get cached data if it has not expired.
  dynamic getCachedData(String key) {
    final entry = cacheBox.get(key);
    if (entry == null) return null;

    final cacheEntry = Map<String, dynamic>.from(entry as Map);
    final timestamp = cacheEntry['timestamp'] as int;
    final expiry = cacheEntry['expiry'] as int?;

    if (expiry != null) {
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (age > expiry) {
        // Cache expired, remove it
        cacheBox.delete(key);
        return null;
      }
    }

    return cacheEntry['data'];
  }

  /// Check if cached data exists and is valid.
  bool isCacheValid(String key) {
    return getCachedData(key) != null;
  }

  /// Clear a specific cache entry.
  Future<void> clearCache(String key) async {
    await cacheBox.delete(key);
  }

  /// Clear all cached data.
  Future<void> clearAllCache() async {
    await cacheBox.clear();
  }

  // Matches Box Operations

  /// Get matches box.
  Box<dynamic> get matchesBox => Hive.box<dynamic>(AppConstants.matchesBox);

  /// Cache match data.
  Future<void> cacheMatch(String matchId, Map<String, dynamic> data) async {
    await matchesBox.put(matchId, data);
  }

  /// Get cached match data.
  Map<String, dynamic>? getCachedMatch(String matchId) {
    final data = matchesBox.get(matchId);
    if (data != null) {
      return Map<String, dynamic>.from(data as Map);
    }
    return null;
  }

  // Tournaments Box Operations

  /// Get tournaments box.
  Box<dynamic> get tournamentsBox =>
      Hive.box<dynamic>(AppConstants.tournamentsBox);

  /// Cache tournament data.
  Future<void> cacheTournament(
    String tournamentId,
    Map<String, dynamic> data,
  ) async {
    await tournamentsBox.put(tournamentId, data);
  }

  /// Get cached tournament data.
  Map<String, dynamic>? getCachedTournament(String tournamentId) {
    final data = tournamentsBox.get(tournamentId);
    if (data != null) {
      return Map<String, dynamic>.from(data as Map);
    }
    return null;
  }

  // Cleanup

  /// Clear all local data (for logout).
  Future<void> clearAll() async {
    await Future.wait([
      userBox.clear(),
      cacheBox.clear(),
      matchesBox.clear(),
      tournamentsBox.clear(),
    ]);
  }

  /// Close all Hive boxes.
  Future<void> close() async {
    await Hive.close();
  }
}
