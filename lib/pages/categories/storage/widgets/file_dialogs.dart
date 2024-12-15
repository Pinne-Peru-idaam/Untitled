import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/file_utils.dart';

class FileDialogs {
  static void showFileOptions(
    BuildContext context,
    File file,
    Function onDelete,
    Function onOpen,
    Function onShare,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: const Text('Open'),
            onTap: () {
              Navigator.pop(context);
              onOpen();
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              onShare();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              confirmDelete(context, file, onDelete);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Properties'),
            onTap: () {
              Navigator.pop(context);
              showFileInfo(context, file);
            },
          ),
        ],
      ),
    );
  }

  static Future<void> confirmDelete(
    BuildContext context,
    File file,
    Function onDelete,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete ${file.path.split('/').last}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      onDelete();
    }
  }

  static void showFileInfo(BuildContext context, File file) async {
    final stat = await file.stat();
    final size = await file.length();

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(file.path.split('/').last),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Path: ${file.path}'),
              Text('Size: ${FileUtils.formatSize(size)}'),
              Text('Modified: ${stat.modified}'),
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
    }
  }
}