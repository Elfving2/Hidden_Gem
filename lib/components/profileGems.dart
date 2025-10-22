import 'package:flutter/material.dart';
import 'package:hidden_gem/components/gemWidget.dart';
import 'package:hidden_gem/model/hiddengem.dart';
import 'package:hidden_gem/service/hidden_gem_service.dart';

class ProfileGemsGrid extends StatelessWidget {
  const ProfileGemsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final gemService = HiddenGemService();

    return StreamBuilder<List<HiddenGem>>(
      stream: gemService.getUsersGems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Failed to load gems."));
        }

        final gems = snapshot.data ?? [];

        if (gems.isEmpty) {
          return const Center(child: Text("You haven't added any gems yet."));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            final gem = gems[index];
            return _GemTile(gem: gem);
          },
        );
      },
    );
  }
}

class _GemTile extends StatelessWidget {
  final HiddenGem gem;

  const _GemTile({required this.gem});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: HiddenGemCard(gem: gem),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          image: DecorationImage(
            image: NetworkImage(gem.imageUrls.first),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
