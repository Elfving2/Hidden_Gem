import 'package:flutter/material.dart';
import 'package:hidden_gem/components/comment_button.dart';
import 'package:hidden_gem/model/comment.dart';
import 'package:hidden_gem/model/user.dart';
import 'package:hidden_gem/service/user_services.dart';

Widget commentSection(BuildContext context, String postId) {
  UserService userService = UserService();

  return GestureDetector(
    onTap: () => Navigator.of(context).pop(),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),
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
                                      title: Text('Loading'),
                                    );
                                  }

                                  final user = userSnapshot.data!;
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        user.photoUrl,
                                      ),
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
