
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritePokemonProvider = StateNotifierProvider<FavoriteNotifier, List<String>>((ref) {
  return FavoriteNotifier();
});

class FavoriteNotifier extends StateNotifier<List<String>> {
  FavoriteNotifier() : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList('favorites') ?? [];
  }

  Future<void> toggleFavorite(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList('favorites') ?? [];

    if (current.contains(name)) {
      current.remove(name);
    } else {
      current.add(name);
    }

    await prefs.setStringList('favorites', current);
    state = current;
  }
}
