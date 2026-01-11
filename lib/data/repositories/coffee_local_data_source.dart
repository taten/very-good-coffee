import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coffee.dart';

class CoffeeLocalDataSource {
  static const String _favoritesKey = 'favorites';

  Future<List<Coffee>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

    return favoritesJson
        .map((json) => Coffee.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveFavorite(Coffee coffee) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    // Check if already favorited
    if (!favorites.any((c) => c.id == coffee.id)) {
      favorites.add(coffee.copyWith(isFavorite: true));
      final favoritesJson = favorites
          .map((c) => jsonEncode(c.toJson()))
          .toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
    }
  }

  Future<void> removeFavorite(String coffeeId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    favorites.removeWhere((c) => c.id == coffeeId);
    final favoritesJson = favorites
        .map((c) => jsonEncode(c.toJson()))
        .toList();
    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  Future<bool> isFavorite(String coffeeId) async {
    final favorites = await getFavorites();
    return favorites.any((c) => c.id == coffeeId);
  }
}
