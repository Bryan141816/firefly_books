import 'dart:typed_data';

import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String title;
  final Uint8List? book_image;

  const BookCard({super.key, required this.title, this.book_image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Center(
            child: book_image != null
                ? Image.memory(
                    book_image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : const Text("No cover Image"),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xcc000000), Colors.transparent],
                stops: [0.0, 0.5],
              ),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 15,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
