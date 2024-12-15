import 'package:flutter/material.dart';
import 'package:untitled/widgets/gradient_background.dart';
import 'widgets/search_bar.dart';
import 'widgets/recent_section.dart';
import 'widgets/categories_section.dart';
import 'widgets/storage_section.dart';
import 'widgets/events_button/events_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SearchBarWidget(), // Changed from SearchBar() to SearchBarWidget()
                    RecentSection(),
                    CategoriesSection(),
                    StorageSection(),
                    SizedBox(height: 100),
                  ],
                ),
              ),
              const Positioned(
                bottom: 24,
                right: 24,
                child: IgnorePointer(
                  ignoring: false,
                  child: EventsButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
