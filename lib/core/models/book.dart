import 'dart:typed_data';

class EpubMeta {
  int? id;
  final String? title;
  final String? author;
  final String? coverImageHref;
  EpubMeta({this.id, this.title, this.author, this.coverImageHref});

  @override
  String toString() {
    return 'EpubMeta(title: $title, author: $author, coverImageHref: $coverImageHref)';
  }
}

class EpubBook {
  final EpubMeta meta;
  final Uint8List? images;
  final String filebase64;
  EpubBook({
    required this.meta,
    required this.images,
    required this.filebase64,
  });
}
