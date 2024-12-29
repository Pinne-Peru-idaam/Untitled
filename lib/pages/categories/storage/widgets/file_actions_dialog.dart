import 'package:flutter/material.dart';
import 'dart:io';
import '../file_manager_controller.dart';

void _showRenameDialog(
  BuildContext context,
  FileSystemEntity entity,
  FileManagerController controller,
) {
  String? newName;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Rename'),
      content: TextField(
        autofocus: true,
        decoration: const InputDecoration(hintText: 'New Name'),
        onChanged: (value) => newName = value,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (newName != null && newName!.isNotEmpty) {
              controller.renameEntity(entity, newName!);
            }
          },
          child: const Text('Rename'),
        ),
      ],
    ),
  );
}

void showFileActionsDialog(
  BuildContext context,
  FileSystemEntity entity,
  FileManagerController controller,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(entity.path.split('/').last),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            controller.deleteEntity(entity);
          },
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _showRenameDialog(context, entity, controller);
          },
          child: const Text('Rename'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
