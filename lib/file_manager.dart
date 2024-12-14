import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class FileManager extends StatefulWidget {
  const FileManager({super.key});

  @override
  FileManagerState createState() => FileManagerState();
}

class FileManagerState extends State<FileManager> {
  List<FileSystemEntity> _files = []; // Initialize empty list
  String _currentPath = '/storage/emulated/0'; // Initialize with default path

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.status.isDenied) {
        await Permission.storage.request();
        await Permission.manageExternalStorage.request();
      }
      getFiles(_currentPath); // Use initial path
    }
  }

  Future<void> getFiles(String path) async {
    try {
      Directory dir = Directory(path);
      setState(() {
        _currentPath = path;
        _files = dir.listSync();
      });
    } catch (e) {
      if (mounted) {
        // Check if widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing path: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _files.length,
            itemBuilder: (context, index) {
              final file = _files[index];
              final fileName = file.path.split('/').last;
              final isDirectory = file is Directory;

              return ListTile(
                leading: isDirectory
                    ? Image.asset(
                        'lib/assets/folder-closed.png', // Your folder icon
                        width: 24,
                        height: 24,
                        color: Colors.amber,
                      )
                    : _getFileIcon(fileName),
                title: Text(
                  fileName,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: !isDirectory
                    ? Text(
                        'Size: ${_getFileSize(file as File)}',
                        style: TextStyle(color: Colors.grey[400]),
                      )
                    : null,
                onTap: () {
                  if (isDirectory) {
                    getFiles(file.path);
                  } else {
                    _showFileOptions(file);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    String imagePath;

    switch (extension) {
      case 'pdf':
        imagePath = 'lib/assets/file.png'; // Your PDF icon
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        imagePath = 'lib/assets/image.png'; // Your image icon
        break;
      case 'mp3':
      case 'wav':
        imagePath = 'lib/assets/Vector.png'; // Your audio icon
        break;
      case 'mp4':
      case 'mov':
        imagePath = 'lib/assets/clapperboard.png'; // Your video icon
        break;
      case 'apk':
        imagePath = 'lib/assets/apk.png'; // Your APK icon
        break;
      default:
        imagePath = 'lib/assets/file.png'; // Your default file icon
    }

    return Image.asset(
      imagePath,
      width: 24,
      height: 24,
      color: Colors.white, // Optional: tint the icon
    );
  }

  String _getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      if (bytes < 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showFileOptions(FileSystemEntity file) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1418),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.white),
            title: const Text('Delete', style: TextStyle(color: Colors.white)),
            onTap: () async {
              Navigator.pop(context);
              await file.delete();
              getFiles(_currentPath);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.white),
            title: const Text('Details', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _showDetailsDialog(file);
            },
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(FileSystemEntity file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F1418),
        title:
            const Text('File Details', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${file.path.split('/').last}',
                style: const TextStyle(color: Colors.white)),
            Text('Path: ${file.path}',
                style: const TextStyle(color: Colors.white)),
            if (file is File)
              Text('Size: ${_getFileSize(file)}',
                  style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
