import 'package:file_picker/file_picker.dart';
import 'package:firefly_books/core/data/local/shared_preferences_handle.dart';
import 'package:firefly_books/core/theme/theme_notifier.dart';
import 'package:firefly_books/features/components/directory_edit.dart';
import 'package:firefly_books/features/components/theme_selector.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String booksPath = PrefsService.instance.booksDirectory;

  bool _storageGranted = false;

  @override
  void initState() {
    super.initState();
    _checkStoragePermission();
  }

  Future<void> _checkStoragePermission() async {
    bool granted = await Permission.storage.isGranted;
    setState(() {
      _storageGranted = granted;
    });
  }

  Future<bool> _requestStoragePermission() async {
    var status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  Future<void> _pickFolder() async {
    if (!_storageGranted) {
      bool granted = await _requestStoragePermission();
      if (!granted) return;
    }

    String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      setState(() {
        booksPath = folderPath;
      });
      await PrefsService.instance.setBooksDirectory(booksPath);
    }
  }

  Future<void> _selectTheme(ThemeMode theme) async {
    themeModeNotifier.value = theme;
    await PrefsService.instance.setTheme(theme);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const _CategoryHeader(title: 'Library'),
        const SizedBox(height: 10),

        _SettingsCard(
          children: [
            const _SettingTitle(
              title: 'Books Folder',
              subtitle: 'Choose where your books are stored.',
            ),
            const SizedBox(height: 12),
            DirectoryEdit(onPressed: _pickFolder, selectedFolder: booksPath),
          ],
        ),

        const SizedBox(height: 20),

        const _CategoryHeader(title: 'Appearance'),
        const SizedBox(height: 20),

        _SettingsCard(
          children: [
            const _SettingTitle(
              title: 'Theme',
              subtitle: 'System, Light, or Dark.',
            ),
            const SizedBox(height: 12),

            // ✅ Keep selector synced across pages
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeModeNotifier,
              builder: (context, mode, _) {
                return ThemeSelector(selected: mode, onChanged: _selectTheme);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;
  const _CategoryHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: cs.primary,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.onSurface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SettingTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SettingTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle),
      ],
    );
  }
}
