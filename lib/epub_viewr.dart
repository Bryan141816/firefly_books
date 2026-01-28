// lib/epub_webview_page.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dbHandler.dart';
import 'dart:convert';

class EpubWebViewPage extends StatefulWidget {
  final int? id;
  final String base64Epub;
  const EpubWebViewPage({super.key, this.id, required this.base64Epub});

  @override
  State<EpubWebViewPage> createState() => _EpubWebViewPageState();
}

class _EpubWebViewPageState extends State<EpubWebViewPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  DatabaseHelper dbHandler = DatabaseHelper();

  void savePositionDB(double position) async {
    final id = widget.id;
    if (id != null) {
      await dbHandler.updateBookScroll(id, position);
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'ReaderScrolled',
        onMessageReceived: (message) {
          double position = double.parse(message.message);
          savePositionDB(position);
        },
      )
      ..addJavaScriptChannel(
        'FileLoaded',
        onMessageReceived: (message) {
          setState(() {
            _isLoading = false;
          });
        },
      );

    _loadHtml();
  }

  Future<void> _loadHtml() async {
    String jszip = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/jszip.min.js');
    String html = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/epub_reader.html');
    html = html.replaceFirst('<head>', '<head><script>$jszip</script>');

    _controller.loadHtmlString(html);

    int? id = widget.id;
    double scrollPosition = 0;
    if (id != null) {
      var bookData = await dbHandler.getBookById(id);
      if (bookData != null) {
        scrollPosition = bookData['scroll_location'];
      }
    }

    // Delay a little to make sure JS is ready
    Future.delayed(const Duration(milliseconds: 200), () {
      _controller.runJavaScript(
        "loadEpubFromBase64(${jsonEncode(widget.base64Epub)}, $scrollPosition);",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EPUB Reader')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
