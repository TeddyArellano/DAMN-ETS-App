import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/ets_model.dart';

class EtsLocalCache {
  const EtsLocalCache({
    required this.items,
    required this.lastUpdated,
  });

  final List<EtsModel> items;
  final DateTime? lastUpdated;
}

class EtsLocalDataSource {
  static const String _cacheKey = 'ets_cached_items';
  static const String _lastUpdatedKey = 'ets_cache_last_updated';

  Future<void> saveEts(List<EtsModel> items) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedItems = items.map((item) => item.toJson()).toList();

    await preferences.setString(_cacheKey, jsonEncode(encodedItems));
    await preferences.setString(
      _lastUpdatedKey,
      DateTime.now().toIso8601String(),
    );
  }

  Future<EtsLocalCache?> getCachedEts() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedItems = preferences.getString(_cacheKey);

    if (encodedItems == null || encodedItems.isEmpty) {
      return null;
    }

    final decodedItems = jsonDecode(encodedItems);

    if (decodedItems is! List) {
      return null;
    }

    final items = decodedItems
        .whereType<Map<String, dynamic>>()
        .map(EtsModel.fromJson)
        .toList();

    final lastUpdatedValue = preferences.getString(_lastUpdatedKey);

    return EtsLocalCache(
      items: items,
      lastUpdated: lastUpdatedValue == null
          ? null
          : DateTime.tryParse(lastUpdatedValue),
    );
  }
}