import 'package:flutter/material.dart';
import 'package:untitled/storage_screen.dart';
import 'category_card.dart';

class StorageSection extends StatelessWidget {
  const StorageSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Storages',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 6,
            childAspectRatio: 2.2,
            children: [
              CategoryCard(
                title: 'Internal Storage',
                size: '64 GB',
                imagePath: 'lib/assets/file.png',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StorageScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}