import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../model/cart_item_model.dart';


/// Thin wrapper around SharedPreferences for all local persistence:
/// auth session, theme choice, cart contents, favorite product ids.
class StorageService {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // --- Auth session ---
  Future<void> saveSession({required String name, required String email}) async {
    final prefs = await _prefs;
    await prefs.setBool(ApiConstants.keyIsLoggedIn, true);
    await prefs.setString(ApiConstants.keyUserName, name);
    await prefs.setString(ApiConstants.keyUserEmail, email);
  }

  Future<void> clearSession() async {
    final prefs = await _prefs;
    await prefs.setBool(ApiConstants.keyIsLoggedIn, false);
    await prefs.remove(ApiConstants.keyUserName);
    await prefs.remove(ApiConstants.keyUserEmail);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(ApiConstants.keyIsLoggedIn) ?? false;
  }

  Future<Map<String, String>?> getSession() async {
    final prefs = await _prefs;
    final loggedIn = prefs.getBool(ApiConstants.keyIsLoggedIn) ?? false;
    if (!loggedIn) return null;
    return {
      'name': prefs.getString(ApiConstants.keyUserName) ?? '',
      'email': prefs.getString(ApiConstants.keyUserEmail) ?? '',
    };
  }

  // --- Theme ---
  Future<void> saveThemeMode(String mode) async {
    final prefs = await _prefs;
    await prefs.setString(ApiConstants.keyThemeMode, mode);
  }

  Future<String?> getThemeMode() async {
    final prefs = await _prefs;
    return prefs.getString(ApiConstants.keyThemeMode);
  }

  // --- Cart (keyed per-user so different accounts don't share a cart) ---
  Future<void> saveCart(String userKey, List<CartItem> items) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString('${ApiConstants.keyCartItems}_$userKey', encoded);
  }

  Future<List<CartItem>> loadCart(String userKey) async {
    final prefs = await _prefs;
    final raw = prefs.getString('${ApiConstants.keyCartItems}_$userKey');
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // --- Favorites (keyed per-user, same reasoning as cart) ---
  Future<void> saveFavoriteIds(String userKey, Set<int> ids) async {
    final prefs = await _prefs;
    await prefs.setStringList(
      '${ApiConstants.keyFavoriteIds}_$userKey',
      ids.map((e) => e.toString()).toList(),
    );
  }

  Future<Set<int>> loadFavoriteIds(String userKey) async {
    final prefs = await _prefs;
    final raw = prefs.getStringList('${ApiConstants.keyFavoriteIds}_$userKey') ?? [];
    return raw.map((e) => int.tryParse(e) ?? -1).where((e) => e != -1).toSet();
  }
}