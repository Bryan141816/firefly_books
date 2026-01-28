import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dbHandler.dart';
import 'screens/book_list.dart';
import 'screens/setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.database;

  // Check if setup is complete
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool setupComplete = prefs.getBool('setupComplete') ?? false;
  String booksDirectory = prefs.getString('booksDirectory') ?? "";

  runApp(MyApp(setupComplete: setupComplete, booksDirectory: booksDirectory));
}

class MyApp extends StatelessWidget {
  final bool setupComplete;
  final String booksDirectory;
  const MyApp({
    super.key,
    required this.setupComplete,
    required this.booksDirectory,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firefly Books',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      // Show BookList if setupComplete, otherwise SetupScreen
      home: setupComplete
          ? BookList(booksPath: booksDirectory)
          : const SetupScreen(),
    );
  }
}
