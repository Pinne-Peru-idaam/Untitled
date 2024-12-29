import 'package:flutter/material.dart';
import 'package:untitled/pages/categories/storage/file_manager.dart';
import 'dart:io';
import 'file_manager_controller.dart';
import 'widgets/file_list_view.dart';
import 'widgets/create_folder_dialog.dart';

class FileManagerState extends State<FileManager> {
  final FileManagerController _controller = FileManagerController();

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_controller.currentDirectory.path.split('/').last),
        leading: _controller.canNavigateBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _controller.navigateBack,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            onPressed: () => showCreateFolderDialog(context, _controller),
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_controller.hasPermission && Platform.isAndroid) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Storage permission is required'),
                  ElevatedButton(
                    onPressed: _controller.checkAndRequestPermissions,
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            );
          }

          return FileListView(controller: _controller);
        },
      ),
    );
  }
}
