import 'dart:io';
import 'package:firefly_books/core/data/epub/epub_parser.dart';
import 'package:firefly_books/core/models/book.dart';

class EpubFileHandler {
  // ignore: non_constant_identifier_names
  Future<List<EpubBook>> loadFilesInFolder(String path) async {
    final directory = Directory(path);
    final files = directory.listSync();

    EpubParser parser = EpubParser();

    List<FileSystemEntity> epubFiles = files
        .where((f) => f is File && f.path.endsWith('.epub'))
        .toList();

    List<EpubBook> books = await parser.parseEpubFiles(epubFiles);

    return books;
  }
}
