import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/recipe.dart';

class RecipeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Recipe>> listByCategoryStream(String category) {
    final col = _db.collection('recipes');
    final query = category.toLowerCase() == 'all'
        ? col.orderBy('createdAt', descending: true)
        : col.where('category', isEqualTo: category).orderBy('createdAt', descending: true);
    return query.snapshots().map(
      (s) => s.docs.map((d) => Recipe.fromMap(d.id, d.data())).toList(),
    );
  }

  Future<List<Recipe>> search(String titleQuery, String? category) async {
    final col = _db.collection('recipes');
    final base = (category == null || category.toLowerCase() == 'all')
        ? col
        : col.where('category', isEqualTo: category);
    final qs = await base
        .where('titleLower', isGreaterThanOrEqualTo: titleQuery.toLowerCase())
        .where('titleLower', isLessThan: '${titleQuery.toLowerCase()}\uf8ff')
        .get();
    return qs.docs.map((d) => Recipe.fromMap(d.id, d.data())).toList();
  }

  Future<void> addRecipe(Recipe recipe) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Not signed in');
    final map = recipe.toMap()
      ..addAll({
        'ownerId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    await _db.collection('recipes').add(map);
  }

  Future<void> updateRecipe(String id, Map<String, Object?> updates) async {
    final merged = Map<String, Object?>.from(updates);
    if (merged['title'] is String) {
      merged['titleLower'] = (merged['title'] as String).toLowerCase();
    }
    merged['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('recipes').doc(id).update(merged);
  }

  Future<void> deleteRecipe(String id) async {
    await _db.collection('recipes').doc(id).delete();
  }

  Future<List<Recipe>> listUserRecipes(String uid) async {
    final qs = await _db
        .collection('recipes')
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return qs.docs.map((d) => Recipe.fromMap(d.id, d.data())).toList();
  }
}



