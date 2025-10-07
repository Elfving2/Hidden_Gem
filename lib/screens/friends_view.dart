import 'package:flutter/material.dart';

class FriendsView extends StatelessWidget {
  const FriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("Friends")),
        actions: [
          //action is used to move the icon the the far right
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              // Logout
            },
          ),
        ],
      ),
      body: Column(
        children: [
          MockupFriendRequest(
            "Simone Elfving",
            "https://images.pexels.com/photos/33506116/pexels-photo-33506116.jpeg",
          ),
          MockupFriendRequest(
            "Robert Jones",
            "https://images.pexels.com/photos/33875524/pexels-photo-33875524.jpeg",
          ),
          MockupFriendRequest(
            "Matilda Elfving",
            "https://images.pexels.com/photos/33594736/pexels-photo-33594736.jpeg",
          ),
          MockupFriendRequest(
            "Nellie",
            "https://images.pexels.com/photos/3687770/pexels-photo-3687770.jpeg",
          ),
          MockupFriendRequest(
            "Aslan",
            "https://images.pexels.com/photos/220938/pexels-photo-220938.jpeg",
          ),
        ],
      ),
    );
  }
}

// Remove later to one component (one in friend_request_view) as well
Widget MockupFriendRequest(String fullName, String profilePicture) {
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
