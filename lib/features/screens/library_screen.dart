import 'package:firefly_books/core/data/local/shared_preferences_handle.dart';
import 'package:firefly_books/features/pages/book_list.dart';
import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final booksPath = PrefsService.instance.booksDirectory;
    return BookList(booksPath: booksPath);
  }
}
