import 'package:flutter/material.dart';
import 'package:untitled/pages/categories/apks/apks_page.dart';
import 'package:untitled/pages/categories/audios/audios_page.dart';
import 'package:untitled/pages/categories/documents/documents_page.dart';
import 'package:untitled/pages/categories/downloads/downloads_page.dart';
import 'package:untitled/pages/categories/images/images_page.dart';
import 'package:untitled/pages/categories/videos/videos_page.dart';
import 'category_card.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({Key? key}) : super(key: key);

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
                size: '456 MB',
                imagePath: 'lib/assets/icons/image.png',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ImagesPage())),
              ),
              CategoryCard(
                title: 'Videos',
                size: '1.2 GB',
                imagePath: 'lib/assets/icons/clapperboard.png',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VideosPage())),
              ),
              // Add other category cards similarly
            ],
          ),
        ],
      ),
    );
  }
}
