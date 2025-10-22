import 'package:flutter/material.dart';
import 'package:hidden_gem/service/friend_request_service.dart';
import 'package:hidden_gem/service/user_services.dart';

/*
  Builds the friendsView displays your friends with a remove button
  Note: addded a nice confirm removal just to make sure the user dosent acedently press remove
*/
class FriendTile extends StatelessWidget {
  final String fullName;
  final String profilePicture;
  final String uid;
  final friendRequestService = FriendRequestService();
  final userService = UserService();

  FriendTile({
    super.key,
    required this.fullName,
    required this.profilePicture,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(profilePicture),
        radius: 26,
      ),
      title: Text(fullName),
      trailing: TextButton.icon(
        icon: const Icon(Icons.person_remove, color: Colors.red),
        label: const Text("Remove", style: TextStyle(color: Colors.red)),
        onPressed: () => _confirmRemoval(context),
      ),
    );
  }

  void _confirmRemoval(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Are you sure you want to remove $fullName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      friendRequestService.removeFriend(uid);
      // Also remove every liked post from user where owner is removed friend user
      friendRequestService.removeFriendsGemsFromCurrentlyLoggedInUsersLikedList(
        uid,
      );
      friendRequestService.removeCurrentlyLoggedInUsersGemsFromFriendsLikedList(
        uid,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$fullName has been removed')));
    }
  }
}
