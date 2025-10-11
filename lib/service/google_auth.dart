import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hidden_gem/service/user_services.dart';

class FirebaseService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final user = FirebaseAuth.instance.currentUser;
  final UserService userService = UserService();

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    final firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      await userService.createUserIfNotExists(firebaseUser);
    }

    return userCredential;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
  }

  ImageProvider getUserImage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
      return NetworkImage(user.photoURL!);
    } else {
      return const AssetImage('assets/images/stockUrlImage.jpg');
    }
  }
}
