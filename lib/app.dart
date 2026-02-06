import 'package:firefly_books/features/screens/favorites_screen.dart';
import 'package:firefly_books/features/screens/library_screen.dart';
import 'package:firefly_books/presentation/navbar/floating_nav_bar.dart';
import 'package:flutter/material.dart';

class PageItem {
  final Widget page;
  final String title;

  const PageItem({required this.page, required this.title});
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _index = 0;

  final List<PageItem> _pages = const [
    PageItem(page: LibraryScreen(), title: 'Library'),
    PageItem(page: FavoriteScreen(), title: 'Favorites'),
    PageItem(page: _SearchPage(), title: 'Search'),
    PageItem(page: _ProfilePage(), title: 'Profile'),
  ];

  // Floating bar sizing
  static const double _barHeight = 64;
  static const double _barMargin = 16;

  @override
  Widget build(BuildContext context) {
    final double bottomPad = _barHeight + (_barMargin * 2) + 8;

    final currentPage = _pages[_index];

    return Scaffold(
      appBar: AppBar(title: Text(currentPage.title)),
      body: Stack(
        children: [
          // Page content: reserve space so it won't get covered by the floating bar
          Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: bottomPad,
            ),
            child: currentPage.page,
          ),

          // Floating bottom navigation
          Positioned(
            left: _barMargin,
            right: _barMargin,
            bottom: _barMargin,
            child: SafeArea(
              top: false,
              child: FloatingBottomNavBar(
                height: _barHeight,
                currentIndex: _index,
                onChanged: (i) => setState(() => _index = i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchPage extends StatelessWidget {
  const _SearchPage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Search"));
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Profile"));
  }
}
