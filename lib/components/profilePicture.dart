import 'dart:developer';

import 'package:flutter/material.dart';

/*
  Displays Image of user
*/
class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const UserAvatar({super.key, required this.imageUrl, this.size = 120});

  @override
  Widget build(BuildContext context) {
    log("IMAGE: ${imageUrl}");
    return Center(
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(imageUrl),
      ),
    );
  }
}
