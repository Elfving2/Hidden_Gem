import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:hidden_gem/model/user.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;
  final user = auth.FirebaseAuth.instance.currentUser;

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
    if (fromUserId == user!.uid) return false;

    await FirebaseFirestore.instance.collection('friend_requests').add({
      'fromUserId': user!.uid,
      'toUserId': fromUserId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
    return true;
  }
}
