import 'package:firefly_books/core/data/local/shared_preferences_handle.dart';
import 'package:firefly_books/core/models/book.dart';
import 'package:firefly_books/features/pages/book_list.dart';
import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});
  bool checker(EpubBook book) {
    return book.meta.isFavorite ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final booksPath = PrefsService.instance.booksDirectory;
    return BookList(booksPath: booksPath, checker: checker);
  }
}
