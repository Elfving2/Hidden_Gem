import 'package:flutter/material.dart';
import 'package:hidden_gem/service/user_services.dart';

/*
  Comment widget used to add a comment to a post from a user 
*/
class CommentInput extends StatefulWidget {
  final String postId;

  const CommentInput({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();
  final _userService = UserService();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _userService.commentOnPost(text, widget.postId);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Add a comment...",
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submit,
            tooltip: 'Send comment',
          ),
        ],
      ),
    );
  }
}
