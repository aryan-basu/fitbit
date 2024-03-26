import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitbit/pages/home.dart';
import 'package:fitbit/pages/health.dart';

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
        MaterialPageRoute(builder: (context) => HealthDataPage()),
      );
      print('accnt us $GoogleSignInAuthentication');
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e) {
      // TODO
      print('exception->$e');
    }
  }

  Future<dynamic> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (GoogleSignInAuthentication != null) {
        print('accnt us $GoogleSignInAuthentication');
        // Successfully signed in, navigate to the home page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HealthDataPage()),
        );
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e) {
      // TODO
      print('exception->$e');
    }
  }
}
