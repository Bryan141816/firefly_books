import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:firefly_books/core/models/book.dart';
import 'package:firefly_books/core/data/local/db_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

class EpubParser {
  DatabaseHelper dbHelper = DatabaseHelper();

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

    return EpubMeta(
      title: title,
      author: author,
      coverImageHref: coverImageHref,
    );
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

  Future<EpubBook> readEpubCompute(String filepath) async {
    final bytes = await File(filepath).readAsBytes();
    return await compute(_readEpubFromBytes, bytes);
  }

  Future<List<EpubBook>> parseEpubFiles(
    List<FileSystemEntity> epubFiles,
  ) async {
    List<EpubBook> books = [];

    for (var file in epubFiles) {
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
        }

        books.add(book);
      } catch (e) {
        throw ('Failed to read ${file.path}: $e');
      }
    }
    return books;
  }
}
