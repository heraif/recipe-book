import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService = AuthService();

  AuthCubit() : super(const AuthState()) {
    _authService.authStateChanges.listen((user) async {
      AppUser? profile;
      if (user != null) {
        profile = await _authService.getCurrentUserProfile();
      }
      emit(state.copyWith(
        firebaseUser: user,
        profile: profile,
        error: null,
      ));
    });
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _authService.login(email: email, password: password);
      emit(state.copyWith(loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String country,
    String photoUrl = '',
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
        country: country,
        photoUrl: photoUrl,
      );
      emit(state.copyWith(loading: false, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}

