import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadUserPhoto({required String uid, required File file}) async {
    final ref = _storage.ref('userPhotos/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  Future<String> uploadRecipeImage({required String uid, required File file}) async {
    final ref = _storage.ref('recipeImages/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }
}



