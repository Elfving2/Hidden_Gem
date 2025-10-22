import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/components/bottom_navigationbar.dart';
import 'package:hidden_gem/db/inizilizedb.dart';
import 'package:hidden_gem/firebase_options.dart';
import 'package:hidden_gem/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final usr = FirebaseAuth.instance.currentUser;
  Inizilizedb inizilizedb = Inizilizedb();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == null) {
            inizilizedb.createDocuments();
            return LoginScreen();
          }
          return BottomNavigationbar();
        },
      ),
    );
  }
}
