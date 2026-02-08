import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart'; // ✅ add this
import 'package:collection/collection.dart';
import 'package:firefly_books/core/models/book.dart';
import 'package:firefly_books/core/data/local/db_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

class EpubParser {
  DatabaseHelper dbHelper = DatabaseHelper();

  EpubMeta _parseContentMeta(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    const dcNs = 'http://purl.org/dc/elements/1.1/';

    final title = document
        .findAllElements('title', namespace: dcNs)
        .firstWhereOrNull((_) => true)
        ?.innerText;

    final author = document
        .findAllElements('creator', namespace: dcNs)
        .firstWhereOrNull((_) => true)
        ?.innerText;

    final description = document
        .findAllElements('description', namespace: dcNs)
        .firstWhereOrNull((_) => true)
        ?.innerText;
    final coverId = document
        .findAllElements('meta')
        .firstWhereOrNull(
          (e) => e.getAttribute('name')?.contains('cover') ?? false,
        )
        ?.getAttribute('content');

    final coverItem = document
        .findAllElements('item')
        .firstWhereOrNull(
          (e) =>
              coverId != null &&
              e.getAttribute('id')?.contains(coverId) == true,
        );

    final coverImageHref = coverItem?.getAttribute('href');

    return EpubMeta(
      title: title,
      author: author,
      description: description,
      coverImageHref: coverImageHref,
    );
  }

  String _getRootFilePath(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    const namespace = 'urn:oasis:names:tc:opendocument:xmlns:container';

    final rootfileElement = document
        .findAllElements('rootfile', namespace: namespace)
        .first;

    return rootfileElement.getAttribute('full-path').toString();
  }

  EpubBook _readEpubFromFile(String filepath) {
    final input = InputFileStream(filepath); // stream from disk
    final archive = ZipDecoder().decodeStream(input); // ✅ correct method

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
      orElse: () => throw Exception('$contentPath not found'),
    );

    final contentXmlString = utf8.decode(
      contentXml.content as List<int>,
      allowMalformed: true,
    );

    final meta = _parseContentMeta(contentXmlString);

    Uint8List? coverImageBytes;
    if (meta.coverImageHref != null) {
      final coverFile = archive.firstWhereOrNull(
        (f) => f.isFile && f.name.endsWith(meta.coverImageHref!),
      );
      if (coverFile != null) {
        coverImageBytes = Uint8List.fromList(coverFile.content as List<int>);
      }
    }

    return EpubBook(meta: meta, images: coverImageBytes, epubPath: filepath);
  }

  Future<EpubBook> readEpubCompute(String filepath) async {
    return compute(_readEpubFromFile, filepath);
  }

  Future<List<EpubBook>> parseEpubFiles(
    List<FileSystemEntity> epubFiles,
  ) async {
    final books = await Future.wait(
      epubFiles.map((file) {
        return readEpubCompute(file.path);
      }),
    );

    for (final book in books) {
      final title = book.meta.title;
      if (title == null) continue;

      final bookRecord = await dbHelper.getBookByName(title);

      if (bookRecord != null) {
        book.meta.id = bookRecord['id'] as int;
        book.meta.isFavorite = (bookRecord['is_favorite'] as int) == 1;
      } else {
        final id = await dbHelper.insertBook(title);
        book.meta.id = id;
        book.meta.isFavorite = false;
      }
    }
    return books;
  }
}
