import 'package:firefly_books/core/data/epub/epub_file_handler.dart';
import 'package:flutter/material.dart';
import '../../core/data/local/db_handler.dart';
import '../../core/models/book.dart';
import '../components/book_grid.dart';

class BookList extends StatefulWidget {
  final String booksPath;
  final bool Function(EpubBook book)? checker;
  const BookList({super.key, required this.booksPath, this.checker});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  List<EpubBook> _books = [];
  DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> _loadFiles() async {
    EpubFileHandler epubFileHandler = EpubFileHandler();
    List<EpubBook>? book = epubFileHandler.getLoadedBooks();

    book ??= await epubFileHandler.loadFilesInFolder(widget.booksPath);
    final checker = widget.checker;
    book = checker == null ? book : book.where((b) => checker(b)).toList();
    if (!mounted) return;
    setState(() {
      if (book == null) return;
      _books = book;
    });
  }

  Future<void> _refreshFiles() async {
    EpubFileHandler epubFileHandler = EpubFileHandler();
    List<EpubBook> book = await epubFileHandler.loadFilesInFolder(
      widget.booksPath,
    );
    final checker = widget.checker;
    book = checker == null ? book : book.where((b) => checker(b)).toList();

    if (!mounted) return;
    setState(() {
      _books = book;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshFiles,
      child: BookGrid(books: _books),
    );
  }
}
