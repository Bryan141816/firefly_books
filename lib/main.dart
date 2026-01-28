import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import 'package:collection/collection.dart';
import 'epub_viewr.dart';
import 'dbHandler.dart';

class EpubMeta {
  int? id;
  final String? title;
  final String? author;
  final String? coverImageHref;
  EpubMeta({this.id, this.title, this.author, this.coverImageHref});

  @override
  String toString() {
    return 'EpubMeta(title: $title, author: $author, coverImageHref: $coverImageHref)';
  }
}

class EpubBook {
  final EpubMeta meta;
  final Uint8List? images;
  final String filebase64;
  EpubBook({
    required this.meta,
    required this.images,
    required this.filebase64,
  });
}

EpubMeta _parseContentMeta(String xmlString) {
  final document = XmlDocument.parse(xmlString);

  // EPUB namespaces
  const dcNs = 'http://purl.org/dc/elements/1.1/';

  // ---- TITLE ----
  final title = document
      .findAllElements('title', namespace: dcNs)
      .firstWhereOrNull((_) => true)
      ?.innerText;

  // ---- AUTHOR ----
  final author = document
      .findAllElements('creator', namespace: dcNs)
      .firstWhereOrNull((_) => true)
      ?.innerText;

  // ---- COVER IMAGE ----
  final coverItem = document
      .findAllElements('item')
      .firstWhereOrNull(
        (e) => e.getAttribute('properties')?.contains('cover-image') ?? false,
      );

  final coverImageHref = coverItem?.getAttribute('href');

  return EpubMeta(title: title, author: author, coverImageHref: coverImageHref);
}

String _getRootFilePath(String xmlString) {
  final document = XmlDocument.parse(xmlString);

  // Define the namespace used in the XML
  const namespace = 'urn:oasis:names:tc:opendocument:xmlns:container';

  // Find the rootfile element inside the namespace
  final rootfileElement = document
      .findAllElements('rootfile', namespace: namespace)
      .first;

  // Get the full-path attribute
  final fullPath = rootfileElement.getAttribute('full-path');

  return fullPath.toString();
}

EpubBook _readEpubFromBytes(Uint8List bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);

  final containerFile = archive.firstWhere(
    (f) => f.isFile && f.name == 'META-INF/container.xml',
    orElse: () => throw Exception('container.xml not found in EPUB'),
  );

  final containerXmlString = utf8.decode(
    containerFile.content as List<int>,
    allowMalformed: true,
  );
  final contentPath = _getRootFilePath(containerXmlString);

  final contentXml = archive.firstWhere(
    (f) => f.isFile && f.name == contentPath,
    orElse: () => throw Exception("$contentPath not found"),
  );

  final contentXmlString = utf8.decode(
    contentXml.content as List<int>,
    allowMalformed: true,
  );

  EpubMeta meta = _parseContentMeta(contentXmlString);

  Uint8List? coverImageBytes;
  if (meta.coverImageHref != null) {
    try {
      final coverImage = archive.firstWhere(
        (f) => f.isFile && f.name.endsWith(meta.coverImageHref!),
      );
      coverImageBytes = coverImage.content;
    } catch (_) {
      coverImageBytes = null;
    }
  }

  final String base64Str = base64Encode(bytes);

  return EpubBook(meta: meta, images: coverImageBytes, filebase64: base64Str);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<EpubBook> _books = [];
  DatabaseHelper dbHelper = DatabaseHelper();
  // Request storage permission
  Future<bool> _requestStoragePermission() async {
    var status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  Future<EpubBook> readEpubCompute(String filePath) async {
    final bytes = await File(filePath).readAsBytes(); // read in main isolate
    return await compute(_readEpubFromBytes, bytes);
  }

  Future<void> _openDirectoryPicker() async {
    bool granted = await _requestStoragePermission();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Storage permission denied")),
      );
      return;
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;

    final directory = Directory(selectedDirectory);
    final files = directory.listSync();
    List<FileSystemEntity> epubFiles = files
        .where((f) => f is File && f.path.endsWith('.epub'))
        .toList();

    List<EpubBook> books = [];

    for (var file in epubFiles) {
      // compute runs _readEpubFromPath off the main thread
      try {
        EpubBook book = await readEpubCompute(file.path);

        if (book.meta.title != null) {
          var bookRecord = await dbHelper.getBookByName(book.meta.title!);
          if (bookRecord != null) {
            book.meta.id = bookRecord['id'];
          } else {
            int id = await dbHelper.insertBook(book.meta.title!);
            book.meta.id = id;
          }
          print("Book id: ${book.meta.id}");
        }

        books.add(book);
      } catch (e) {
        print('Failed to read ${file.path}: $e');
      }
    }

    setState(() {
      _books = books;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _openDirectoryPicker,
            child: const Text("Select Folder"),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: _books.length, // Important!
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2 / 3,
                ),

                itemBuilder: (context, index) {
                  final book = _books[index];
                  return GestureDetector(
                    onTap: () {
                      // Just navigate to the WebView page
                      final base64File = book.filebase64;
                      final id = book.meta.id;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EpubWebViewPage(id: id, base64Epub: base64File),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: book.images != null
                                ? Image.memory(book.images!, fit: BoxFit.cover)
                                : const Text("No Cover Image"),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black87, Colors.transparent],
                                  stops: [0.0, 0.3],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            right: 8,
                            bottom: 15,
                            child: Text(
                              book.meta.title ?? "No Title",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
