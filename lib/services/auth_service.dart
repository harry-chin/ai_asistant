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
    await _firestore.collection('users').doc(uid).update({
      'categories': chatHistory,
    });
  }

  Future<Map<String, List<Map<String, String>>>> loadCategoriesAndChatHistory(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    return Map<String, List<Map<String, String>>>.from(doc['categories']);
  }
}
