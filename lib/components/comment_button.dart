import 'package:flutter/material.dart';
import 'package:hidden_gem/service/user_services.dart';

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
