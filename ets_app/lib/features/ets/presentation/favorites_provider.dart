import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/presentation/auth_providers.dart';

final favoritesProvider =
    AsyncNotifierProvider<FavoritesController, Set<int>>(
  FavoritesController.new,
);

class FavoritesController extends AsyncNotifier<Set<int>> {
  String get _storageKey {
    final email =
        ref.read(authControllerProvider).asData?.value?.email ?? 'guest';

    return 'ets_favorites_$email';
  }

  @override
  Future<Set<int>> build() async {
    ref.watch(authControllerProvider);

    final preferences = await SharedPreferences.getInstance();
    final storedValues = preferences.getStringList(_storageKey) ?? [];

    return storedValues
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  Future<void> toggleFavorite(int etsId) async {
    final currentFavorites = <int>{...state.value ?? <int>{}};

    if (currentFavorites.contains(etsId)) {
      currentFavorites.remove(etsId);
    } else {
      currentFavorites.add(etsId);
    }

    state = AsyncData(currentFavorites);

    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      currentFavorites.map((id) => id.toString()).toList(),
    );
  }

  Future<void> clearFavorites() async {
    state = const AsyncData(<int>{});

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }
}