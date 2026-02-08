import 'package:firefly_books/app.dart';
import 'package:firefly_books/core/data/local/shared_preferences_handle.dart';
import 'package:firefly_books/core/theme/theme_notifier.dart';
import 'package:firefly_books/features/components/directory_edit.dart';
import 'package:firefly_books/features/components/theme_selector.dart';
import 'package:firefly_books/presentation/steps/steps.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  bool _storageGranted = false;
  String? _selectedFolder;
  ThemeMode _themeMode = ThemeMode.system;
  @override
  void initState() {
    super.initState();
    _checkStoragePermission();
  }

  // Check storage permission
  Future<void> _checkStoragePermission() async {
    bool granted = await Permission.storage.isGranted;
    setState(() {
      _storageGranted = granted;
    });
  }

  // Request storage permission
  Future<bool> _requestStoragePermission() async {
    var status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  // Pick folder
  Future<void> _pickFolder() async {
    if (!_storageGranted) {
      bool granted = await _requestStoragePermission();
      if (!granted) return;
    }

    String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      setState(() {
        _selectedFolder = folderPath;
      });
    }
  }

  void onThemeSelect(ThemeMode theme) {
    themeModeNotifier.value = theme;
    setState(() {
      _themeMode = theme;
    });
  }

  // Complete setup and save to SharedPreferences
  Future<void> _completeSetup() async {
    if (_selectedFolder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a folder first')),
      );
      return;
    }

    await PrefsService.instance.setBooksDirectory(_selectedFolder!);
    await PrefsService.instance.setTheme(_themeMode);
    await PrefsService.instance.setSetupComplete(true);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => App(),
      ), // replace with your BookList widget
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1 circle
            StepsIndicator(
              count: "1",
              title: "Select Books Folder",
              description:
                  "Select the folder where your books are stored. The app will scan this folder to display your library. You can always change it later in settings.",
            ),

            const SizedBox(height: 20),
            // Folder picker button
            _selectedFolder == null
                ? Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextButton(
                      onPressed: _pickFolder,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: const Color.fromARGB(255, 24, 49, 83),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Select Folder',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )
                : DirectoryEdit(
                    onPressed: _pickFolder,
                    selectedFolder: _selectedFolder ?? "",
                  ),
            const SizedBox(height: 20),
            StepsIndicator(
              count: "2",
              title: "Choose App Theme",
              description:
                  "Select the theme you prefer for the app. You can choose between light, dark, or system default, and change it anytime later in settings.",
            ),
            const SizedBox(height: 20),
            ThemeSelector(selected: _themeMode, onChanged: onThemeSelect),

            const Spacer(), // pushes the complete button to the bottom
            // Complete button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: _completeSetup,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text(
                  'Complete Setup',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
