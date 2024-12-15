// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:untitled/pages/categories/apks_page.dart';
import 'package:untitled/assets/storage_screen.dart';
import 'package:untitled/pages/categories/audios_page.dart';
import 'package:untitled/pages/categories/documents_page.dart';
import 'package:untitled/pages/categories/downloads_page.dart';
import 'package:untitled/pages/categories/images_page.dart';
import 'package:untitled/pages/categories/videos_page.dart';
import 'package:untitled/widgets/gradient_background.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand, // Add this to make Stack fill the screen
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    _buildRecent(),
                    _buildCategories(context),
                    _allStorage(context),
                    SizedBox(height: 100), // Space for Events button
                  ],
                ),
              ),
              Positioned(
                bottom: 24, // Keep these values
                right: 24,
                child: IgnorePointer(
                  ignoring: false,
                  child: _buildEventsButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//Search Bar
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
                  hintStyle: TextStyle(
                    color: Colors.grey[400], // Change hint text color
                    fontSize: 14, // Change font size
                  ),
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

//AI stuff
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
            padding: EdgeInsets.fromLTRB(40, 60, 40, 60),
            decoration: BoxDecoration(
              color: Color(0xFF0F1418),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Make your first ai search\nand improve productivity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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

//Catagories Function
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
          case 'Downloads':
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DownloadsPage()));
            break;
          case 'Apks':
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ApksPage()));
            break;

          //Using the same card funtion for All Storages
          case 'Internal Storage':
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => StorageScreen()));
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

// Catagory options
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
          physics: NeverScrollableScrollPhysics(), // Add this line
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 20,
          childAspectRatio: 2.4,
          children: [
            _categoryCard('Images', '456 MB', 'lib/assets/image.png', context),
            _categoryCard('Videos', '1.2 GB', 'lib/assets/clapperboard.png', context),
            _categoryCard('Documents', '456 MB', 'lib/assets/file.png', context),
            _categoryCard('Audios', '228 MB', 'lib/assets/Vector.png', context),
            _categoryCard('Downloads', '0 GB', 'lib/assets/download.png', context),
            _categoryCard('Apks', '0', 'lib/assets/apk.png', context),
          ],
        ),
      ],
    ),
  );
}

  //All Storage
Widget _allStorage(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Storages',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          physics: NeverScrollableScrollPhysics(), // Add this line
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 6,
          childAspectRatio: 2.2,
          children: [
            _categoryCard('Internal Storage', '64 GB', 'lib/assets/file.png', context),
          ],
        ),
      ],
    ),
  );
}

//Event button
  Widget _buildEventsButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Color(0xFF4A4A4A))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'lib/assets/Vector2.png',
            width: 20,
            height: 20,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Text(
            'Events',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
