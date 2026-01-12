import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/coffee.dart';

/// Local data source for managing favorited coffees.
/// Only responsible for local storage operations.
class CoffeeLocalDataSource {
  static const String _favoritesKey = 'favorites';

  /// Retrieves all favorited coffees from local storage
  Future<List<Coffee>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

    return favoritesJson.map((jsonStr) {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Coffee(
        id: json['id'] as String,
        imageUrl: json['imageUrl'] as String,
        isFavorite: true,
      );
    }).toList();
  }

  /// Saves a coffee to favorites
  Future<void> saveFavorite(Coffee coffee) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    // Check if already favorited
    if (!favorites.any((c) => c.id == coffee.id)) {
      favorites.add(coffee.copyWith(isFavorite: true));
      final favoritesJson = favorites.map((c) {
        return jsonEncode({
          'id': c.id,
          'imageUrl': c.imageUrl,
          'isFavorite': true,
        });
      }).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
    }
  }

  /// Removes a coffee from favorites
  Future<void> removeFavorite(String coffeeId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    favorites.removeWhere((c) => c.id == coffeeId);
    final favoritesJson = favorites.map((c) {
      return jsonEncode({
        'id': c.id,
        'imageUrl': c.imageUrl,
        'isFavorite': true,
      });
    }).toList();
    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  /// Checks if a coffee is favorited
  Future<bool> isFavorite(String coffeeId) async {
    final favorites = await getFavorites();
    return favorites.any((c) => c.id == coffeeId);
  }
}
