import 'package:flutter/material.dart';
import 'dart:io';

class FileListItem extends StatelessWidget {
  final FileSystemEntity file;
  final Function(String) onTap;

  const FileListItem({
    super.key,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = file.path.split('/').last;
    final isDirectory = FileSystemEntity.isDirectorySync(file.path);

    return ListTile(
      leading: Icon(
        isDirectory ? Icons.folder : Icons.file_present,
        color: isDirectory ? Colors.yellow : Colors.blue,
      ),
      title: Text(fileName),
      onTap: isDirectory
          ? () => onTap(file.path)
          : () {
              // Handle file tap
            },
    );
  }
}