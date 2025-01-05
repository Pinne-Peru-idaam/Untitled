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

class CategoriesSection extends StatefulWidget {
  // Change to StatefulWidget
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  String imagesSize = '0 MB';
  String videosSize = '0 MB';
  String documentsSize = '0 MB';
  String audiosSize = '0 MB';
  String downloadsSize = '0 MB';
  String apksSize = '0 MB';

  @override
  void initState() {
    super.initState();
    _loadSizes();
  }

  Future<void> _loadSizes() async {
    // Load Downloads size
    try {
      final directory = Directory('/storage/emulated/0/Download');
      if (await directory.exists()) {
        int totalSize = 0;
        await for (var entity in directory.list()) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
        setState(() {
          downloadsSize = _formatSize(totalSize);
        });
      }
    } catch (e) {
      print('Error loading downloads size: $e');
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
                size: imagesSize,
                imagePath: 'lib/assets/icons/image.png',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ImagesPage())),
              ),
              CategoryCard(
                title: 'Videos',
                size: videosSize,
                imagePath: 'lib/assets/icons/clapperboard.png',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const VideosPage())),
              ),
              CategoryCard(
                title: 'Documents',
                size: documentsSize,
                imagePath: 'lib/assets/icons/file.png',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DocumentsPage())),
              ),
              CategoryCard(
                title: 'Audios',
                size: audiosSize,
                imagePath: 'lib/assets/icons/Vector.png',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AudiosPage())),
              ),
              CategoryCard(
                title: 'Downloads',
                size: downloadsSize, // Using the calculated size
                imagePath: 'lib/assets/icons/download.png',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DownloadsPage())),
              ),
              CategoryCard(
                title: 'Apks',
                size: apksSize,
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
