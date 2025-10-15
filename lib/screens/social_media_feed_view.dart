import 'package:flutter/material.dart';
import 'package:hidden_gem/components/postWidget.dart';
import 'package:hidden_gem/model/hiddengem.dart';
import 'package:hidden_gem/service/hidden_gem_service.dart';

class SocialMediaFeed extends StatefulWidget {
  const SocialMediaFeed({super.key});

  @override
  State<SocialMediaFeed> createState() => _SocialMediaFeedState();
}

class _SocialMediaFeedState extends State<SocialMediaFeed> {
  final HiddenGemService gemService = HiddenGemService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Feed")),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<HiddenGem>>(
        stream: gemService.getFriendsGems(),
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
              return postWidget(gem, context);
            },
          );
        },
      ),
    );
  }
}
