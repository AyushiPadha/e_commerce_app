import '../model/user_model.dart';
import 'storage_service.dart';

/// A local, mock authentication service.
///
/// FakeStoreAPI's own /auth endpoint is a demo stub not meant for real
/// account creation, so real auth flow (validate → persist session) is
/// simulated locally with SharedPreferences. This keeps the UX identical
/// to a real backend and is easy to swap for FastAPI + JWT later —
/// only this file would need to change.
class AuthService {
  final StorageService _storage;

  AuthService({StorageService? storage}) : _storage = storage ?? StorageService();

  Future<AppUser> login({required String email, required String password}) async {
    // Simulate network latency for a realistic UX.
    await Future.delayed(const Duration(milliseconds: 600));

    if (email.trim().isEmpty || !email.contains('@')) {
      throw AuthException('Please enter a valid email address.');
    }
    if (password.length < 4) {
      throw AuthException('Password must be at least 4 characters.');
    }

    final name = email.split('@').first;
    await _storage.saveSession(name: name, email: email.trim());
    return AppUser(name: name, email: email.trim());
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (name.trim().isEmpty) {
      throw AuthException('Please enter your name.');
    }
    if (!email.contains('@')) {
      throw AuthException('Please enter a valid email address.');
    }
    if (password.length < 4) {
      throw AuthException('Password must be at least 4 characters.');
    }

    await _storage.saveSession(name: name.trim(), email: email.trim());
    return AppUser(name: name.trim(), email: email.trim());
  }

  Future<void> logout() => _storage.clearSession();

  Future<AppUser?> currentUser() async {
    final session = await _storage.getSession();
    if (session == null) return null;
    return AppUser(name: session['name'] ?? '', email: session['email'] ?? '');
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}