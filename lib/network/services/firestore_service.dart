import 'package:cloud_firestore/cloud_firestore.dart';

abstract class DatabaseService {
  Future<void> addData({required String path, required Map<String, dynamic> data}) async {
  }
}

class FirestoreService implements DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.doc(path).set(data);
    } catch (e) {
      print('Error saving to Firestore: $e');
      rethrow;
    }
  }
}
