import 'package:flutter/material.dart';
import 'package:fitbit/pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitbit',
       theme: ThemeData(
        // Set black as the primary color
        primaryColor: Colors.black,
        // Set black as the accent color
        // Set black as the background color
        backgroundColor: Colors.black,
        // Set black as the scaffold background color
        scaffoldBackgroundColor: Colors.black,
        // Set white as the text color
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white, // Set white as the body text color
              displayColor: Colors.white, // Set white as the display text color
            ),
      ),
      home: Home(),
    );
  }
}
