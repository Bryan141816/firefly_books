import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firefly_books/core/models/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/data/local/db_handler.dart';
import 'dart:convert';

class EpubWebViewPage extends StatefulWidget {
  final EpubBook book;

  const EpubWebViewPage({super.key, required this.book});

  @override
  State<EpubWebViewPage> createState() => _EpubWebViewPageState();
}

class _EpubWebViewPageState extends State<EpubWebViewPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  DatabaseHelper dbHandler = DatabaseHelper();
  int maxPageCount = 0;
  bool _controlsVisible = false;
  int _pageIndex = 1;
  Timer? _sliderDebounce;
  late Uint8List fileBytes;

  void savePositionDB(double position) async {
    final id = widget.book.meta.id;
    if (id == null) return;
    await dbHandler.updateBookScroll(id, position);
  }

  Future<void> _loadFilePath() async {
    final String? epubPath = widget.book.epubPath;
    if (epubPath == null) throw Exception("epubPath is null");
    fileBytes = await File(epubPath).readAsBytes();
  }

  @override
  void initState() {
    super.initState();
    () async {
      await _loadFilePath();
      await _loadHtml();
    }();

    _controller = WebViewController()
      ..setBackgroundColor(Colors.transparent)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'ReaderLoaded',
        onMessageReceived: (message) {
          () async {
            final id = widget.book.meta.id;
            var scrollPosition = 0.0;
            if (id != null) {
              final bookData = await dbHandler.getBookById(id);
              if (!mounted) return;
              if (bookData != null) {
                scrollPosition =
                    (bookData['scroll_location'] as num?)?.toDouble() ?? 0.0;
              }
            }

            final brightness =
                WidgetsBinding.instance.platformDispatcher.platformBrightness;

            final appTheme = brightness == Brightness.dark ? "dark" : "light";
            if (!mounted) return;
            await sendEpubBase64Chunked(
              fileBytes,
              _controller,
              scrollPosition.toString(),
              appTheme,
            );
          }();
        },
      )
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
          maxPageCount = int.parse(message.message);
          setState(() {
            _isLoading = false;
          });
        },
      )
      ..addJavaScriptChannel(
        'PageChanged',
        onMessageReceived: (message) {
          setState(() {
            _pageIndex = int.parse(message.message) + 1;
          });
        },
      );
  }

  void toggleControlsVisibility() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
  }

  void goToPage(int page) {
    _controller.runJavaScript("goToPage($page);");
  }

  Future<void> _loadHtml() async {
    final jszip = await rootBundle.loadString('assets/jszip.min.js');
    var html = await rootBundle.loadString('assets/epub_reader.html');
    html = html.replaceFirst('<head>', '<head><script>$jszip</script>');

    _controller.loadHtmlString(html);
  }

  Future<void> sendEpubBase64Chunked(
    Uint8List bytes,
    dynamic controller,
    String scrollPosition,
    String appTheme, {
    int chunkSize = 200000, // chars
  }) async {
    final b64 = base64Encode(bytes);

    await controller.runJavaScript(
      "epubRxStart(${jsonEncode(scrollPosition)}, ${jsonEncode(appTheme)});",
    );

    for (int i = 0; i < b64.length; i += chunkSize) {
      final end = (i + chunkSize < b64.length) ? i + chunkSize : b64.length;
      final chunk = b64.substring(i, end);
      await controller.runJavaScript("epubRxChunk(${jsonEncode(chunk)});");
    }

    await controller.runJavaScript("epubRxEnd();");
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (_) => toggleControlsVisibility(),
            ),
            if (_controlsVisible)
              Positioned(
                top: 20,
                left: 10,
                right: 10,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: colors.onSecondary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),

                      // Title
                      Expanded(
                        child: Text(
                          widget.book.meta.title ?? "Title",
                          style: TextStyle(
                            color: colors.onSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_controlsVisible && maxPageCount != 0)
              Positioned(
                bottom: 20,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10, // 👈 top & bottom padding
                  ),
                  decoration: BoxDecoration(
                    color: colors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // 👈 wrap content vertically
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // 👈 center horizontally
                    children: [
                      Text(
                        '$_pageIndex/$maxPageCount',
                        style: TextStyle(color: colors.onSecondary),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Text(
                            '1',
                            style: TextStyle(color: colors.onSecondary),
                          ),

                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                                thumbColor: colors.primary,

                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 14,
                                ),
                              ),
                              child: Slider(
                                min: 1,
                                max: maxPageCount.toDouble(),
                                divisions: maxPageCount - 1,
                                value: _pageIndex.toDouble(),
                                onChanged: (v) {
                                  setState(() => _pageIndex = v.floor());

                                  // cancel previous timer
                                  _sliderDebounce?.cancel();

                                  // start new debounce timer
                                  _sliderDebounce = Timer(
                                    const Duration(milliseconds: 50),
                                    () {
                                      goToPage(_pageIndex);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),

                          Text(
                            maxPageCount.toString(),
                            style: TextStyle(color: colors.onSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            if (_isLoading)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: colors.surface,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
