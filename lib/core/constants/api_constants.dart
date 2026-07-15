/// Central place for all API endpoints and storage keys.
class ApiConstants {
  ApiConstants._();

  // FakeStoreAPI — free, no key required. Great for demo/portfolio use.
  // https://fakestoreapi.com
  static const String baseUrl = 'https://fakestoreapi.com';

  static const String products = '$baseUrl/products';
  static const String categories = '$baseUrl/products/categories';

  static String productsByCategory(String category) =>
      '$baseUrl/products/category/$category';

  static String productById(int id) => '$baseUrl/products/$id';

  // Local storage keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyThemeMode = 'theme_mode';
  static const String keyCartItems = 'cart_items';
  static const String keyFavoriteIds = 'favorite_ids';
}