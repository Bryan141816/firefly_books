import 'dart:typed_data';

class EpubMeta {
  int? id;
  bool? isFavorite;
  final String? title;
  final String? author;
  final String? description;
  final String? coverImageHref;
  EpubMeta({
    this.id,
    this.isFavorite,
    this.title,
    this.author,
    this.coverImageHref,
    this.description,
  });

  @override
  String toString() {
    return 'EpubMeta(title: $title, author: $author, coverImageHref: $coverImageHref)';
  }

  void setIsFavorite(bool state) {
    isFavorite = state;
  }
}

class EpubBook {
  final EpubMeta meta;
  final Uint8List? images;
  final Uint8List epubFile;
  EpubBook({required this.meta, required this.images, required this.epubFile});
}
