import 'package:flutter/material.dart';
import 'package:hidden_gem/service/friend_request_service.dart';

Widget MockupFriend(
  String fullName,
  String profilePicture,
  String uid,
  FriendRequestService service,
) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(profilePicture),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(fullName, style: const TextStyle(fontSize: 16))),
          ElevatedButton(
            onPressed: () async {
              await service.removeFriend(uid);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Remove"),
          ),
        ],
      ),
    ),
  );
}
