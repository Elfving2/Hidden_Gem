import 'package:flutter/material.dart';
import 'package:hidden_gem/components/gemWidget.dart';
import 'package:hidden_gem/model/hiddengem.dart';
import 'package:hidden_gem/service/hidden_gem_service.dart';

Widget profileGems() {
  HiddenGemService hiddenGemService = HiddenGemService();
  return StreamBuilder<List<HiddenGem>>(
    stream: hiddenGemService.getUsersGems(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text("No gems found"));
      }

      final gems = snapshot.data!;

      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: gems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
        ),
        itemBuilder: (context, index) {
          final gem = gems[index];
          return ElevatedButton(
            onPressed: () {
              print("PRESSED");
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(content: gemWidget(context, gem));
                },
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(gem.imageUrls[0]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
