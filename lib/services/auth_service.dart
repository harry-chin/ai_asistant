import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'categories': {},
      });
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> saveCategoriesAndChatHistory(String uid, Map<String, List<Map<String, String>>> chatHistory) async {
    await _firestore.collection('users').doc(uid).set({
      'categories': chatHistory,
    }, SetOptions(merge: true));
  }

  Future<Map<String, List<Map<String, String>>>> loadCategoriesAndChatHistory(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Map<String, List<Map<String, String>>> categories = {};
      data['categories']?.forEach((key, value) {
        List<Map<String, String>> messages = List<Map<String, String>>.from(value.map((item) => Map<String, String>.from(item)));
        categories[key] = messages;
      });
      return categories;
    }
    return {};
  }
}
