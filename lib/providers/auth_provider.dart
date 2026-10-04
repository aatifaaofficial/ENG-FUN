import 'package:englishfun/models/user_model.dart';
import 'package:englishfun/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  const AuthState({
    this.isLoggedIn = false,
    this.onboardingCompleted = false,
    this.user,
  });

  final bool isLoggedIn;
  final bool onboardingCompleted;
  final UserProfile? user;

  AuthState copyWith({
    bool? isLoggedIn,
    bool? onboardingCompleted,
    UserProfile? user,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._storage) : super(const AuthState()) {
    _load();
  }

  final StorageService _storage;

  Future<void> _load() async {
    final profile = _storage.userProfile;
    state = AuthState(
      isLoggedIn: _storage.isLoggedIn,
      onboardingCompleted: _storage.onboardingCompleted,
      user: profile,
    );
  }

  Future<void> completeOnboarding() async {
    await _storage.setOnboardingCompleted(true);
    state = state.copyWith(onboardingCompleted: true);
  }

  Future<void> login(UserProfile profile) async {
    await _storage.setLoggedIn(true);
    await _storage.saveUserProfile(profile);
    state = state.copyWith(isLoggedIn: true, user: profile);
  }

  Future<void> logout() async {
    await _storage.clearSession();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(StorageService.instance),
);
