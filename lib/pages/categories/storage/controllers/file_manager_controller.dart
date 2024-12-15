import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class FileManagerController {
  String currentPath = '';
  List<FileSystemEntity> files = [];
  bool isLoading = true;

  final Function(bool) updateLoading;
  final Function(List<FileSystemEntity>) updateFiles;
  final Function(String) updatePath;
  final Function(String) showError;

  FileManagerController({
    required this.updateLoading,
    required this.updateFiles,
    required this.updatePath,
    required this.showError,
  });

  Future<void> requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      loadFiles();
    }
  }

  Future<void> loadFiles() async {
    updateLoading(true);
    try {
      Directory? directory;
      if (currentPath.isEmpty) {
        directory = Directory('/storage/emulated/0');
      } else {
        directory = Directory(currentPath);
      }

      final List<FileSystemEntity> entities = await directory.list().toList();
      entities.sort((a, b) => _sortFiles(a, b));

      currentPath = directory.path;
      updateFiles(entities);
      updatePath(currentPath);
      updateLoading(false);
    } catch (e) {
      updateLoading(false);
      showError('Error loading files: $e');
    }
  }

  int _sortFiles(FileSystemEntity a, FileSystemEntity b) {
    if (a is Directory && b is File) return -1;
    if (a is File && b is Directory) return 1;
    return a.path.toLowerCase().compareTo(b.path.toLowerCase());
  }

  Future<bool> handleBackPress() async {
    if (currentPath == '/storage/emulated/0') {
      return true;
    }
    currentPath = Directory(currentPath).parent.path;
    updatePath(currentPath);
    loadFiles();
    return false;
  }

  Future<void> deleteFile(File file) async {
    try {
      await file.delete();
      loadFiles();
    } catch (e) {
      showError('Error deleting file: $e');
    }
  }
}
