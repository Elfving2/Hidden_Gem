import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hidden_gem/model/hiddengem.dart';
import 'package:rxdart/rxdart.dart';

class MarkerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  Future<List> fetchFriendsGems() async {
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
    if (postOwner == user!.uid) return true;
    return false;
  }

  Stream<List<HiddenGem>> getUserAndFriendsGems() {
    // Stream of your gems (private + public)
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
            );
          }).toList(),
        );

    // Stream of friends' public gems
    final friendsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
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
                  );
                }).toList(),
              );
        });

    // Combine both streams
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
      yield []; // No friends → no gems
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
            );
          }).toList();
        });
  }
}
