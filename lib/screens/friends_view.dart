import 'package:flutter/material.dart';
import 'package:hidden_gem/service/friend_request_service.dart';
import 'package:hidden_gem/service/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsView extends StatelessWidget {
  FriendsView({super.key});

  final TextEditingController emailController = TextEditingController();
  final UserService userService = UserService();
  final FriendRequestService friendRequestService = FriendRequestService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(child: Text("Friends")),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              showDialog(
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
                          decoration: const InputDecoration(
                            hintText: "email@example.com",
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final email = emailController.text.trim();
                            final uid = await userService.getUserIdByEmail(
                              email,
                            );

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
                        // Stream for incoming friend requests
                        SizedBox(
                          height: 250,
                          child: StreamBuilder<List<Map<String, dynamic>>>(
                            stream: friendRequestService
                                .getIncomingFriendRequests(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
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
                                    req['photoUrl'] ??
                                        'https://via.placeholder.com/150',
                                    onAccept: () => friendRequestService
                                        .updateRequestStatus(
                                          req['requestId'],
                                          "accept",
                                        ),
                                    onDecline: () => friendRequestService
                                        .updateRequestStatus(
                                          req['requestId'],
                                          "decline",
                                        ),
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
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: friendRequestService.getFriendsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No friends yet"));
          }

          final friends = snapshot.data!;

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return MockupFriend(
                friend['displayName'],
                friend['photoUrl'],
                friend['uid'],
                friendRequestService,
              );
            },
          );
        },
      ),
    );
  }
}

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
