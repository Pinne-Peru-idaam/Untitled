import 'package:flutter/material.dart';
import 'dart:io';
import '../file_manager_controller.dart';
import 'file_actions_dialog.dart';

class FileListView extends StatelessWidget {
  final FileManagerController controller;

  const FileListView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FileSystemEntity>>(
      future: controller.getEntities(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Empty folder'));
        }

        final entities = snapshot.data!;
        return ListView.builder(
          itemCount: entities.length,
          itemBuilder: (context, index) {
            final entity = entities[index];
            final isDirectory = FileSystemEntity.isDirectorySync(entity.path);
            final name = entity.path.split('/').last;
            final fileSize = controller.getFileSize(entity);

            return ListTile(
              leading: Icon(
                isDirectory ? Icons.folder : Icons.insert_drive_file,
                color: isDirectory ? Colors.blue : Colors.grey,
              ),
              title: Text(name),
              subtitle: fileSize.isNotEmpty ? Text(fileSize) : null,
              onTap: () =>
                  isDirectory ? controller.navigateToDirectory(entity) : null,
              onLongPress: () =>
                  showFileActionsDialog(context, entity, controller),
            );
          },
        );
      },
    );
  }
}
