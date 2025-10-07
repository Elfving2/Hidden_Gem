import 'package:flutter/material.dart';

class FriendRequestView extends StatelessWidget {
  const FriendRequestView({super.key});

  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("Friend Requests")),
      ),
      body: Column(
        children: [
          MockupFriendRequest(
            "Sebastian Elfving",
            "https://images.pexels.com/photos/14661/pexels-photo-14661.jpeg",
          ),
          MockupFriendRequest(
            "Erik Nilsson",
            "https://images.pexels.com/photos/41008/cowboy-ronald-reagan-cowboy-hat-hat-41008.jpeg",
          ),
          MockupFriendRequest(
            "Julius Bilén",
            "https://images.pexels.com/photos/7823/selfie.jpg",
          ),
        ],
      ),
    );
  }
}

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

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => {},

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // sharp corners
                  ),
                  minimumSize: const Size(120, 40),
                ),
                child: const Text("Accept"),
              ),
              SizedBox(width: 30),
              ElevatedButton(
                onPressed: () => {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // sharp corners
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
