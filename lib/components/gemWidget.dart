import 'package:flutter/material.dart';
import 'package:hidden_gem/components/commentSection.dart';
import 'package:hidden_gem/model/hiddengem.dart';
import 'package:hidden_gem/model/user.dart';
import 'package:hidden_gem/service/hidden_gem_service.dart';
import 'package:hidden_gem/service/user_services.dart';

/*
  Builds gems view displaying pictures, name and user image
  if user is the owner of the gem also add a delete gem button
*/
class HiddenGemCard extends StatelessWidget {
  final HiddenGem gem;

  const HiddenGemCard({super.key, required this.gem});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    final gemService = HiddenGemService();
    final isOwner = userService.getUser() == gem.ownerId;

    return SizedBox(
      width: 300,
      height: 550,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(userService),
          const SizedBox(height: 10),
          _buildImageCarousel(),
          const SizedBox(height: 10),
          Center(
            child: IconButton(
              icon: const Icon(Icons.comment, color: Colors.blue),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierColor: Colors.black54,
                  builder: (_) => CommentBottomSheet(postId: gem.id),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(gem.description),
          ),
          const SizedBox(height: 8),
          if (isOwner) _buildDeleteButton(context, gemService),
        ],
      ),
    );
  }

  Widget _buildHeader(UserService userService) {
    return FutureBuilder<User>(
      future: userService.getUserById(gem.ownerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircleAvatar(child: CircularProgressIndicator()),
            title: Text("Loading..."),
          );
        }
        // Kinda unessasary dont really need but just for future use
        if (snapshot.hasError || !snapshot.hasData) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.error)),
            title: Text("User not found"),
          );
        }

        final user = snapshot.data!;
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(user.photoUrl)),
          title: Text(user.displayName),
          subtitle: Text(gem.name),
        );
      },
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
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
    );
  }

  Widget _buildDeleteButton(BuildContext context, HiddenGemService service) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.delete),
        label: const Text("Delete Gem"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Confirm Deletion"),
              content: const Text("Are you sure you want to delete this gem?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await service.deleteFromGems(gem.id);
            await service.deleteGemFromLiked(gem.id);
            await service.removeGemFromOwner(gem.id);
            await service.removeCommentsFromDeletedPosts(gem.id);

            Navigator.pop(context); // Close card/dialog if needed

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Gem deleted")));
          }
        },
      ),
    );
  }
}
