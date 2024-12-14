// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:untitled/audios_page.dart';
import 'package:untitled/documents_page.dart';
import 'package:untitled/images_page.dart';
import 'package:untitled/videos_page.dart';
import 'package:untitled/widgets/gradient_background.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              _buildRecent(),
              _buildCategories(context),
              Spacer(), // Push Events button to bottom
              _buildEventsButton(),
              SizedBox(height: 24), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 60, top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            Color(0xFF68008E), // Purple
            Color(0xFF00AEFF), // Blue
          ],
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(1), // Creates border effect
        decoration: BoxDecoration(
          color: Colors.black, // Inner background color
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search files',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecent() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Color(0xFF0F1418),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Make your first ai search\nand improve productivity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(
      String title, String size, String imagePath, BuildContext context) {
    return GestureDetector(
      onTap: () {
        switch (title) {
          case 'Images':
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ImagesPage()));
            break;
          case 'Videos':
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => VideosPage()));
            break;
          case 'Documents':
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DocumentsPage()));
            break;
          case 'Audios':
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AudiosPage()));
            break;
        }
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFF0F1418),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          // Changed to Row as main container
          children: [
            Image.asset(
              imagePath,
              width: 20,
              height: 20,
              color: Colors.white,
            ),
            SizedBox(width: 16),
            Column(
              // Column for title and size
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4), // Small spacing between title and size
                Text(
                  size,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Update GridView aspect ratio
  Widget _buildCategories(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.2, // Adjusted for shorter height
            children: [
              _categoryCard(
                  'Images', '456 MB', 'lib/assets/image.png', context),
              _categoryCard(
                  'Videos', '1.2 GB', 'lib/assets/clapperboard.png', context),
              _categoryCard(
                  'Documents', '456 MB', 'lib/assets/file.png', context),
              _categoryCard(
                  'Audios', '228 MB', 'lib/assets/Vector.png', context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsButton() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFF1E2746),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_note, size: 20),
            SizedBox(width: 8),
            Text(
              'Events',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
