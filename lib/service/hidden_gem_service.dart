import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hidden_gem/model/hiddengem.dart';
import 'package:rxdart/rxdart.dart';

class HiddenGemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<bool> uploadHiddenGem(
    String name,
    String description,
    List<String> images,
    LatLng selectedPosition,
    bool isPublic,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final gemRef = await FirebaseFirestore.instance.collection("Gems").add({
        "name": name,
        "description": description,
        "images": images,
        "latitude": selectedPosition.latitude,
        "longitude": selectedPosition.longitude,
        "ownerId": user!.uid,
        "isPublic": isPublic,
        "likes": 0,
      });

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'gems': FieldValue.arrayUnion([gemRef.id]),
        },
      );

      return true;
    } catch (e) {
      print("Error uploading gem: $e");
      return false;
    }
  }

  Future<List> fetchFriendsGems() async {
    final user = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    List<String> friendIds = List<String>.from(
      userDoc.data()?['friends'] ?? [],
    );

    return friendIds;
  }

  bool isUsersPost(String postOwner) {
    final user = FirebaseAuth.instance.currentUser;
    if (postOwner == user!.uid) return true;
    return false;
  }

  Stream<List<HiddenGem>> getUserAndFriendsGems() {
    // Stream of your gems (private + public)
    final user = FirebaseAuth.instance.currentUser;
    final myGemsStream = _firestore
        .collection('Gems')
        .where('ownerId', isEqualTo: user!.uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return HiddenGem(
              id: doc.id,
              name: data['name'],
              description: data['description'],
              latitude: data['latitude'],
              longitude: data['longitude'],
              imageUrls: List<String>.from(data['images'] ?? []),
              ownerId: data['ownerId'],
              isPublic: data['isPublic'],
              likes: data['likes'],
            );
          }).toList(),
        );

    // Stream of friends' public gems
    final friendsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .switchMap((userDoc) {
          final likedIds = List<String>.from(userDoc.data()?['liked'] ?? []);

          if (likedIds.isEmpty) {
            // return an empty list stream if no liked gems
            return Stream.value(<HiddenGem>[]);
          }

          // fetch only gems whose IDs are in the liked list
          return _firestore
              .collection('Gems')
              .where(FieldPath.documentId, whereIn: likedIds)
              .snapshots()
              .map(
                (snapshot) => snapshot.docs.map((doc) {
                  final data = doc.data();
                  return HiddenGem(
                    id: doc.id,
                    name: data['name'],
                    description: data['description'],
                    latitude: data['latitude'],
                    longitude: data['longitude'],
                    imageUrls: List<String>.from(data['images'] ?? []),
                    ownerId: data['ownerId'],
                    isPublic: data['isPublic'],
                    likes: data['likes'],
                  );
                }).toList(),
              );
        });

    return Rx.combineLatest2<List<HiddenGem>, List<HiddenGem>, List<HiddenGem>>(
      myGemsStream,
      friendsStream,
      (myGems, friendsGems) => [...myGems, ...friendsGems],
    );
  }

  Stream<List<HiddenGem>> getFriendsGems() async* {
    final currentUser = FirebaseAuth.instance.currentUser;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    List<String> friendIds = List<String>.from(
      userDoc.data()?['friends'] ?? [],
    );

    if (friendIds.isEmpty) {
      yield [];
      return;
    }

    yield* FirebaseFirestore.instance
        .collection('Gems')
        .where('ownerId', whereIn: friendIds)
        .where('isPublic', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return HiddenGem(
              id: doc.id,
              name: data['name'],
              description: data['description'],
              latitude: data['latitude'],
              longitude: data['longitude'],
              imageUrls: List<String>.from(data['images'] ?? []),
              ownerId: data['ownerId'],
              isPublic: data['isPublic'],
              likes: data['likes'],
            );
          }).toList();
        });
  }

  Future<void> deleteFromGems(String gemId) async {
    await FirebaseFirestore.instance.collection('Gems').doc(gemId).delete();
  }

  Future<void> deleteGemFromLiked(String gemId) async {
    final usersSnapshot = await _firestore
        .collection('users')
        .where('liked', arrayContains: gemId)
        .get();

    for (final doc in usersSnapshot.docs) {
      await doc.reference.update({
        'liked': FieldValue.arrayRemove([gemId]),
      });
    }
  }

  Future<void> removeGemFromOwner(String gemId) async {
    final user = FirebaseAuth.instance.currentUser;
    await _firestore.collection('users').doc(user!.uid).update({
      'gems': FieldValue.arrayRemove([gemId]),
    });
  }

  Future<void> removeCommentsFromDeletedPosts(String gemId) async {
    final querySnapshot = await _firestore
        .collection('post_comments')
        .where('postId', isEqualTo: gemId)
        .get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Stream<List<HiddenGem>> getUsersGems() {
    final user = FirebaseAuth.instance.currentUser;

    return FirebaseFirestore.instance
        .collection('Gems')
        .where('ownerId', isEqualTo: user!.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return HiddenGem(
              id: doc.id,
              name: data['name'],
              description: data['description'],
              latitude: data['latitude'],
              longitude: data['longitude'],
              imageUrls: List<String>.from(data['images'] ?? []),
              ownerId: data['ownerId'],
              isPublic: data['isPublic'],
              likes: data['likes'],
            );
          }).toList();
        });
  }

  Future<void> likePost(String postId) async {
    final userRef = _firestore.collection('Gems');

    await Future.wait([
      userRef.doc(postId).update({'likes': FieldValue.increment(1)}),
    ]);
  }

  Future<void> deLikePost(String postId) async {
    final userRef = _firestore.collection('Gems');

    await userRef.doc(postId).update({'likes': FieldValue.increment(-1)});
  }

  String validateGem(String name, String description, List<File> images) {
    if (name.isEmpty) return "Please enter a name!";

    if (description.isEmpty) return "Please enter a description!";

    if (images.isEmpty) return "Please add atleast one image!";
    return "";
  }
}
