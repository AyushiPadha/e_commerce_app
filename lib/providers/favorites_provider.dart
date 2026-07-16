import 'package:ecommerce_app/providers/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';


class FavoritesNotifier extends StateNotifier<Set<int>> {
  final Ref ref;
  String? _userKey;

  FavoritesNotifier(this.ref) : super({});

  /// Loads the favorites belonging to [userKey] (the user's email). Call
  /// this right after login/register, and on app start if a session
  /// already exists, so each account sees only its own favorites.
  Future<void> loadForUser(String userKey) async {
    _userKey = userKey;
    final storage = ref.read(storageServiceProvider);
    state = await storage.loadFavoriteIds(userKey);
  }

  /// Clears the in-memory favorites when logging out, WITHOUT touching
  /// what's saved on disk — it reappears next time this user logs back
  /// in via [loadForUser].
  void clearSession() {
    _userKey = null;
    state = {};
  }

  Future<void> _persist() async {
    final userKey = _userKey;
    if (userKey == null) return;
    final storage = ref.read(storageServiceProvider);
    await storage.saveFavoriteIds(userKey, state);
  }

  void toggleFavorite(int productId) {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
    } else {
      state = {...state, productId};
    }
    _persist();
  }

  bool isFavorite(int productId) => state.contains(productId);
}

final favoritesProvider =
StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  return FavoritesNotifier(ref);
});