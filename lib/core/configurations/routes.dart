import 'package:firefly_books/core/data/local/shared_preferences_handle.dart';
import 'package:firefly_books/features/screens/library_screen.dart';
import 'package:firefly_books/features/screens/setup_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._();
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final isSetupDone = PrefsService.instance.setupComplete;

    debugPrint("Route requested: ${settings.name}");

    if (!isSetupDone && settings.name != "/setup") {
      return MaterialPageRoute(builder: (_) => const SetupScreen());
    }

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => const LibraryScreen());
      case "/setup":
        return MaterialPageRoute(builder: (_) => const SetupScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LibraryScreen());
    }
  }
}
