import 'dart:typed_data';

import 'package:firefly_books/core/models/book.dart';
import 'package:firefly_books/features/pages/book_detailed_view.dart';
import 'package:firefly_books/presentation/bookcard/book_card.dart';
import 'package:flutter/material.dart';

class BookGrid extends StatefulWidget {
  final List<EpubBook> books;
  const BookGrid({super.key, required this.books});

  @override
  State<BookGrid> createState() => _BookGridState();
}

class _BookGridState extends State<BookGrid> {
  List<EpubBook> get _books => widget.books;

  @override
  Widget build(BuildContext context) {
    return _books.isEmpty
        ? ListView(
            children: const [
              SizedBox(height: 200),
              Center(child: Text("No books found")),
            ],
          )
        : Column(
            children: [
              Expanded(
                child: GridView.builder(
                  itemCount: _books.length,
                  padding: const EdgeInsets.only(
                    bottom: 75,
                  ), // replaces SizedBox
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2 / 3,
                  ),
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    final title = book.meta.title ?? "No title";
                    final Uint8List? image = book.images;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailedView(book: book),
                          ),
                        );
                      },
                      child: BookCard(title: title, book_image: image),
                    );
                  },
                ),
              ),
            ],
          );
  }
}
