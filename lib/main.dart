import 'package:flutter/material.dart';
import 'home.dart'; // Importing the HomePage class

// lib/main.dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF1E2746),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: HomePage(),
    );
  }
}
