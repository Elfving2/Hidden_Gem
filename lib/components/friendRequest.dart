import 'package:flutter/material.dart';

/*
  Builds the friendRequest card where you can accept or denied a friend request 
*/
class FriendRequestCard extends StatelessWidget {
  final String fullName;
  final String profilePicture;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const FriendRequestCard({
    super.key,
    required this.fullName,
    required this.profilePicture,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(profilePicture),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fullName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onDecline,
                  icon: const Icon(Icons.close, color: Colors.grey),
                  label: const Text(
                    "Decline",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check),
                  label: const Text("Accept"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
