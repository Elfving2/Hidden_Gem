import 'package:flutter/material.dart';
import 'package:hidden_gem/controller/hidden_gem_controller.dart';
import 'package:hidden_gem/model/comment.dart';
import 'package:hidden_gem/model/hiddengem.dart';
import 'package:hidden_gem/model/user.dart';
import 'package:hidden_gem/service/user_services.dart';

class SocialMediaFeed extends StatefulWidget {
  const SocialMediaFeed({super.key});

  @override
  State<SocialMediaFeed> createState() => _SocialMediaFeedState();
}

class _SocialMediaFeedState extends State<SocialMediaFeed> {
  final MarkerService _gemService = MarkerService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Feed")),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<HiddenGem>>(
        stream: _gemService.getFriendsGems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No posts yet"));
          }

          final gems = snapshot.data!;

          return ListView.builder(
            itemCount: gems.length,
            itemBuilder: (context, index) {
              final gem = gems[index];
              return PostWidget(
                heading: gem.name,
                pictureLink: gem.imageUrls.first,
                author: gem.ownerId,
                pid: gem.id,
              );
            },
          );
        },
      ),
    );
  }
}

class PostWidget extends StatefulWidget {
  final String heading;
  final String pictureLink;
  final String author;
  final String pid;

  const PostWidget({
    required this.heading,
    required this.pictureLink,
    required this.author,
    required this.pid,
    super.key,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  final UserService _userService = UserService();
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(
                  "https://images.pexels.com/photos/33875524/pexels-photo-33875524.jpeg",
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.author,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.heading,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(widget.pictureLink),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });

                  if (isFavorite) {
                    _userService.addToLiked(widget.pid);
                  } else {
                    _userService.removeLiked(widget.pid);
                  }
                },
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.comment, color: Colors.blue),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true, // tap outside closes
                    barrierColor:
                        Colors.black54, // semi-transparent dark background
                    builder: (BuildContext context) {
                      return commentSection(context, widget.pid);
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ✅ Comment Section (popup)
Widget commentSection(BuildContext context, String postId) {
  UserService userService = UserService();

  return GestureDetector(
    onTap: () => Navigator.of(context).pop(), // close when tapping outside
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // background area
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),

          // Bottom comment panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: SizedBox(
                height: 550,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Comments",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Colors.black26),

                    Expanded(
                      child: StreamBuilder<List<Comment>>(
                        stream: userService.getComments(postId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text("No comments yet."),
                            );
                          }

                          final comments = snapshot.data!;

                          return ListView.separated(
                            itemCount: comments.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 15),
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return FutureBuilder<AppUser>(
                                future: userService.getUserById(comment.userId),
                                builder: (context, userSnapshot) {
                                  if (!userSnapshot.hasData) {
                                    return const ListTile(
                                      leading: CircleAvatar(
                                        child: Icon(Icons.person),
                                      ),
                                      title: Text('Loading...'),
                                    );
                                  }

                                  final user = userSnapshot.data!;
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: user.photoUrl.isNotEmpty
                                          ? NetworkImage(user.photoUrl)
                                          : const AssetImage(
                                                  'assets/default_avatar.png',
                                                )
                                                as ImageProvider,
                                    ),
                                    title: Text(user.displayName),
                                    subtitle: Text(comment.message),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),

                    commentButton(postId),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget commentButton(String pId) {
  UserService userService = UserService();
  TextEditingController commentController = TextEditingController();

  return Material(
    child: Container(
      color: Colors.grey[300],
      height: 100,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: "Write a comment...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              final message = commentController.text.trim();
              if (message.isNotEmpty) {
                userService.commentOnPost(message, pId);
                commentController.clear();
              }
            },
          ),
        ],
      ),
    ),
  );
}
