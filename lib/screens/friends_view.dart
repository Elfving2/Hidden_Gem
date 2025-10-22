import 'package:flutter/material.dart';
import 'package:hidden_gem/components/addPerson.dart';
import 'package:hidden_gem/components/friend.dart';
import 'package:hidden_gem/service/friend_request_service.dart';

class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => FriendsViewState();
}

class FriendsViewState extends State<FriendsView> {
  final TextEditingController emailController = TextEditingController();
  final FriendRequestService friendRequestService = FriendRequestService();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

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
              showAddFriendDialog(
                context,
                emailController,
                friendRequestService,
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
              return FriendTile(
                fullName: friend['displayName'],
                profilePicture: friend['photoUrl'],
                uid: friend['uid'],
              );
            },
          );
        },
      ),
    );
  }
}
