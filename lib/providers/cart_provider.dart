import 'package:ecommerce_app/providers/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/cart_item_model.dart';
import '../model/product_model.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  final Ref ref;

  CartNotifier(this.ref) : super([]) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    final storage = ref.read(storageServiceProvider);
    state = await storage.loadCart();
  }

  Future<void> _persist() async {
    final storage = ref.read(storageServiceProvider);
    await storage.saveCart(state);
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