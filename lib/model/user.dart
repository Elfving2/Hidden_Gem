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
  final List<String> liked;

  AppUser({
    required this.id,
    required this.displayName,
    required this.photoUrl,
    required this.email,
    required this.description,
    required this.friends,
    required this.gems,
    required this.liked,
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
      liked: [],
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
      'liked': liked,
    };
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      description: map['description'] ?? '',
      email: map['email'] ?? '',
      friends: List<String>.from(map['friends'] ?? []),
      gems: List<String>.from(map['gems'] ?? []),
      liked: List<String>.from(map['liked'] ?? []),
    );
  }

  Future<void> saveChanges() async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(id);
    await userRef.update(toMap());
  }
}
