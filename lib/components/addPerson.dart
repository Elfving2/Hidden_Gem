import 'package:flutter/material.dart';
import 'package:hidden_gem/components/friendRequest.dart';
import 'package:hidden_gem/service/friend_request_service.dart';
import 'package:hidden_gem/service/user_services.dart';

final UserService userService = UserService();

Future<void> addPerson(
  BuildContext context,
  TextEditingController emailController,
  FriendRequestService friendRequestService,
) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Add Friend"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(hintText: "email@example.com"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final uid = await userService.getUserIdByEmail(email);

                if (uid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User not found")),
                  );
                  return;
                }

                String message = "Something went wrong!";
                if (await userService.sendFriendRequest(uid)) {
                  message = "Friend request sent successfully!";
                }

                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              },
              child: const Text("Send Friend Request"),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: friendRequestService.getIncomingFriendRequests(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final requests = snapshot.data!;
                  if (requests.isEmpty) {
                    return const Center(
                      child: Text("No pending friend requests"),
                    );
                  }

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      return MockupFriendRequest(
                        req['displayName'] ?? "Unknown User",
                        req['photoUrl'] ?? 'https://via.placeholder.com/150',
                        onAccept: () => friendRequestService
                            .updateRequestStatus(req['requestId'], "accept"),
                        onDecline: () => friendRequestService
                            .updateRequestStatus(req['requestId'], "decline"),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
