import 'package:flutter/material.dart';

Widget profileGems() {
  return GridView.count(
    physics: NeverScrollableScrollPhysics(),
    crossAxisCount: 3,
    mainAxisSpacing: 5.0,
    crossAxisSpacing: 5.0,
    shrinkWrap: true,
    children: List.generate(12, (index) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              "https://www.bigfootdigital.co.uk/wp-content/uploads/2020/07/image-optimisation-scaled.jpg",
            ),
            fit: BoxFit.cover,
          ),
        ),
      );
    }),
  );
}
