import 'package:firefly_books/core/data/epub/epub_file_handler.dart';
import 'package:flutter/material.dart';
import '../../core/data/local/db_handler.dart';
import '../../core/models/book.dart';
import '../components/book_grid.dart';

class BookList extends StatefulWidget {
  final String booksPath;
  const BookList({super.key, required this.booksPath});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  List<EpubBook> _books = [];
  DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> _loadFiles() async {
    EpubFileHandler epubFileHandler = EpubFileHandler();
    List<EpubBook> book = await epubFileHandler.loadFilesInFolder(
      widget.booksPath,
    );
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
    return Scaffold(
      appBar: AppBar(title: const Text("Library")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: RefreshIndicator(
          onRefresh: _loadFiles,
          child: BookGrid(books: _books),
        ),
      ),
    );
  }
}
