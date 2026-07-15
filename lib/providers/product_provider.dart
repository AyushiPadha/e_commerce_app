
import 'package:ecommerce_app/providers/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/product_model.dart';


/// Fetches the full product catalog once from the REST API.
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchProducts();
});

/// Fetches available categories from the REST API.
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchCategories();
});

/// Currently selected category filter on the home screen ('All' = no filter).
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

/// Current search query typed on the search screen.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Products filtered by the selected category.
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final category = ref.watch(selectedCategoryProvider);

  return productsAsync.whenData((products) {
    if (category == 'All') return products;
    return products.where((p) => p.category == category).toList();
  });
});

/// Products filtered by the current search query (title match, case-insensitive).
final searchResultsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return productsAsync.whenData((products) {
    if (query.isEmpty) return <Product>[];
    return products
        .where((p) => p.title.toLowerCase().contains(query))
        .toList();
  });
});

/// Fetch a single product by id (used for deep links / detail refresh).
final productByIdProvider =
FutureProvider.family<Product, int>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  return api.fetchProductById(id);
});