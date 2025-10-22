import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hidden_gem/model/hiddengem.dart';
import 'package:rxdart/rxdart.dart';

class HiddenGemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /* 
    Uplaod hidden gem to firebase
    For a gem to be accepted 
    You need atleast 
    * a description
    * Name 
    * atleast one image

    lattitide and longitude is set before typing in gem details
    then we add Gem to both current users list of gems
    and to gems collection feels perhaps a little stupid to add to two places?
    Come back to later and fix perhaps?
  */
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

  /*
    Get friends document ids from currently looged in users friends tab 
    returns document ids.
  */
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

  /*
    Boolean value to check if a post is the currently logged in users, i use this to make it possible for
    currently logged in user to delete their own gems on map and in profile
  */
  bool isUsersPost(String postOwner) {
    final user = FirebaseAuth.instance.currentUser;
    if (postOwner == user!.uid) return true;
    return false;
  }

  /* 
   Crazy method that need to be refactored its really shitty,
   but here is what it does:
   Gets users gems and adds it to a list both public and private
   Then gets all gems from friends only the public onces that current user has liked, then 
   it takes those ids of gems and maps them to the user that created those gems and combindes those gems 
   to one list so there is one list of current users gems and friends gems 
   I use a stream to get in real time updates so lets say we i i like a gem it wil directly appear on the map
   with a blue marker
  */
  Stream<List<HiddenGem>> getUserAndFriendsGems() {
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

    final friendsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .switchMap((userDoc) {
          final likedIds = List<String>.from(userDoc.data()?['liked'] ?? []);

          if (likedIds.isEmpty) {
            return Stream.value(<HiddenGem>[]);
          }

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

  /*
    Get friends gems by collection all friends document ids from friends field
    then we go to Gems collection and get all the public gems with friends doucment id
    and then create hidden gem objects from my model HiddenGem and put them inside a list to later display
    in the social media feed
  */
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

  /*
    Delete from gems collection using gem document id
  */
  Future<void> deleteFromGems(String gemId) async {
    await FirebaseFirestore.instance.collection('Gems').doc(gemId).delete();
  }

  /* Delete gem from users liked field*/
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

  // delete gem from owners gem field
  Future<void> removeGemFromOwner(String gemId) async {
    final user = FirebaseAuth.instance.currentUser;
    await _firestore.collection('users').doc(user!.uid).update({
      'gems': FieldValue.arrayRemove([gemId]),
    });
  }

  // remove comments from the deleted post using gems document id
  Future<void> removeCommentsFromDeletedPosts(String gemId) async {
    final querySnapshot = await _firestore
        .collection('post_comments')
        .where('postId', isEqualTo: gemId)
        .get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  /* 
    fetch both private and public gems from currently logged in user
  */
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

  // Like a post by incrementing like field by one
  Future<void> likePost(String postId) async {
    final userRef = _firestore.collection('Gems');

    await Future.wait([
      userRef.doc(postId).update({'likes': FieldValue.increment(1)}),
    ]);
  }
  /*
  Like a post by incrementing like field by -1 there is no decrement method or atleast not what i could
  find: https://stackoverflow.com/questions/55675911/fieldvalue-increment-for-cloud-firestore-in-flutter
  */

  Future<void> deLikePost(String postId) async {
    final userRef = _firestore.collection('Gems');

    await userRef.doc(postId).update({'likes': FieldValue.increment(-1)});
  }

  /*
    Validating for creating a gem 
    returns incorrect validation text if any of the parametes are empty
    if not empty creates the gem 
  */
  String validateGem(String name, String description, List<File> images) {
    if (name.isEmpty) return "Please enter a name!";

    if (description.isEmpty) return "Please enter a description!";

    if (images.isEmpty) return "Please add atleast one image!";
    return "";
  }
}
