import 'package:flutter/material.dart';
import 'package:hidden_gem/screens/edit_profile_view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Profile")),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      border: Border.all(width: 4, color: Colors.white),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          "https://i.pinimg.com/1200x/82/85/96/828596ef925a10e8c1a76d3a3be1d3e5.jpg",
                        ),
                      ),
                    ),
                  ),
                  // BUTTON
                  SizedBox(height: 15),
                  customButton("Go to Settings", () {
                    goToSettings(context);
                  }),
                  SizedBox(height: 30),
                  Text(
                    "Gallery",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 5.0, // vertical gap
              crossAxisSpacing: 5.0, // horizontal gap
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
            ),
          ],
        ),
      ),
    );
  }
}

Widget customButton(String buttonText, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      minimumSize: const Size(120, 40),
    ),
    child: Text(buttonText),
  );
}

// Function needs BuildContext to work
void goToSettings(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => const EditProfile()));
}
