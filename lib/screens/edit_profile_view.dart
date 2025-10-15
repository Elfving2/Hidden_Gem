import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hidden_gem/components/buildDescriptionField.dart';
import 'package:hidden_gem/components/buildTextField.dart';
import 'package:hidden_gem/components/profilePicture.dart';
import 'package:hidden_gem/model/user.dart';
import 'package:hidden_gem/screens/login_screen.dart';
import 'package:hidden_gem/service/google_login_service.dart';
import 'package:hidden_gem/service/user_services.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfile> {
  UserService userService = UserService();
  final displayNameController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isObscurePassword = true;
  AppUser? currentUser;
  FirebaseService firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = await userService.getLoggedInUserData();
    setState(() {
      currentUser = user;
      displayNameController.text = user.displayName;
      descriptionController.text = user.description;
    });
  }

  @override
  void dispose() {
    displayNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await firebaseService.signOut();

              if (!mounted) return;

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            profilePicture(currentUser!.photoUrl),
            const SizedBox(height: 30),
            buildTextField("Display Name", displayNameController),
            buildDescriptionField("Description", descriptionController),
            ElevatedButton(
              onPressed: () {
                userService.saveProfile(
                  displayNameController.text,
                  descriptionController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text("Save", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
