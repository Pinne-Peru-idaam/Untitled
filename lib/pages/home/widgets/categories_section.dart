import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:untitled/pages/categories/apks/apks_page.dart';
import 'package:untitled/pages/categories/audios/audios_page.dart';
import 'package:untitled/pages/categories/documents/documents_page.dart';
import 'package:untitled/pages/categories/downloads/downloads_page.dart';
import 'package:untitled/pages/categories/images/images_page.dart';
import 'package:untitled/pages/categories/videos/videos_page.dart';
import 'package:untitled/pages/home/widgets/category_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CategoriesSection extends StatefulWidget {
  // Change to StatefulWidget
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  Map<String, String> storageInfo = {
    'images': '0 B',
    'videos': '0 B',
    'documents': '0 B',
    'audio': '0 B',
    'downloads': '0 B',
    'apks': '0 B',
  };

  @override
  void initState() {
    super.initState();
    _requestPermissionAndCalculateStorage();
  }

  Future<void> _requestPermissionAndCalculateStorage() async {
    // Request permissions first
    var status = await Permission.storage.request();
    var manageStatus = await Permission.manageExternalStorage.request();
    
    if (status.isGranted || manageStatus.isGranted) {
      await calculateStorageUsage();
    } else {
      debugPrint('Storage permission denied');
    }
  }

  Future<void> calculateStorageUsage() async {
    try {
      // Get the external storage directory
      Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) return;

      // Get the root directory (Android specific)
      String rootPath = externalDir.path.split('Android')[0];
      Directory rootDir = Directory(rootPath);

      await _scanDirectory(rootDir);
    } catch (e) {
      debugPrint('Error calculating storage: $e');
    }
  }

  Future<void> _scanDirectory(Directory directory) async {
    try {
      Map<String, int> sizes = {
        'images': 0,
        'videos': 0,
        'documents': 0,
        'audio': 0,
        'downloads': 0,
        'apks': 0,
      };

      await for (var entity in directory.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          String path = entity.path.toLowerCase();
          try {
            int size = await entity.length();

            if (path.endsWith('.jpg') || path.endsWith('.jpeg') || 
                path.endsWith('.png') || path.endsWith('.gif')) {
              sizes['images'] = (sizes['images'] ?? 0) + size;
            } else if (path.endsWith('.mp4') || path.endsWith('.avi') || 
                       path.endsWith('.mov') || path.endsWith('.mkv')) {
              sizes['videos'] = (sizes['videos'] ?? 0) + size;
            } else if (path.endsWith('.pdf') || path.endsWith('.doc') || 
                       path.endsWith('.docx') || path.endsWith('.txt')) {
              sizes['documents'] = (sizes['documents'] ?? 0) + size;
            } else if (path.endsWith('.mp3') || path.endsWith('.wav') || 
                       path.endsWith('.m4a') || path.endsWith('.aac')) {
              sizes['audio'] = (sizes['audio'] ?? 0) + size;
            } else if (path.endsWith('.apk')) {
              sizes['apks'] = (sizes['apks'] ?? 0) + size;
            }
            
            if (path.contains('download')) {
              sizes['downloads'] = (sizes['downloads'] ?? 0) + size;
            }
          } catch (e) {
            debugPrint('Error reading file ${entity.path}: $e');
          }
        }
      }

      setState(() {
        storageInfo = sizes.map((key, value) => 
          MapEntry(key, _formatSize(value)));
      });
      
      // Debug print the sizes
      sizes.forEach((key, value) {
        debugPrint('$key: ${_formatSize(value)}');
      });

    } catch (e) {
      debugPrint('Error scanning directory: $e');
    }
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 20,
            childAspectRatio: 2.4,
            children: [
              CategoryCard(
                title: 'Images',
                size: storageInfo['images'] ?? '0 B',
                imagePath: 'lib/assets/icons/image.png',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ImagesPage())),
              ),
              CategoryCard(
                title: 'Videos',
                size: storageInfo['videos'] ?? '0 B',
                imagePath: 'lib/assets/icons/clapperboard.png',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const VideosPage())),
              ),
              CategoryCard(
                title: 'Documents',
                size: storageInfo['documents'] ?? '0 B',
                imagePath: 'lib/assets/icons/file.png',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DocumentsPage())),
              ),
              CategoryCard(
                title: 'Audios',
                size: storageInfo['audio'] ?? '0 B',
                imagePath: 'lib/assets/icons/Vector.png',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AudiosPage())),
              ),
              CategoryCard(
                title: 'Downloads',
                size: storageInfo['downloads'] ?? '0 B',
                imagePath: 'lib/assets/icons/download.png',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DownloadsPage())),
              ),
              CategoryCard(
                title: 'Apks',
                size: storageInfo['apks'] ?? '0 B',
                imagePath: 'lib/assets/icons/apk.png',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ApksPage())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StorageInfoWidget extends StatefulWidget {
  const StorageInfoWidget({super.key});

  @override
  State<StorageInfoWidget> createState() => _StorageInfoWidgetState();
}

class _StorageInfoWidgetState extends State<StorageInfoWidget> {
  Map<String, int> storageInfo = {
    'images': 0,
    'videos': 0,
    'documents': 0,
    'audio': 0,
    'downloads': 0,
    'apks': 0,
  };

  @override
  void initState() {
    super.initState();
    calculateStorageUsage();
  }

  Future<void> calculateStorageUsage() async {
    final Directory? directory = await getExternalStorageDirectory();
    if (directory == null) return;

    await _scanDirectory(directory);
    setState(() {}); // Update UI after calculation
  }

  Future<void> _scanDirectory(Directory directory) async {
    try {
      List<FileSystemEntity> entities = directory.listSync(recursive: true);
      
      for (var entity in entities) {
        if (entity is File) {
          String path = entity.path.toLowerCase();
          int size = await entity.length();

          if (path.endsWith('.jpg') || path.endsWith('.jpeg') || 
              path.endsWith('.png') || path.endsWith('.gif')) {
            storageInfo['images'] = (storageInfo['images'] ?? 0) + size;
          } else if (path.endsWith('.mp4') || path.endsWith('.avi') || 
                     path.endsWith('.mov')) {
            storageInfo['videos'] = (storageInfo['videos'] ?? 0) + size;
          } else if (path.endsWith('.pdf') || path.endsWith('.doc') || 
                     path.endsWith('.docx') || path.endsWith('.txt')) {
            storageInfo['documents'] = (storageInfo['documents'] ?? 0) + size;
          } else if (path.endsWith('.mp3') || path.endsWith('.wav') || 
                     path.endsWith('.m4a')) {
            storageInfo['audio'] = (storageInfo['audio'] ?? 0) + size;
          } else if (path.endsWith('.apk')) {
            storageInfo['apks'] = (storageInfo['apks'] ?? 0) + size;
          }
          
          // Assuming downloads folder
          if (path.contains('download')) {
            storageInfo['downloads'] = (storageInfo['downloads'] ?? 0) + size;
          }
        }
      }
    } catch (e) {
      debugPrint('Error scanning directory: $e');
    }
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: storageInfo.entries.map((entry) {
        return ListTile(
          title: Text(entry.key.toUpperCase()),
          trailing: Text(_formatSize(entry.value)),
        );
      }).toList(),
    );
  }
}
