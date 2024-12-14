// lib/pages/images_page.dart
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class ImagesPage extends StatefulWidget {
  const ImagesPage({super.key});

  @override
  ImagesPageState createState() => ImagesPageState();
}

class ImagesPageState extends State<ImagesPage> {
  List<FileSystemEntity> imageFiles = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    if (await Permission.storage.request().isGranted) {
      final List<FileSystemEntity> files = [];

      Directory? directory = await getExternalStorageDirectory();
      String? path = directory?.path;

      if (path != null) {
        var dir = Directory(path);
        await for (var entity in dir.list(recursive: true)) {
          if (entity.path.endsWith('.jpg') ||
              entity.path.endsWith('.jpeg') ||
              entity.path.endsWith('.png') ||
              entity.path.endsWith('.svg')) {
            files.add(entity);
          }
        }

        setState(() {
          imageFiles = files;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Images'),
        backgroundColor: Color(0xFF1E2746),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Images (${imageFiles.length} files)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: imageFiles.length,
                itemBuilder: (context, index) {
                  return Image.file(
                    File(imageFiles[index].path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Text('Error loading image'));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
