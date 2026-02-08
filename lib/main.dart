import 'package:firefly_books/app.dart';
import 'package:firefly_books/core/configurations/routes.dart';
import 'package:firefly_books/core/data/local/shared_preferences_handle.dart';
import 'package:firefly_books/core/theme/theme_notifier.dart';
import 'package:firefly_books/core/theme/themes.dart';
import 'package:firefly_books/features/pages/setup_page.dart';
import 'package:flutter/material.dart';
import 'core/data/local/db_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.database;
  await PrefsService.instance.init();

  themeModeNotifier.value = PrefsService.instance.themeMode;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isSetupDone = PrefsService.instance.setupComplete;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          onGenerateRoute: AppRoutes.generateRoute,
          home: isSetupDone ? App() : SetupPage(),
        );
      },
    );
  }
}
