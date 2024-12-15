// lib/pages/documents_page.dart
import 'package:flutter/material.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documents'),
        backgroundColor: Color(0xFF1E2746),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents (456 MB)',
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