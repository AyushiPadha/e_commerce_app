import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../model/product_model.dart';


/// Handles all REST calls to the product API (FakeStoreAPI).
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Product>> fetchProducts() async {
    final response = await _client.get(Uri.parse(ApiConstants.products));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException('Failed to load products (${response.statusCode})');
  }

  Future<List<String>> fetchCategories() async {
    final response = await _client.get(Uri.parse(ApiConstants.categories));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((e) => e.toString()).toList();
    }
    throw ApiException('Failed to load categories (${response.statusCode})');
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    final response = await _client
        .get(Uri.parse(ApiConstants.productsByCategory(category)));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException('Failed to load category products (${response.statusCode})');
  }

  Future<Product> fetchProductById(int id) async {
    final response =
    await _client.get(Uri.parse(ApiConstants.productById(id)));
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw ApiException('Failed to load product (${response.statusCode})');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}