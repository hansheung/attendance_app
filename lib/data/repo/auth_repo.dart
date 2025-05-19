import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return credential.user;
  }

  Future<void> register(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'email': email,
      'isAdmin': false,
    });
  }

  Future<bool> isAdmin(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['isAdmin'] ?? false;
  }
}
