import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileManagerController {
  Directory currentDirectory = Directory('');
  final List<Directory> navigationStack = [];
  final ValueNotifier<bool> isLoading = ValueNotifier(true);
  bool hasPermission = false;

  bool get canNavigateBack => navigationStack.isNotEmpty;

  Future<void> initialize() async {
    await checkAndRequestPermissions();
  }

  Future<void> checkAndRequestPermissions() async {
    isLoading.value = true;

    if (Platform.isAndroid) {
      if (await _requestPermissions()) {
        await _initializeDirectory();
      }
    } else {
      await _initializeDirectory();
    }

    isLoading.value = false;
  }

  Future<bool> _requestPermissions() async {
    final storage = await Permission.storage.request();
    final manageStorage = await Permission.manageExternalStorage.request();

    hasPermission = storage.isGranted || manageStorage.isGranted;
    return hasPermission;
  }

  Future<void> _initializeDirectory() async {
    try {
      if (Platform.isAndroid && hasPermission) {
        currentDirectory = Directory('/storage/emulated/0');
        await currentDirectory.list().first;
      } else {
        currentDirectory = await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      currentDirectory = await getApplicationDocumentsDirectory();
    }
  }

  void navigateBack() {
    if (navigationStack.isNotEmpty) {
      currentDirectory = navigationStack.removeLast();
    }
  }

  Future<List<FileSystemEntity>> getEntities() async {
    try {
      final List<FileSystemEntity> entities =
          await currentDirectory.list().toList();
      entities.sort((a, b) {
        bool aIsDir = FileSystemEntity.isDirectorySync(a.path);
        bool bIsDir = FileSystemEntity.isDirectorySync(b.path);

        if (aIsDir && !bIsDir) return -1;
        if (!aIsDir && bIsDir) return 1;

        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });
      return entities;
    } catch (e) {
      throw Exception('Failed to list directory contents: $e');
    }
  }

  String getFileSize(FileSystemEntity entity) {
    try {
      if (entity is File) {
        int bytes = entity.lengthSync();
        if (bytes < 1024) return '$bytes B';
        if (bytes < 1024 * 1024) {
          return '${(bytes / 1024).toStringAsFixed(1)} KB';
        }
        if (bytes < 1024 * 1024 * 1024) {
          return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
        return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
      }
    } catch (e) {
      return '';
    }
    return '';
  }

  void navigateToDirectory(FileSystemEntity entity) {
    navigationStack.add(currentDirectory);
    currentDirectory = Directory(entity.path);
  }

  Future<void> createFolder(String folderName) async {
    try {
      await Directory('${currentDirectory.path}/$folderName').create();
    } catch (e) {
      throw Exception('Error creating folder: $e');
    }
  }

  Future<void> deleteEntity(FileSystemEntity entity) async {
    try {
      await entity.delete(recursive: true);
    } catch (e) {
      throw Exception('Error deleting: $e');
    }
  }

  Future<void> renameEntity(FileSystemEntity entity, String newName) async {
    try {
      String newPath = '${entity.parent.path}/$newName';
      await entity.rename(newPath);
    } catch (e) {
      throw Exception('Error renaming: $e');
    }
  }

  // Add other methods from original file...
}
