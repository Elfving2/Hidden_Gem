import 'package:flutter/material.dart';
import 'package:hidden_gem/components/bottom_navigationbar.dart';
import 'package:hidden_gem/service/google_login_service.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginViewState();
}

class LoginViewState extends State<LoginScreen> {
  final authService = FirebaseService();

  /* 
    Have to create new context, becuase of await, the widget originally provided can be removed from widget tree or rebuilt
    can cause problems in the future. So the solution is to create a new context after await then we know that it will always exist
    after the async operations are done.
  */

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 60,
        child: Builder(
          builder: (buttonContext) {
            return SignInButton(
              Buttons.google,
              text: "Sign in with Google",
              onPressed: () async {
                final user = await authService.signInWithGoogle();

                if (!mounted) return;

                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Login failed. Please try again.'),
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BottomNavigationbar(),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
