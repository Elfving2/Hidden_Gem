import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class AppUser {
  final String id;
  final String displayName;
  final String photoUrl;
  final String email;
  final String description;
  final List<String> friends;
  final List<String> gems;

  AppUser({
    required this.id,
    required this.displayName,
    required this.photoUrl,
    required this.email,
    required this.description,
    required this.friends,
    required this.gems,
  });

  factory AppUser.fromAuthUser(auth.User user) {
    return AppUser(
      id: user.uid,
      displayName: user.displayName ?? '',
      photoUrl: user.photoURL ?? '', // ill send in another image
      email: user.email ?? '',
      description: '',
      friends: [],
      gems: [],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'photoUrl': photoUrl,
      'description': description,
      'email': email,
      'friends': friends,
      'gems': gems,
    };
  }

  Future<void> saveChanges() async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(id);
    await userRef.update(toMap());
  }
}
