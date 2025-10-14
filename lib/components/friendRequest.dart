import 'package:flutter/material.dart';

Widget MockupFriendRequest(
  String fullName,
  String profilePicture, {
  required VoidCallback onAccept,
  required VoidCallback onDecline,
}) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(profilePicture),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(fullName)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(120, 40),
                ),
                child: const Text("Accept"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: onDecline,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  minimumSize: const Size(120, 40),
                ),
                child: const Text("Decline"),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
