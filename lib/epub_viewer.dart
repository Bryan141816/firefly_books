// lib/epub_webview_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dbHandler.dart';
import 'dart:convert';

class EpubWebViewPage extends StatefulWidget {
  final int? id;
  final String base64Epub;
  final String title;
  const EpubWebViewPage({
    super.key,
    this.id,
    required this.base64Epub,
    required this.title,
  });

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
      ..setBackgroundColor(Colors.transparent)
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

    _loadHtml();
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
        print(' $scrollPosition');
      }
    }

    var brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    String appTheme = brightness == Brightness.dark ? "dark" : "light";
    // Delay a little to make sure JS is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      _controller.runJavaScript(
        "loadEpubFromBase64(${jsonEncode(widget.base64Epub)}, $scrollPosition, ${jsonEncode(appTheme)});",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.secondary;

    final darkerPrimary = HSLColor.fromColor(secondary)
        .withLightness(
          (HSLColor.fromColor(secondary).lightness - 0.67).clamp(0.0, 1.0),
        )
        .toColor();

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
                    color: darkerPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).pop(),
                      ),

                      // Title
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
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
                    color: darkerPrimary,
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
                        style: const TextStyle(color: Colors.white),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Text(
                            '1',
                            style: TextStyle(color: Colors.white),
                          ),

                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
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
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
