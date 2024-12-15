// lib/pages/categories/storage/file_manager.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:math';

class AppIcons {
  static const String folder = 'lib/assets/icons/folder-closed.png';
  static const String file = 'lib/assets/icons/file.png';
  static const String apk = 'lib/assets/icons/apk.png';
  static const String video = 'lib/assets/icons/clapperboard.png';
  static const String audio = 'lib/assets/icons/vector.png';
  static const String image = 'lib/assets/icons/image.png';
}

class FileManager extends StatefulWidget {
  const FileManager({super.key});

  @override
  FileManagerState createState() => FileManagerState();
}

class FileManagerState extends State<FileManager> {
  List<FileSystemEntity> files = [];
  String currentPath = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      _loadFiles();
    }
  }

  Future<void> _loadFiles() async {
    setState(() => isLoading = true);
    try {
      Directory? directory;
      if (currentPath.isEmpty) {
        directory = Directory('/storage/emulated/0');
      } else {
        directory = Directory(currentPath);
      }

      final List<FileSystemEntity> entities = await directory.list().toList();
      setState(() {
        files = entities..sort((a, b) => _sortFiles(a, b));
        currentPath = directory!.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Error loading files: $e');
    }
  }

  int _sortFiles(FileSystemEntity a, FileSystemEntity b) {
    if (a is Directory && b is File) return -1;
    if (a is File && b is Directory) return 1;
    return a.path.toLowerCase().compareTo(b.path.toLowerCase());
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleFileTap(FileSystemEntity entity) async {
    if (entity is Directory) {
      setState(() {
        currentPath = entity.path;
      });
      _loadFiles();
    } else if (entity is File) {
      _showFileOptions(entity);
    }
  }

  void _showFileOptions(File file) {
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
              OpenFile.open(file.path);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              Share.share(file.path);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(file);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Properties'),
            onTap: () {
              Navigator.pop(context);
              _showFileInfo(file);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(File file) async {
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
      try {
        await file.delete();
        _loadFiles();
      } catch (e) {
        _showError('Error deleting file: $e');
      }
    }
  }

  void _showFileInfo(File file) async {
    final stat = await file.stat();
    final size = await file.length();
    final modified = stat.modified;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(file.path.split('/').last),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Path: ${file.path}'),
            Text('Size: ${_formatSize(size)}'),
            Text('Modified: ${modified.toString()}'),
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

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  Widget _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    String iconPath;
    
    switch (extension) {
      case 'apk':
        iconPath = AppIcons.apk;
        break;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'wmv':
        iconPath = AppIcons.video;
        break;
      case 'mp3':
      case 'wav':
      case 'm4a':
      case 'aac':
      case 'wma':
        iconPath = AppIcons.audio;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        iconPath = AppIcons.image;
        break;
      default:
        iconPath = AppIcons.file;
    }

    return Image.asset(
      iconPath,
      width: 40,
      height: 40,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Manager'),
        leading: currentPath != '/storage/emulated/0'
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    currentPath = Directory(currentPath).parent.path;
                  });
                  _loadFiles();
                },
              )
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final entity = files[index];
                final name = entity.path.split('/').last;
                final isDirectory = entity is Directory;

                return ListTile(
                  leading: isDirectory
                      ? Image.asset(
                          AppIcons.folder,
                          width: 40,
                          height: 40,
                        )
                      : _getFileIcon(name),
                  title: Text(name),
                  subtitle: FutureBuilder<FileStat>(
                    future: entity.stat(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text('Loading...');
                      final stat = snapshot.data!;
                      if (isDirectory) {
                        return Text('Modified: ${stat.modified.toString()}');
                      } else {
                        return Text('Size: ${_formatSize(stat.size)}');
                      }
                    },
                  ),
                  onTap: () => _handleFileTap(entity),
                );
              },
            ),
    );
  }
}