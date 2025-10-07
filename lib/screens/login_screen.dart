import 'package:flutter/material.dart';
import 'package:hidden_gem/components/bottom_navigationbar.dart';
import 'package:hidden_gem/service/google_auth.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final authService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 60,
        child: SignInButton(
          Buttons.google,
          text: "Sign in with Google",
          onPressed: () async {
            final usr = await authService.signInWithGoogle();
            if (usr != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BottomNavigationbar(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login failed. Please try again.')),
              );
            }
          },
        ),
      ),
    );
  }
}
