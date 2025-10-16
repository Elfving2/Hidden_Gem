import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:hidden_gem/model/comment.dart';
import 'package:hidden_gem/model/user.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;
  // cant do like this dosent change when i logout
  //final user = auth.FirebaseAuth.instance.currentUser;

  Future<void> createUserIfNotExists(auth.User firebaseUser) async {
    final userRef = _firestore.collection('users').doc(firebaseUser.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      final appUser = AppUser.fromAuthUser(firebaseUser);
      await userRef.set(appUser.toMap());
    }
  }

  Future<String?> getUserIdByEmail(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }
    return null;
  }

  Future<bool> sendFriendRequest(String fromUserId) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (fromUserId == user!.uid) return false;

    await FirebaseFirestore.instance.collection('friend_requests').add({
      'fromUserId': user!.uid,
      'toUserId': fromUserId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
    return true;
  }

  Future<void> addToLiked(String postId) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    final userRef = _firestore.collection('users');

    // Add each other to the 'friends' arrays
    await Future.wait([
      userRef.doc(user!.uid).update({
        'liked': FieldValue.arrayUnion([postId]),
      }),
    ]);
  }

  Future<void> removeLiked(String postId) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    final userRef = _firestore.collection('users');

    await userRef.doc(user!.uid).update({
      'liked': FieldValue.arrayRemove([postId]),
    });
  }

  Future<void> commentOnPost(String message, String postId) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('post_comments').add({
      'message': message,
      'userId': user!.uid,
      'postId': postId,
    });
  }

  Stream<List<Comment>> getComments(String postId) {
    return FirebaseFirestore.instance
        .collection('post_comments')
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return Comment(
              message: data['message'],
              userId: data['userId'],
              postId: data['postId'],
            );
          }).toList(),
        );
  }

  Future<AppUser> getLoggedInUserData() async {
    final user = auth.FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    return AppUser.fromMap(user!.uid, doc.data()!);
  }

  Future<bool> saveProfile(String newName, String newDescription) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (newName == "" || newDescription == "") return false;
    await _firestore.collection('users').doc(user!.uid).update({
      'displayName': newName,
      'description': newDescription,
    });
    return true;
  }

  Future<AppUser> getUserById(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    return AppUser.fromMap(userId, doc.data()!);
  }

  Future<bool> hasLikedPost(String postId) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final data = doc.data();

    final List<dynamic> likes = data?['liked'] ?? [];

    if (likes.isEmpty) return false;

    if (likes.contains(postId)) {
      return true;
    }

    return false;
  }

  String getUser() {
    final user = auth.FirebaseAuth.instance.currentUser;
    print("USERID:  ${user!.uid}");
    return user.uid;
  }
}
