import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileManager extends StatefulWidget {
  const FileManager({super.key});

  @override
  FileManagerState createState() => FileManagerState(); // Remove underscore
}

class FileManagerState extends State<FileManager> {
  List<FileSystemEntity> _files = [];
  String _currentPath = '';

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
      getFiles('/storage/emulated/0');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing path: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Path navigator
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Current Path: $_currentPath'),
        ),
        // File list
        Expanded(
          child: ListView.builder(
            itemCount: _files.length,
            itemBuilder: (context, index) {
              final file = _files[index];
              final fileName = file.path.split('/').last;
              final isDirectory = file is Directory;

              return ListTile(
                leading: Icon(
                  isDirectory ? Icons.folder : _getFileIcon(fileName),
                  color: isDirectory ? Colors.amber : Colors.blue,
                ),
                title: Text(fileName),
                subtitle: !isDirectory
                    ? Text('Size: ${_getFileSize(file as File)}')
                    : null,
                onTap: () {
                  if (isDirectory) {
                    getFiles(file.path);
                  } else {
                    // Handle file tap
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

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'mp3':
      case 'wav':
        return Icons.music_note;
      case 'mp4':
      case 'mov':
        return Icons.video_library;
      default:
        return Icons.insert_drive_file;
    }
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
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete'),
            onTap: () async {
              Navigator.pop(context);
              await file.delete();
              getFiles(_currentPath);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Details'),
            onTap: () {
              Navigator.pop(context);
              // Show file details
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('File Details'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${file.path.split('/').last}'),
                      Text('Path: ${file.path}'),
                      if (file is File) Text('Size: ${_getFileSize(file)}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
