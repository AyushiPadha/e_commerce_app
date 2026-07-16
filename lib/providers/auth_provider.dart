import 'package:ecommerce_app/providers/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/user_model.dart';
import 'cart_provider.dart';
import 'favorites_provider.dart';


enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final authService = ref.read(authServiceProvider);
    final user = await authService.currentUser();
    if (user != null) {
      await ref.read(cartProvider.notifier).loadForUser(user.email);
      await ref.read(favoritesProvider.notifier).loadForUser(user.email);
    }
    state = state.copyWith(
      status: user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      user: user,
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.login(email: email, password: password);
      await ref.read(cartProvider.notifier).loadForUser(user.email);
      await ref.read(favoritesProvider.notifier).loadForUser(user.email);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authService = ref.read(authServiceProvider);
      final user =
      await authService.register(name: name, email: email, password: password);
      await ref.read(cartProvider.notifier).loadForUser(user.email);
      await ref.read(favoritesProvider.notifier).loadForUser(user.email);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    // clearSession only resets the in-memory view — the saved cart and
    // favorites for this account stay on disk under their own key, so
    // they're restored next time this same user logs back in.
    ref.read(cartProvider.notifier).clearSession();
    ref.read(favoritesProvider.notifier).clearSession();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});