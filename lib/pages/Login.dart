import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbit/pages/home.dart';

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
            _signInWithGoogle(context);
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

  Future<dynamic> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (GoogleSignInAuthentication != null) {
        // Successfully signed in, navigate to the home page
             Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>Home()),
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
