import 'package:ecommerce_app/providers/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/cart_item_model.dart';
import '../model/product_model.dart';


class CartNotifier extends StateNotifier<List<CartItem>> {
  final Ref ref;
  String? _userKey;

  CartNotifier(this.ref) : super([]);

  /// Loads the cart belonging to [userKey] (the user's email). Call this
  /// right after login/register, and on app start if a session already
  /// exists, so each account sees only its own cart.
  Future<void> loadForUser(String userKey) async {
    _userKey = userKey;
    final storage = ref.read(storageServiceProvider);
    state = await storage.loadCart(userKey);
  }

  /// Clears the in-memory cart when logging out, WITHOUT touching what's
  /// saved on disk — the data is still there under this user's key and
  /// will reappear next time they log back in via [loadForUser].
  void clearSession() {
    _userKey = null;
    state = [];
  }

  Future<void> _persist() async {
    final userKey = _userKey;
    if (userKey == null) return; // no active session — nothing to save to
    final storage = ref.read(storageServiceProvider);
    await storage.saveCart(userKey, state);
  }

  void addToCart(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final updated = [...state];
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + 1,
      );
      state = updated;
    } else {
      state = [...state, CartItem(product: product)];
    }
    _persist();
  }

  void removeFromCart(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
    _persist();
  }

  void incrementQuantity(int productId) {
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
    _persist();
  }

  void decrementQuantity(int productId) {
    state = [
      for (final item in state)
        if (item.product.id == productId && item.quantity > 1)
          item.copyWith(quantity: item.quantity - 1)
        else if (item.product.id != productId)
          item,
    ];
    _persist();
  }

  /// Empties the CURRENT user's cart on disk too (e.g. after checkout
  /// completes). Different from [clearSession], which only clears the
  /// in-memory view and keeps the saved data intact.
  void clearCart() {
    state = [];
    _persist();
  }

  bool isInCart(int productId) =>
      state.any((item) => item.product.id == productId);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier(ref);
});

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold<double>(0, (sum, item) => sum + item.totalPrice);
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold<int>(0, (sum, item) => sum + item.quantity);
});