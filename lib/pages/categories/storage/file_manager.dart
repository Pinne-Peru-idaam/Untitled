import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'controllers/file_manager_controller.dart';
import 'widgets/file_grid_item.dart';
import 'widgets/file_dialogs.dart';

class FileManager extends StatefulWidget {
  const FileManager({super.key});

  @override
  FileManagerState createState() => FileManagerState();
}

class FileManagerState extends State<FileManager> {
  FileManagerController controller = FileManagerController(
    updateLoading: (value) {}, // Initialize with empty functions
    updateFiles: (value) {},
    updatePath: (value) {},
    showError: (value) {},
  ); // Remove late keyword and provide initial value

  List<FileSystemEntity> files = [];
  String currentPath = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Update the controller with actual callbacks
    controller = FileManagerController(
      updateLoading: (value) => setState(() => isLoading = value),
      updateFiles: (value) => setState(() => files = value),
      updatePath: (value) => setState(() => currentPath = value),
      showError: _showError,
    );
    controller.requestPermission();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleFileTap(FileSystemEntity entity) async {
    if (entity is Directory) {
      controller.currentPath = entity.path;
      controller.loadFiles();
    } else if (entity is File) {
      OpenFile.open(entity.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.handleBackPress,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('File Manager'),
          leading: currentPath != '/storage/emulated/0'
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    controller.handleBackPress();
                  },
                )
              : null,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final entity = files[index];

                    return FileGridItem(
                      entity: entity,
                      onTap: () => _handleFileTap(entity),
                      onLongPress: () {
                        if (entity is File) {
                          FileDialogs.showFileOptions(
                            context,
                            entity,
                            () => controller.deleteFile(entity),
                            () => OpenFile.open(entity.path),
                            () => Share.share(entity.path),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }
}
