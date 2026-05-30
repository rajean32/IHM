import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../repositories/auth_repository.dart';
import '../models/user.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthState {
  final bool isLoading;
  final String? error;
  final LoginResponse? user;
  final bool isAuthenticated;
  final bool needsFirstLogin;

  AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.isAuthenticated = false,
    this.needsFirstLogin = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    LoginResponse? user,
    bool? isAuthenticated,
    bool? needsFirstLogin,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      needsFirstLogin: needsFirstLogin ?? this.needsFirstLogin,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(AuthState()) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = await _repository.getUserSession();
    if (session['token'] != null) {
      final needsFirstLogin = session['needsFirstLogin'] == 'true';
      state = state.copyWith(
        isAuthenticated: true,
        needsFirstLogin: needsFirstLogin,
        user: LoginResponse(
          token: session['token']!,
          codeUtilisateur: session['userCode'] ?? '',
          email: session['userEmail'] ?? '',
          role: session['role'] ?? '',
          isFirstLogin: needsFirstLogin,
        ),
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.login(email, password);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        needsFirstLogin: user.isFirstLogin,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
    }
  }

  Future<void> register({
    required String codeUtilisateur,
    required String nom,
    required String prenoms,
    required String sexe,
    required String dateDeNaissance,
    required String email,
    required String tel,
    required String motDePasse,
    String type = 'client',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.register(
        codeUtilisateur: codeUtilisateur,
        nom: nom,
        prenoms: prenoms,
        sexe: sexe,
        dateDeNaissance: dateDeNaissance,
        email: email,
        tel: tel,
        motDePasse: motDePasse,
        type: type,
      );
      await _repository.saveSession(user);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        needsFirstLogin: user.isFirstLogin,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
    }
  }

  Future<void> firstLoginUpdate({
    required String codeUtilisateur,
    required String newPassword,
    required String newEmail,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.firstLoginUpdate(
        codeUtilisateur: codeUtilisateur,
        newPassword: newPassword,
        newEmail: newEmail,
      );
      await _repository.saveSession(user);
      state = state.copyWith(
        isLoading: false,
        user: user,
        needsFirstLogin: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState();
  }
}
