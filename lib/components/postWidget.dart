import 'package:flutter/material.dart';
import 'package:hidden_gem/components/commentSection.dart';
import 'package:hidden_gem/model/hiddengem.dart';
import 'package:hidden_gem/model/user.dart';
import 'package:hidden_gem/service/hidden_gem_service.dart';
import 'package:hidden_gem/service/user_services.dart';

/*
  Displays the post of friends gems 
  * Displays owner profile info (image, name)
  * allows user to like and de-like post
  * user can comment on post if wanted 
  * if the current logged in user is the owner allow delete of post.
*/
class HiddenGemCard extends StatefulWidget {
  final HiddenGem gem;
  const HiddenGemCard({super.key, required this.gem});

  @override
  State<HiddenGemCard> createState() => _HiddenGemCardState();
}

class _HiddenGemCardState extends State<HiddenGemCard> {
  final _userService = UserService();
  final _gemService = HiddenGemService();

  final ValueNotifier<bool> _isFavorite = ValueNotifier<bool>(false);
  bool _likeBusy = false;
  bool _likeInitDone = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.gem.likes;
    _initLike();
  }

  Future<void> _initLike() async {
    try {
      final liked = await _userService.hasLikedPost(widget.gem.id);
      if (!mounted) return;
      _isFavorite.value = liked;
      _likeInitDone = true;
    } catch (_) {}
  }

  Future<void> _toggleLike() async {
    if (_likeBusy) return;
    setState(() => _likeBusy = true);

    final next = !_isFavorite.value;
    final prevCount = _likeCount;

    // optimistic UI
    _isFavorite.value = next;
    _likeCount = next ? _likeCount + 1 : (_likeCount > 0 ? _likeCount - 1 : 0);
    setState(() {});

    try {
      if (next) {
        await _userService.addToLiked(widget.gem.id);
        await _gemService.likePost(widget.gem.id);
      } else {
        await _userService.removeLiked(widget.gem.id);
        await _gemService.deLikePost(widget.gem.id);
      }
    } catch (_) {
      // rollback on failure
      _isFavorite.value = !next;
      _likeCount = prevCount;
      if (mounted) setState(() {});
    } finally {
      if (mounted) setState(() => _likeBusy = false);
    }
  }

  @override
  void dispose() {
    _isFavorite.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _userService.getUser() == widget.gem.ownerId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          _buildImageCarousel(),
          const SizedBox(height: 10),
          _buildActions(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(widget.gem.description),
          ),
          const SizedBox(height: 8),
          if (isOwner) _buildDeleteButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FutureBuilder<User>(
      future: _userService.getUserById(widget.gem.ownerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircleAvatar(child: CircularProgressIndicator()),
            title: Text('Loading'),
          );
        }
        if (!snapshot.hasData) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.error)),
            title: Text('Unknown user'),
          );
        }

        final user = snapshot.data!;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            foregroundImage: NetworkImage(user.photoUrl),
            child: const Icon(Icons.person),
          ),
          title: Text(user.displayName),
          subtitle: Text(widget.gem.name),
        );
      },
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.gem.imageUrls.length,
        itemBuilder: (context, index) {
          final url = widget.gem.imageUrls[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: MediaQuery.of(context).size.width * 0.94,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Colors.black12,
                child: Center(child: Icon(Icons.broken_image)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActions() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isFavorite,
      builder: (context, liked, _) {
        return Row(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: liked ? 'Unlike' : 'Like',
                  onPressed: _likeBusy ? null : _toggleLike,
                  icon: Icon(
                    Icons.favorite,
                    color: liked ? Colors.red : Colors.grey,
                  ),
                ),
                Text("$_likeCount"),
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
                  builder: (ctx) => CommentBottomSheet(postId: widget.gem.id),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.delete),
        label: const Text('Delete Gem'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text('Are you sure you want to delete this gem?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await _gemService.deleteFromGems(widget.gem.id);
            await _gemService.deleteGemFromLiked(widget.gem.id);
            await _gemService.removeGemFromOwner(widget.gem.id);
            await _gemService.removeCommentsFromDeletedPosts(widget.gem.id);

            if (!mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Gem deleted')));
          }
        },
      ),
    );
  }
}
