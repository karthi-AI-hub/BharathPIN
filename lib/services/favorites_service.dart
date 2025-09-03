import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_office.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_post_offices';

  /// Add post office to favorites
  static Future<void> addToFavorites(PostOffice postOffice) async {
    final prefs = await SharedPreferences.getInstance();
    List<PostOffice> favorites = await getFavorites();

    // Check if already exists
    bool exists = favorites.any(
        (po) => po.name == postOffice.name && po.pincode == postOffice.pincode);

    if (!exists) {
      favorites.add(postOffice);
      List<String> favoritesJson =
          favorites.map((po) => json.encode(po.toJson())).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
    }
  }

  /// Remove post office from favorites
  static Future<void> removeFromFavorites(PostOffice postOffice) async {
    final prefs = await SharedPreferences.getInstance();
    List<PostOffice> favorites = await getFavorites();

    favorites.removeWhere(
        (po) => po.name == postOffice.name && po.pincode == postOffice.pincode);

    List<String> favoritesJson =
        favorites.map((po) => json.encode(po.toJson())).toList();
    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  /// Check if post office is in favorites
  static Future<bool> isFavorite(PostOffice postOffice) async {
    List<PostOffice> favorites = await getFavorites();
    return favorites.any(
        (po) => po.name == postOffice.name && po.pincode == postOffice.pincode);
  }

  /// Get all favorite post offices
  static Future<List<PostOffice>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

    return favoritesJson
        .map((jsonStr) => PostOffice.fromJson(json.decode(jsonStr)))
        .toList();
  }

  /// Clear all favorites
  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }
}
