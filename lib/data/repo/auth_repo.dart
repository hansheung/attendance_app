import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login(String email, String password) async {
    final credential =
        await _auth.signInWithEmailAndPassword(email: email, password: password);
    return credential.user;
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String deviceId,
  }) async {
    final credential =
        await _auth.createUserWithEmailAndPassword(email: email, password: password);

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'name': name,
      'email': email,
      'phone': phone,
      'isAdmin': false,
      'deviceId': deviceId,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'lastLoggedIn': DateTime.now().toUtc().toIso8601String(),
      'logoutAt': null,
    });
  }
 
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<bool> isEmailRegistered(String email) async {
    final methods = await _auth.fetchSignInMethodsForEmail(email);
    return methods.isNotEmpty;
  }

  Future<bool> isAdmin(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['isAdmin'] ?? false;
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<String> getDeviceId() async {
    final plugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        return info.id;
      } else if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        return info.identifierForVendor ?? 'unknown-ios';
      }
    } catch (_) {
      // Fallback to avoid crashing when device info is unavailable.
    }
    return 'unknown';
  }

  Future<void> logout() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'logoutAt': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (_) {
        // Best effort logging; ignore failure so logout can proceed.
      }
    }
    await _auth.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
