import 'package:flutter/material.dart';
import 'dart:io';
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
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      if (await _requestPermissions()) {
        await _initializeDirectory();
      }
    } else {
      await _initializeDirectory();
    }
  }

  Future<bool> _requestPermissions() async {
    final storage = await Permission.storage.request();
    final manageStorage = await Permission.manageExternalStorage.request();

    setState(() {
      _hasPermission = storage.isGranted || manageStorage.isGranted;
    });

    if (!_hasPermission) {
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Storage Permission Required'),
            content: const Text(
                'This app needs storage access to manage files. Please grant permission in settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
    }

    return _hasPermission;
  }

  Future<void> _initializeDirectory() async {
    try {
      if (Platform.isAndroid && _hasPermission) {
        currentDirectory = Directory('/storage/emulated/0');
        await currentDirectory.list().first;
      } else {
        currentDirectory = await getApplicationDocumentsDirectory();
      }
      setState(() {});
    } catch (e) {
      currentDirectory = await getApplicationDocumentsDirectory();
      setState(() {});
    }
  }

  Future<List<FileSystemEntity>> _getEntities() async {
    try {
      final List<FileSystemEntity> entities = await currentDirectory.list().toList();
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

  String _getFileSize(FileSystemEntity entity) {
    try {
      if (entity is File) {
        int bytes = entity.lengthSync();
        if (bytes < 1024) return '$bytes B';
        if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
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

  Future<void> _createNewFolder() async {
    String? folderName;
    
    if (context.mounted) {
      await showDialog(
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
                  Directory('${currentDirectory.path}/$folderName')
                      .create()
                      .then((_) => setState(() {}))
                      .catchError((e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error creating folder: $e')),
                    );
                  });
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      );
    }
  }

  void _showEntityActions(FileSystemEntity entity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entity.path.split('/').last),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEntity(entity);
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _renameEntity(entity);
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

  Future<void> _deleteEntity(FileSystemEntity entity) async {
    bool confirm = await _confirmDelete(entity);
    if (!confirm) return;

    try {
      await entity.delete(recursive: true);
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
    }
  }

  Future<bool> _confirmDelete(FileSystemEntity entity) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${entity.path.split('/').last}?'),
        actions: [
          TextButton(
            onPressed: () {
              result = false;
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              result = true;
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _renameEntity(FileSystemEntity entity) async {
    String? newName;
    
    if (context.mounted) {
      await showDialog(
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
                  String newPath = '${entity.parent.path}/$newName';
                  entity.rename(newPath).then((_) => setState(() {})).catchError((e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error renaming: $e')),
                    );
                  });
                }
              },
              child: const Text('Rename'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentDirectory.path.split('/').last),
        leading: navigationStack.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateBack,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            onPressed: _createNewFolder,
          ),
        ],
      ),
      body: !_hasPermission && Platform.isAndroid
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Storage permission is required'),
                  ElevatedButton(
                    onPressed: _checkAndRequestPermissions,
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            )
          : FutureBuilder<List<FileSystemEntity>>(
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
                    final name = entity.path.split('/').last;
                    final fileSize = _getFileSize(entity);

                    return ListTile(
                      leading: Icon(
                        isDirectory ? Icons.folder : Icons.insert_drive_file,
                        color: isDirectory ? Colors.blue : Colors.grey,
                      ),
                      title: Text(name),
                      subtitle: fileSize.isNotEmpty ? Text(fileSize) : null,
                      onTap: () => isDirectory ? _navigateToDirectory(entity) : null,
                      onLongPress: () => _showEntityActions(entity),
                    );
                  },
                );
              },
            ),
    );
  }
}