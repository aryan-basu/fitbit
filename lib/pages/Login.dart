import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitbit/pages/home.dart';
import 'package:fitbit/pages/health.dart';
import 'package:fitbit/pages/chart.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in with Google'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            signInWithGoogle(context);
          },
          icon: Icon(Icons.g_translate), // Google logo icon
          label: Text('Sign in with Google'),
          style: ElevatedButton.styleFrom(
            primary: Colors.white, // Button background color
            onPrimary: Colors.black, // Button text color
          ),
        ),
      ),
    );
  }

  Future<dynamic> signInWithGoogle(BuildContext context) async {
    await Firebase.initializeApp();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>Chart()),
      );

      // Sign in with the provided credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Access the current user's email
      print('User email: ${userCredential.user?.email}');

      return userCredential;
    } on Exception catch (e) {
      // Handle sign-in errors
      print('Sign-in error: $e');
    }
  }
}
