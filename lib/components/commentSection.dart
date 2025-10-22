import 'package:flutter/material.dart';
import 'package:hidden_gem/components/comment_button.dart';
import 'package:hidden_gem/model/comment.dart';
import 'package:hidden_gem/model/user.dart';
import 'package:hidden_gem/service/user_services.dart';

/*
  Comment section displays comments on a specific post (gem) if there are no comments displays the text
  no comments yet. Otherwise displays comments from post_comments firebase
*/
class CommentBottomSheet extends StatelessWidget {
  final String postId;

  const CommentBottomSheet({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Close sheet on tap outside
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.transparent),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildSheet(context, userService),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheet(BuildContext context, UserService userService) {
    return Material(
      color: Colors.grey[100],
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        height: 550,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Comments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1, color: Colors.black12),
            Expanded(
              child: StreamBuilder<List<Comment>>(
                stream: userService.getComments(postId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final comments = snapshot.data ?? [];
                  if (comments.isEmpty) {
                    return const Center(child: Text("No comments yet."));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return _CommentTile(comment: comment);
                    },
                  );
                },
              ),
            ),
            CommentInput(postId: postId),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    return FutureBuilder<User>(
      future: userService.getUserById(comment.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Loading...'),
          );
        }

        final user = snapshot.data!;
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(user.photoUrl)),
          title: Text(user.displayName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.createdAt),
              const SizedBox(height: 4),
              Text(comment.message),
            ],
          ),
        );
      },
    );
  }
}
