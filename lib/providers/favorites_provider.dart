import 'package:ecommerce_app/providers/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';


class FavoritesNotifier extends StateNotifier<Set<int>> {
  final Ref ref;

  FavoritesNotifier(this.ref) : super({}) {
    _load();
  }

  Future<void> _load() async {
    final storage = ref.read(storageServiceProvider);
    state = await storage.loadFavoriteIds();
  }

  Future<void> _persist() async {
    final storage = ref.read(storageServiceProvider);
    await storage.saveFavoriteIds(state);
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