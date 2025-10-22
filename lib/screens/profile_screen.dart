import 'package:flutter/material.dart';
import 'package:hidden_gem/components/customButton.dart';
import 'package:hidden_gem/components/profileGems.dart';
import 'package:hidden_gem/components/profilePicture.dart';
import 'package:hidden_gem/model/user.dart';
import 'package:hidden_gem/screens/edit_profile_view.dart';
import 'package:hidden_gem/service/user_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  UserService userService = UserService();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = await userService.getLoggedInUserData();
    setState(() {
      currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Profile")),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: currentUser == null
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: const Center(child: CircularProgressIndicator()),
              )
            : Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        UserAvatar(imageUrl: currentUser!.photoUrl),
                        SizedBox(height: 15),
                        PrimaryButton(
                          label: 'Go to settings',
                          onPressed: () {
                            goToSettings(context);
                          },
                        ),

                        SizedBox(height: 30),
                        Text(
                          "Gallery",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ProfileGemsGrid(),
                ],
              ),
      ),
    );
  }
}

void goToSettings(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => const EditProfile()));
}
