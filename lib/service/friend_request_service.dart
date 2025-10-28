import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hidden_gem/service/user_services.dart';

/* 
  Friend request service 
*/
class FriendRequestService {
  final firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  UserService userService = UserService();

  /* 
  fetch all pending fromUiserIds from currently logged in user 
*/
  Future<Map<String, String>> getPendingFriendRequestUid() async {
    final snapshot = await firestore
        .collection('friend_requests')
        .where('toUserId', isEqualTo: auth.currentUser!.uid)
        .where('status', isEqualTo: 'pending')
        .get();

    final Map<String, String> requests = {
      for (var doc in snapshot.docs) doc.id: doc.data()['fromUserId'] as String,
    };

    return requests;
  }

  /*
    return the requestId - the id of the friendRequest 
    also return displayname and photo of the user sending the friend request
   */
  Stream<List<Map<String, dynamic>>> getIncomingFriendRequests() async* {
    final uidPendingRequests = await getPendingFriendRequestUid();
    print("uidPendingRequests: ${uidPendingRequests}");

    if (uidPendingRequests.isEmpty) {
      yield <Map<String, dynamic>>[];
      return;
    }

    final requests = await Future.wait(
      uidPendingRequests.entries.map((entry) async {
        final requestId = entry.key;
        final fromUserId = entry.value;

        final user = await userService.getUserById(fromUserId);

        return {
          "requestId": requestId,
          "displayName": user.displayName,
          "photoUrl": user.photoUrl,
        };
      }),
    );

    yield requests;
  }

  /*
  "Generic" method that lets the user either deny och accept pending friend request
  */
  Future<void> updateRequestStatus(String requestId, String status) async {
    final requestRef = firestore.collection('friend_requests').doc(requestId);
    final requestSnapshot = await requestRef.get();

    if (!requestSnapshot.exists) return;

    final data = requestSnapshot.data()!;
    final fromUid = data['fromUserId'];
    final toUid = data['toUserId'];

    await requestRef.update({'status': status});

    if (status == 'accept') {
      final userRef = firestore.collection('users');
      await Future.wait([
        userRef.doc(fromUid).update({
          'friends': FieldValue.arrayUnion([toUid]),
        }),
        userRef.doc(toUid).update({
          'friends': FieldValue.arrayUnion([fromUid]),
        }),
      ]);
    }
  }

  // Get currently logged in users friends in a stream so we get updates in real time
  Stream<List<Map<String, dynamic>>> getFriendsStream() {
    final currentUser = auth.currentUser;
    if (currentUser == null) return const Stream.empty();

    return firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((userDoc) {
          List<dynamic> friendIdsDynamic = userDoc.data()?['friends'] ?? [];
          List<String> friendIds = friendIdsDynamic.cast<String>();

          return Future.wait(
            friendIds.map((friendId) async {
              final friendDoc = await firestore
                  .collection('users')
                  .doc(friendId)
                  .get();
              if (!friendDoc.exists) return null;

              final data = friendDoc.data()!;
              return {
                'uid': friendDoc.id,
                'displayName': data['displayName'],
                'photoUrl': data['photoUrl'],
              };
            }).toList(),
          ).then(
            (friends) => friends.whereType<Map<String, dynamic>>().toList(),
          );
        })
        .asyncMap((event) async => await event);
  }

  // Remove friend from friends array and remove currently logged in user from friends array
  Future<void> removeFriend(String friendUid) async {
    final currentUser = auth.currentUser;
    final userRef = FirebaseFirestore.instance.collection('users');

    await userRef.doc(currentUser!.uid).update({
      'friends': FieldValue.arrayRemove([friendUid]),
    });

    await userRef.doc(friendUid).update({
      'friends': FieldValue.arrayRemove([currentUser.uid]),
    });
  }

  // fetch all friends gems so we can remove them from current users liked post
  Future<List<String>> getFriendsGemsId(String friendUid) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(friendUid)
        .get();

    final data = userDoc.data();
    final gems = List<String>.from(data?['gems'] ?? []);
    print("GEMS: ${gems}");
    return gems;
  }

  /*
    Remove friends gems from liked list when removing friend
  */
  Future<void> removeFriendsGemsFromCurrentlyLoggedInUsersLikedList(
    String friendUid,
  ) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    final myRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid);
    final mySnap = await myRef.get();
    final myData = mySnap.data();

    final myLikedPosts = List<String>.from(myData?['liked'] ?? []);
    final friendGemIds = await getFriendsGemsId(friendUid);

    final postsToRemove = myLikedPosts.where(friendGemIds.contains).toList();
    if (postsToRemove.isEmpty) return;

    await myRef.update({'liked': FieldValue.arrayRemove(postsToRemove)});

    print("Removed friend's gems: $postsToRemove");
  }

  /*
    Remove currently logged in users gems from friends liked list when removing friend
  */

  Future<void> removeCurrentlyLoggedInUsersGemsFromFriendsLikedList(
    String friendUid,
  ) async {
    final currentUser = auth.currentUser;

    final friendRef = FirebaseFirestore.instance
        .collection('users')
        .doc(friendUid);
    final friendSnap = await friendRef.get();
    final friendData = friendSnap.data();

    final friendLikedPosts = List<String>.from(friendData?['liked'] ?? []);
    final myGemIds = await getFriendsGemsId(currentUser!.uid);

    final postsToRemove = friendLikedPosts.where(myGemIds.contains).toList();
    if (postsToRemove.isEmpty) return;

    await friendRef.update({'liked': FieldValue.arrayRemove(postsToRemove)});

    print("Removed my gems $postsToRemove");
  }
}
