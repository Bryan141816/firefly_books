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
            // needed so RefreshIndicator can scroll
            children: const [
              SizedBox(height: 200),
              Center(child: Text("No books found")),
            ],
          )
        : GridView.builder(
            itemCount: _books.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2 / 3,
            ),
            itemBuilder: (context, index) {
              final book = _books[index];
              final bookMeta = book.meta;
              final title = bookMeta.title ?? "No title";
              final image = book.images!;
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
          );
  }
}
