// lib/pages/documents_page.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

class ApksPage extends StatefulWidget {
  const ApksPage({super.key});

  @override
  State<ApksPage> createState() => _ApksPageState();
}

class _ApksPageState extends State<ApksPage> {
  List<File> apkFiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      _loadApkFiles();
    }
  }

  Future<void> _loadApkFiles() async {
    setState(() => isLoading = true);
    try {
      final List<File> files = [];
      final List<String> searchPaths = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
        '/storage/emulated/0/Documents',
        '/storage/emulated/0/APKs',
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0'
      ];

      for (String path in searchPaths) {
        try {
          final directory = Directory(path);
          if (await directory.exists()) {
            await for (var entity in directory.list()) {
              if (entity is File &&
                  entity.path.endsWith('.apk') &&
                  await entity.exists()) {
                files.add(entity);
              }
            }
          }
        } catch (e) {
          // Skip inaccessible directories
          continue;
        }
      }

      setState(() {
        apkFiles = files;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Error loading APK files: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showFileOptions(File file) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: const Text('Install'),
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
        ],
      ),
    );
  }

  Future<void> _confirmDelete(File file) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete APK'),
        content: Text(
            'Are you sure you want to delete ${file.path.split('/').last}?'),
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
        _loadApkFiles();
      } catch (e) {
        _showError('Error deleting file: $e');
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APKs'),
        backgroundColor: const Color(0xFF1E2746),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'APKs (${apkFiles.length})',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : apkFiles.isEmpty
                      ? const Center(child: Text('No APK files found'))
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: apkFiles.length,
                          itemBuilder: (context, index) {
                            final file = apkFiles[index];
                            final name = file.path.split('/').last;

                            return Card(
                              elevation: 2,
                              child: InkWell(
                                onTap: () => OpenFile.open(file.path),
                                onLongPress: () => _showFileOptions(file),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'lib/assets/icons/apk.png',
                                        width: 48,
                                        height: 48,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        name,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      FutureBuilder<FileStat>(
                                        future: file.stat(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Text('Loading...',
                                                style: TextStyle(fontSize: 10));
                                          }
                                          return Text(
                                            _formatSize(snapshot.data!.size),
                                            style:
                                                const TextStyle(fontSize: 10),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
