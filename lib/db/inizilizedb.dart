import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class Inizilizedb {
  final db = FirebaseFirestore.instance;

  Future<void> collectionExists(
    String collectionName,
    Map<String, dynamic> fakeData,
  ) async {
    final snapshot = await db.collection(collectionName).limit(1).get();

    if (snapshot.docs.isEmpty) {
      log("Create collection: ${collectionName}");
      await db.collection(collectionName).doc('FAKE').set(fakeData);
    } else {
      log('$collectionName already exists.');
    }
  }

  Future<void> createGemDocument() async {
    final fakeGem = <String, dynamic>{
      'description': '',
      'images': [],
      'isPublic': true,
      'latitude': 56.18580151961529,
      'likes': 0,
      'longitude': 15.59553734958172,
      'name': '',
      'ownerId': '',
    };

    collectionExists("Gems", fakeGem);
  }

  Future<void> createFriendRequest() async {
    final fakeFriendRequest = <String, dynamic>{
      'fromUserId': '',
      'status': '',
      'timestamp': DateTime.now(),
      'toUserId': '',
    };
    collectionExists("friend_requests", fakeFriendRequest);
  }

  Future<void> createPostComments() async {
    final fakeComment = <String, dynamic>{
      'createdAt': '',
      'message': '',
      'postId': '',
      'userId': '',
    };
    collectionExists("post_comments", fakeComment);
  }

  Future<void> createUser() async {
    final fakeUser = <String, dynamic>{
      'description': '',
      'displayName': '',
      'email': '',
      'friends': [],
      'gems': [],
      'liked': [],
      'photoUrl': '',
    };
    collectionExists("users", fakeUser);
  }

  Future<void> createDocuments() async {
    createGemDocument();
    createFriendRequest();
    createPostComments();
    createUser();
  }
}
