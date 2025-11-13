import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final snap = await _db.collection('users').doc(user.uid).get();
    if (!snap.exists) return null;
    return AppUser.fromMap(snap.data()!);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String country,
    String photoUrl = '',
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;

    final userMap = {
      'uid': uid,
      'name': name,
      'email': email,
      'country': country,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _db.collection('users').doc(uid).set(userMap);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }
}



