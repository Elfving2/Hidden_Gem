import 'package:flutter/material.dart';
import 'package:hidden_gem/components/commentSection.dart';
import 'package:hidden_gem/model/hiddengem.dart';
import 'package:hidden_gem/model/user.dart';
import 'package:hidden_gem/service/hidden_gem_service.dart';
import 'package:hidden_gem/service/user_services.dart';

Widget postWidget(HiddenGem gem, BuildContext context) {
  final UserService userService = UserService();
  final HiddenGemService hiddenGemService = HiddenGemService();
  final isFavorite = ValueNotifier<bool>(false);
  bool isFavoriteInitialized = false;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<AppUser>(
          future: userService.getUserById(gem.ownerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                leading: CircleAvatar(child: CircularProgressIndicator()),
                title: Text('Loading'),
              );
            }

            if (!snapshot.hasData) {
              return const ListTile(title: Text('Unknown user'));
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
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gem.imageUrls.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: MediaQuery.of(context).size.width * 0.94,
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
        FutureBuilder<bool>(
          future: userService.hasLikedPost(gem.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            }

            if (snapshot.hasData && !isFavoriteInitialized) {
              isFavorite.value = snapshot.data!;
              isFavoriteInitialized = true;
            }

            return ValueListenableBuilder<bool>(
              valueListenable: isFavorite,
              builder: (context, value, _) {
                return Row(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: value ? Colors.red : Colors.grey,
                          ),
                          onPressed: () async {
                            final newValue = !value;
                            isFavorite.value = newValue;

                            if (newValue) {
                              await userService.addToLiked(gem.id);
                              await hiddenGemService.likePost(gem.id);
                            } else {
                              await userService.removeLiked(gem.id);
                              await hiddenGemService.deLikePost(gem.id);
                            }
                          },
                        ),
                        Text("${gem.likes}"),
                      ],
                    ),
                    const SizedBox(width: 10),
                    IconButton(
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
                  ],
                );
              },
            );
          },
        ),
      ],
    ),
  );
}
