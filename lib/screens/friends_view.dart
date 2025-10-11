import 'package:flutter/material.dart';
import 'package:hidden_gem/service/friend_request_service.dart';
import 'package:hidden_gem/service/user_services.dart';

class FriendsView extends StatelessWidget {
  FriendsView({super.key});
  final TextEditingController emailController = TextEditingController();
  UserService userService = UserService();
  FriendRequestService friendRequestService = FriendRequestService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("Friends")),
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
                            //friendRequestService.getFriends();
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
                              message = "Friend request was sent successfully!";
                            }

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                            Navigator.of(context).pop();
                          },
                          child: const Text("Send Friend Request"),
                        ),
                        const SizedBox(height: 16),

                        // 👇 Wrap the StreamBuilder output in a SizedBox
                        SizedBox(
                          height:
                              250, // or MediaQuery.of(context).size.height * 0.4
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
                                shrinkWrap: true,
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: friendRequestService
            .getFriends(), // your new getFriends() method
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
              return MockupFriend(friend['displayName'], friend['photoUrl']);
            },
          );
        },
      ),
    );
  }
}

// Remove later to one component (one in friend_request_view) as well
Widget MockupFriend(String fullName, String profilePicture) {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(profilePicture),
              ),
              const SizedBox(width: 12),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(fullName)],
                ),
              ),
            ],
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(fullName)],
                ),
              ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: const Size(120, 40),
                ),
                child: const Text("Accept"),
              ),
              const SizedBox(width: 30),
              ElevatedButton(
                onPressed: onDecline,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
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
