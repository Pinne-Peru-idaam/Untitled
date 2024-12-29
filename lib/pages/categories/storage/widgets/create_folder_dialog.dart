import 'package:flutter/material.dart';
import '../file_manager_controller.dart';

void showCreateFolderDialog(
  BuildContext context,
  FileManagerController controller,
) {
  String? folderName;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Create New Folder'),
      content: TextField(
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Folder Name'),
        onChanged: (value) => folderName = value,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (folderName != null && folderName!.isNotEmpty) {
              controller.createFolder(folderName!);
            }
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}
