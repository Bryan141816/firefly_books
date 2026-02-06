import 'dart:io';
import 'package:firefly_books/core/data/epub/epub_parser.dart';
import 'package:firefly_books/core/models/book.dart';

class EpubFileHandler {
  // Private constructor
  EpubFileHandler._internal();

  // Single instance
  static final EpubFileHandler _instance = EpubFileHandler._internal();

  List<EpubBook>? _books = null;

  // Factory constructor always returns the same instance
  factory EpubFileHandler() {
    return _instance;
  }

  Future<List<EpubBook>> loadFilesInFolder(String path) async {
    final directory = Directory(path);
    final files = directory.listSync();

    final parser = EpubParser();

    final epubFiles = files
        .where((f) => f is File && f.path.endsWith('.epub'))
        .toList();

    List<EpubBook> books = await parser.parseEpubFiles(epubFiles);
    _books = books;
    return books;
  }

  List<EpubBook>? getLoadedBooks() => _books;
}
