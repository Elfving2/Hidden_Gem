import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

/* 
  * id - document id 
  * displayName - name that users see example comments or social media feed name displayed
  * photourl - image url from google 
  * email - email of user. Used to add friends
  * description - short description about the user
  * friends - list of document id of other users, this user is friends with
  * gems - users own created gems
  * liked - gems of friends user has liked (gem document id)
*/
class User {
  final String id;
  final String displayName;
  final String photoUrl;
  final String email;
  final String description;
  final List<String> friends;
  final List<String> gems;
  final List<String> liked;

  User({
    required this.id,
    required this.displayName,
    required this.photoUrl,
    required this.email,
    required this.description,
    required this.friends,
    required this.gems,
    required this.liked,
  });

  factory User.fromAuthUser(auth.User user) {
    return User(
      id: user.uid,
      displayName: user.displayName ?? '',
      photoUrl: user.photoURL ?? '',
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

  factory User.fromMap(String id, Map<String, dynamic> map) {
    return User(
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
