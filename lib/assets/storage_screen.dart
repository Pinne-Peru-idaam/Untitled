import 'package:flutter/material.dart';
import 'package:untitled/file_manager.dart';  // Adjust import path as needed

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internal Storage'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,  // Match your app's theme
      body: const FileManager(),
    );
  }
}