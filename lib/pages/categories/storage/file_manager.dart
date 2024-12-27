import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileManager extends StatefulWidget {
  const FileManager({super.key});

  @override
  State<FileManager> createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  late Directory currentDirectory;
  List<Directory> navigationStack = [];

  @override
  void initState() {
    super.initState();
    _initializeDirectory();
  }

  Future<void> _initializeDirectory() async {
  if (Platform.isAndroid) {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      currentDirectory = Directory('/storage/emulated/0');
    } else {
      currentDirectory = await getApplicationDocumentsDirectory();
    }
  } else {
    currentDirectory = await getApplicationDocumentsDirectory();
  }
  setState(() {});
}

  Future<List<FileSystemEntity>> _getEntities() async {
    try {
      final entities = await currentDirectory.list().toList();
      return entities..sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    } catch (e) {
      throw Exception('Failed to list directory contents: $e');
    }
  }

  void _navigateToDirectory(FileSystemEntity entity) {
    setState(() {
      navigationStack.add(currentDirectory);
      currentDirectory = Directory(entity.path);
    });
  }

  void _navigateBack() {
    if (navigationStack.isNotEmpty) {
      setState(() {
        currentDirectory = navigationStack.removeLast();
      });
    }
  }

  Future<void> _deleteFile(FileSystemEntity entity) async {
    try {
      await entity.delete(recursive: true);
      setState(() {});
    } catch (e) {
      _showError('Failed to delete: $e');
    }
  }

  Future<void> _createFolder(String name) async {
    try {
      final newDir = Directory(path.join(currentDirectory.path, name));
      await newDir.create();
      setState(() {});
    } catch (e) {
      _showError('Failed to create folder: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(path.basename(currentDirectory.path)),
        leading: navigationStack.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateBack,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            onPressed: () => _showCreateFolderDialog(),
          ),
        ],
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: _getEntities(),
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
              
              return Dismissible(
                key: Key(entity.path),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteFile(entity),
                child: ListTile(
                  leading: Icon(
                    isDirectory ? Icons.folder : Icons.insert_drive_file,
                    color: isDirectory ? Colors.blue : Colors.grey,
                  ),
                  title: Text(path.basename(entity.path)),
                  subtitle: FutureBuilder<FileStat>(
                    future: entity.stat(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final modified = snapshot.data!.modified;
                      return Text(
                        '${modified.day}/${modified.month}/${modified.year}',
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                  onTap: () {
                    if (isDirectory) {
                      _navigateToDirectory(entity);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCreateFolderDialog() async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Folder name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _createFolder(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}