import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _pincodeHistoryKey = 'pincode_search_history';
  static const String _nameHistoryKey = 'name_search_history';
  static const int _maxHistoryItems = 10;

  /// Add a pincode to search history
  static Future<void> addPincodeToHistory(String pincode) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = await getPincodeHistory();

    // Remove if already exists to avoid duplicates
    history.remove(pincode);

    // Add to beginning of list
    history.insert(0, pincode);

    // Limit history size
    if (history.length > _maxHistoryItems) {
      history = history.take(_maxHistoryItems).toList();
    }

    await prefs.setStringList(_pincodeHistoryKey, history);
  }

  /// Add a post office name to search history
  static Future<void> addNameToHistory(String name) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = await getNameHistory();

    // Remove if already exists to avoid duplicates
    history.remove(name);

    // Add to beginning of list
    history.insert(0, name);

    // Limit history size
    if (history.length > _maxHistoryItems) {
      history = history.take(_maxHistoryItems).toList();
    }

    await prefs.setStringList(_nameHistoryKey, history);
  }

  /// Get pincode search history
  static Future<List<String>> getPincodeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_pincodeHistoryKey) ?? [];
  }

  /// Get name search history
  static Future<List<String>> getNameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_nameHistoryKey) ?? [];
  }

  /// Clear pincode search history
  static Future<void> clearPincodeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pincodeHistoryKey);
  }

  /// Clear name search history
  static Future<void> clearNameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameHistoryKey);
  }

  /// Clear all search history
  static Future<void> clearAllHistory() async {
    await clearPincodeHistory();
    await clearNameHistory();
  }
}
