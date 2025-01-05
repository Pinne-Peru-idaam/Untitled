import 'package:flutter/material.dart';
import 'pages/home/home_page.dart'; // Importing the HomePage class
import 'package:permission_handler/permission_handler.dart';

// lib/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request permissions
  await [
    Permission.storage,
    Permission.manageExternalStorage,
    Permission.photos,
    Permission.videos,
    Permission.audio,
  ].request();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Poppins'),
          bodyMedium: TextStyle(fontFamily: 'Poppins'),
          titleLarge: TextStyle(fontFamily: 'Poppins'),
        ),
        brightness: Brightness.dark,
        primaryColor: Color(0xFF1E2746),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: HomePage(),
    );
  }
}
