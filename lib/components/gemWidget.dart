import 'package:flutter/material.dart';
import 'package:hidden_gem/components/commentSection.dart';
import 'package:hidden_gem/model/hiddengem.dart';
import 'package:hidden_gem/model/user.dart';
import 'package:hidden_gem/service/hidden_gem_service.dart';
import 'package:hidden_gem/service/user_services.dart';

Widget gemWidget(BuildContext context, HiddenGem gem) {
  UserService userService = UserService();
  HiddenGemService hiddenGemService = HiddenGemService();

  return Container(
    width: 300,
    height: 550,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<AppUser>(
          future: userService.getUserById(gem.ownerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                leading: CircleAvatar(child: CircularProgressIndicator()),
                title: Text("Loading..."),
              );
            }

            final user = snapshot.data!;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl),
              ),
              title: Text(user.displayName),
              subtitle: Text(gem.name),
            );
          },
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gem.imageUrls.length,
            itemBuilder: (context, index) {
              return Container(
                width: 290,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(gem.imageUrls[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        Center(
          child: IconButton(
            icon: const Icon(Icons.comment, color: Colors.blue),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                barrierColor: Colors.black54,
                builder: (BuildContext context) {
                  return commentSection(context, gem.id);
                },
              );
            },
          ),
        ),
        Text(gem.description),
        const SizedBox(height: 8),
        if (userService.getUser() == gem.ownerId)
          Center(
            child: ElevatedButton(
              onPressed: () {
                hiddenGemService.deleteFromGems(gem.id);
                hiddenGemService.deleteGemFromLiked(gem.id);
                hiddenGemService.removeGemFromOwner(gem.id);
                hiddenGemService.removeCommentsFromDeletedPosts(gem.id);
                Navigator.pop(context);
              },
              child: Text("Delete Gem"),
            ),
          ),
      ],
    ),
  );
}
