import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'book_list.dart'; // replace with your actual BookList import

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool _storageGranted = false;
  String? _selectedFolder;

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
      print('Selected folder: $folderPath');
    }
  }

  // Complete setup and save to SharedPreferences
  Future<void> _completeSetup() async {
    if (_selectedFolder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a folder first')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('setupComplete', true);
    await prefs.setString('booksDirectory', _selectedFolder!);

    // Redirect to BookList and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => BookList(booksPath: _selectedFolder ?? ""),
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
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                "1",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              "Select Books Folder",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Description
            const Text(
              "Select the folder where your books are stored. The app will scan this folder to display your library. You can always change it later in settings.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Folder picker button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 116, 192, 252),
                border: const Border(
                  top: BorderSide(
                    color: Color.fromARGB(255, 24, 49, 83),
                    width: 2,
                  ),
                  left: BorderSide(
                    color: Color.fromARGB(255, 24, 49, 83),
                    width: 2,
                  ),
                  right: BorderSide(
                    color: Color.fromARGB(255, 24, 49, 83),
                    width: 2,
                  ),
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 24, 49, 83),
                    width: 4,
                  ),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: _pickFolder,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Color.fromARGB(255, 24, 49, 83),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _selectedFolder == null
                      ? 'Select Folder'
                      : _selectedFolder.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const Spacer(), // pushes the complete button to the bottom
            // Complete button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: _completeSetup,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Complete Setup',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
