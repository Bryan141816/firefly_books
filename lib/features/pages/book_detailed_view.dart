import 'dart:typed_data';

import 'package:firefly_books/core/data/local/db_handler.dart';
import 'package:firefly_books/core/models/book.dart';
import 'package:firefly_books/features/components/expandable_fading_text.dart';
import 'package:firefly_books/features/pages/epub_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookDetailedView extends StatefulWidget {
  final EpubBook book;
  final Uint8List epubFile;
  const BookDetailedView({
    super.key,
    required this.book,
    required this.epubFile,
  });

  @override
  State<StatefulWidget> createState() => _BookDetailedView();
}

class _BookDetailedView extends State<BookDetailedView> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.book.meta.isFavorite ?? false;
  }

  DatabaseHelper dbHandler = DatabaseHelper();
  void toggleIsFavorite(bool state) async {
    final id = widget.book.meta.id;
    if (id == null) return;

    try {
      final result = await dbHandler.toggleIsFavorite(id, state);
      if (!mounted) return;

      if (result) {
        setState(() => isFavorite = state);
        widget.book.meta.setIsFavorite(state);
      }
    } catch (e, st) {
      debugPrint("toggleIsFavorite error: $e");
      debugPrintStack(stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;
    final appBarHeight = kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.memory(widget.book.images!, fit: BoxFit.cover),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    colors.surface,
                    colors.surface.withValues(alpha: 0.9),
                  ],
                  stops: const [0.75, 1],
                ),
              ),
            ),
          ),

          // Foreground scrolls
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: topPadding + appBarHeight + 20,
              left: 20,
              right: 20,
              bottom: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          widget.book.images!,
                          fit: BoxFit.cover,
                          height: double.infinity,
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.book.meta.title ?? "No title",
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(CupertinoIcons.person, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.book.meta.author ?? "No author",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EpubWebViewPage(
                                bookMeta: widget.book.meta,
                                epubFile: widget.epubFile,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: colors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.play_arrow_solid,
                              size: 18,
                              color: colors.onPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Start Reading",
                              style: TextStyle(color: colors.onPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: isFavorite
                          ? TextButton(
                              onPressed: () {
                                toggleIsFavorite(!isFavorite);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: colors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.heart_fill,
                                    size: 18,
                                    color: colors.onPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Add to Favorites",
                                    style: TextStyle(color: colors.onPrimary),
                                  ),
                                ],
                              ),
                            )
                          : OutlinedButton(
                              onPressed: () {
                                toggleIsFavorite(!isFavorite);
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: colors.primary,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(CupertinoIcons.heart, size: 18),
                                  SizedBox(width: 8),
                                  Text("Add to Favorites"),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ExpandableFadingText(
                  text: widget.book.meta.description ?? "",
                  collapsedLines: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
