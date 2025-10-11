import 'dart:developer';

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

  Future<List<Map<String, dynamic>>> getFriends() async {
    final currentUser = _auth.currentUser;

    final userData = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    if (!userData.exists) return [];

    print("UserData:  ${userData['friends']}");

    List<dynamic> friendIds = userData['friends'] ?? [];

    if (friendIds.isEmpty) return [];

    // Fetch all friend documents by ID
    List<Map<String, dynamic>> friends = [];

    for (String friendId in friendIds) {
      final friendDoc = await _firestore
          .collection('users')
          .doc(friendId)
          .get();

      print("friends: ${friendDoc.data()}");

      friends.add({
        'displayName': friendDoc['displayName'],
        'photoUrl': friendDoc['photoUrl'],
      });
    }
    return friends;
  }
}
