import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:hidden_gem/model/comment.dart';
import 'package:hidden_gem/model/user.dart';
import 'package:intl/intl.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;
  /*
    cannot use this:
    final user = auth.FirebaseAuth.instance.currentUser;
    as a class variable becuase of phone caches user even when i logout so have to call 
    it in every function so it checks for the current logged in user not the cashed user 
  */

  // Create user if it dosent exist when creating account with google for the first time
  Future<void> createUserIfNotExists(auth.User firebaseUser) async {
    final userRef = _firestore.collection('users').doc(firebaseUser.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      final appUser = User.fromAuthUser(firebaseUser);
      await userRef.set(appUser.toMap());
    }
  }

  /*
  Fetch user by email if email dosent exist user dosent exist return null then
 */
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

  /*
    send friendrequest using uid = document id in firebase ex: ZV5JFqA6TEYRYrC1vTyQyW7RhiA1
    is an example of an uid
    This creates a row in friend_requests displaying
    * Sent from
    * pending - as in hasnt accepted or denied the request 
    * sent to
 */
  Future<bool> sendFriendRequest(String fromUserId) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (fromUserId == user!.uid) return false;

    await FirebaseFirestore.instance.collection('friend_requests').add({
      'fromUserId': user.uid,
      'toUserId': fromUserId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
    return true;
  }

  /*
    add friends gem to liked list in user collection under the current logged in users liked posts
  */
  Future<void> addToLiked(String postId) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    final userRef = _firestore.collection('users');

    await Future.wait([
      userRef.doc(user!.uid).update({
        'liked': FieldValue.arrayUnion([postId]),
      }),
    ]);
  }

  /*
    Dose the opposite of addToLiked removes liked post from liked list
  */
  Future<void> removeLiked(String postId) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    final userRef = _firestore.collection('users');

    await userRef.doc(user!.uid).update({
      'liked': FieldValue.arrayRemove([postId]),
    });
  }

  /*
    comment on a post by sending in parametes message, and post document id 
    adds to firebase comment document
    * message
    * user document id
    * post document id
    * and when the comment was made in the format of (yyyy-MM-dd HH:mm)
  */
  Future<void> commentOnPost(String message, String postId) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('post_comments').add({
      'message': message,
      'userId': user!.uid,
      'postId': postId,
      'createdAt': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    });
  }

  /*
 Fetch all the comments for as specific post using post document id
 displays all comments returns
 * message
 *  user document id - so i later can get the users informaton and display it to the user
 * post document id so i know what post every comment was made on so when i click i get the correct post
 * created at is also displayed with the user once i fetched user information i display it with it
 */
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
              createdAt: data['createdAt'],
            );
          }).toList(),
        );
  }

  /*
    fetch currentlyLogged in user data in this case it means everything from the user model
    * liked gems
    * descriptio
    * display name
    * photourl
    * friends
    * email 
    * owned gems 
  */
  Future<User> getLoggedInUserData() async {
    final user = auth.FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    return User.fromMap(user.uid, doc.data()!);
  }

  /*
    Save everything user has typed inside textfields of the edit_profile_view 
    in my case its description and display name
    description isnt that important but display name is what friends see as the name of the user 
    so if i change name to "Bob" all friends will see you now as "Bob"
  */
  Future<bool> saveProfile(String newName, String newDescription) async {
    final user = auth.FirebaseAuth.instance.currentUser;
    if (newName == "" || newDescription == "") return false;
    await _firestore.collection('users').doc(user!.uid).update({
      'displayName': newName,
      'description': newDescription,
    });
    return true;
  }

  /* 
    Fetch user by document id
  */
  Future<User> getUserById(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    return User.fromMap(userId, doc.data()!);
  }

  /*
    boolean to see if currenty looged in user has liked a gem used to display red heart if liked post previously
    to display a read heart or a grey heart
  */
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

  /*
   Get currentlyLogged in user information
   */
  String getUser() {
    final user = auth.FirebaseAuth.instance.currentUser;
    print("USERID:  ${user!.uid}");
    return user.uid;
  }
}
