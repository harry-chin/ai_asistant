import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveMessage(String userId, String message) async {
    await _firestore.collection('messages').add({
      'userId': userId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessages() {
    return _firestore.collection('messages').orderBy('timestamp').snapshots();
  }
}
