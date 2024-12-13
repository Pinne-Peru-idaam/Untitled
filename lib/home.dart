import 'package:flutter/material.dart';
import 'file_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              // Navigate to root directory
              final fileManagerState =
                  context.findAncestorStateOfType<FileManagerState>();
              if (fileManagerState != null) {
                fileManagerState.getFiles('/storage/emulated/0');
              }
            },
          ),
        ],
      ),
      body: const FileManager(),
    );
  }
}
