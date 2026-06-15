import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Observable auth state
  Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    currentUser.bindStream(_auth.authStateChanges());
  }

  String? get uid => _auth.currentUser?.uid;
  bool get isLoggedIn => _auth.currentUser != null;

  // ─── Google Sign In ───────────────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);

      // Create user doc if new
      if (userCred.additionalUserInfo?.isNewUser == true) {
        await _createUserDoc(userCred.user!);
      }
      return userCred;
    } catch (e) {
      Get.snackbar('Sign In Failed', e.toString(),
          backgroundColor: const Color(0xFFFF4444),
          colorText: const Color(0xFFFFFFFF));
      return null;
    }
  }

  // ─── Email/Password Register ──────────────────────────────────────────────
  Future<UserCredential?> registerWithEmail(String name, String email, String password) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
      await userCred.user?.updateDisplayName(name);
      await _createUserDoc(userCred.user!, name: name);
      return userCred;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Registration Failed', e.message ?? 'Unknown error',
          backgroundColor: const Color(0xFFFF4444),
          colorText: const Color(0xFFFFFFFF));
      return null;
    }
  }

  // ─── Email/Password Login ─────────────────────────────────────────────────
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Failed', e.message ?? 'Unknown error',
          backgroundColor: const Color(0xFFFF4444),
          colorText: const Color(0xFFFFFFFF));
      return null;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    Get.offAllNamed('/login');
  }

  // ─── Internal: Create Firestore User Document ─────────────────────────────
  Future<void> _createUserDoc(User user, {String? name}) async {
    await _db.collection('users').doc(user.uid).set({
      'name': name ?? user.displayName ?? 'Viora User',
      'email': user.email ?? '',
      'profileImage': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
