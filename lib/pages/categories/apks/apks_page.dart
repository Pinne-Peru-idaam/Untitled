// lib/pages/documents_page.dart
import 'package:flutter/material.dart';

class ApksPage extends StatelessWidget {
  const ApksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apks'),
        backgroundColor: Color(0xFF1E2746),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apks (0)',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            // Add your documents list here
          ],
        ),
      ),
    );
  }
}
