import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hidden_gem/service/user_services.dart';

/* 
  Sign in with google 
  Had slight problem here with phone saves cashing data so it didnt logout properly, 
  fixed in my user_service.file
  TLDR turns out i cant have class variable of user becuase it dosent update when logging into new account
*/
class FirebaseService {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final UserService userService = UserService();

  Future<UserCredential?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(scopes: ['email']);

    await googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    if (userCredential.user != null) {
      await userService.createUserIfNotExists(userCredential.user!);
    }

    return userCredential;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }
}
