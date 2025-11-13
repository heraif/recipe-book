import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/app_user.dart';

class AuthState extends Equatable {
  final User? firebaseUser;
  final AppUser? profile;
  final bool loading;
  final String? error;

  const AuthState({
    this.firebaseUser,
    this.profile,
    this.loading = false,
    this.error,
  });

  AuthState copyWith({
    User? firebaseUser,
    AppUser? profile,
    bool? loading,
    String? error,
  }) {
    return AuthState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      profile: profile ?? this.profile,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [firebaseUser, profile, loading, error];
}

