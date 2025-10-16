import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hidden_gem/model/hiddengem.dart';
import 'package:hidden_gem/service/hidden_gem_service.dart';
import 'package:hidden_gem/service/user_services.dart';

UserService userService = UserService();
HiddenGemService hiddenGemService = HiddenGemService();

Future<void> displayGem(BuildContext context, HiddenGem gem) async {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              gem.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(gem.description),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: gem.imageUrls.map((url) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            insetPadding: EdgeInsets.zero,
                            backgroundColor: Colors.black,
                            child: Center(
                              child: InteractiveViewer(
                                child: Image.network(url, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Image.network(
                        url,
                        width: 50,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      ),
                    );
                  }).toList(),
                ),
                if (userService.getUser() == gem.ownerId)
                  ElevatedButton(
                    onPressed: () {
                      hiddenGemService.deleteFromGems(gem.id);
                      hiddenGemService.deleteGemFromLiked(gem.id);
                      hiddenGemService.removeGemFromOwner(gem.id);
                      hiddenGemService.removeCommentsFromDeletedPosts(gem.id);
                      Navigator.pop(context);
                    },
                    child: Text("Delete Gem"),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
