import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestService {
  final _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getIncomingFriendRequests() {
    return _firestore
        .collection('friend_requests')
        .where('toUserId', isEqualTo: _auth.currentUser!.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snapshot) async {
          // For each friend request, also fetch user info
          final requests = await Future.wait(
            snapshot.docs.map((doc) async {
              final data = doc.data();
              data['requestId'] = doc.id;

              // Fetch the sender’s user document
              final fromUserRef = _firestore
                  .collection('users')
                  .doc(data['fromUserId']);
              final fromUserSnap = await fromUserRef.get();

              if (fromUserSnap.exists) {
                final fromUserData = fromUserSnap.data()!;
                data['displayName'] =
                    fromUserData['displayName'] ?? 'Unknown User';
                data['photoUrl'] =
                    fromUserData['photoUrl'] ??
                    'https://via.placeholder.com/150';
                data['email'] = fromUserData['email'] ?? '';
              }

              return data;
            }).toList(),
          );
          return requests;
        });
  }

  // Can be both deny and accept
  Future<void> updateRequestStatus(String requestId, String status) async {
    final requestRef = _firestore.collection('friend_requests').doc(requestId);
    final requestSnapshot = await requestRef.get();

    if (!requestSnapshot.exists) return;

    final data = requestSnapshot.data()!;
    final fromUid = data['fromUserId'];
    final toUid = data['toUserId'];

    // Update the request status (accept or decline)
    await requestRef.update({'status': status});

    if (status == 'accept') {
      final userRef = _firestore.collection('users');

      // Add each other to the 'friends' arrays
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

  Stream<List<Map<String, dynamic>>> getFriendsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((userDoc) {
          List<dynamic> friendIdsDynamic = userDoc.data()?['friends'] ?? [];
          List<String> friendIds = friendIdsDynamic.cast<String>();

          // Build a list of friend Futures
          return Future.wait(
            friendIds.map((friendId) async {
              final friendDoc = await _firestore
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

  Future<void> removeFriend(String friendUid) async {
    final currentUser = _auth.currentUser;
    final userRef = FirebaseFirestore.instance.collection('users');

    // Remove friendUid from current user's friends array
    await userRef.doc(currentUser!.uid).update({
      'friends': FieldValue.arrayRemove([friendUid]),
    });

    // Remove current user from friend's friends array
    await userRef.doc(friendUid).update({
      'friends': FieldValue.arrayRemove([currentUser.uid]),
    });
  }
}
