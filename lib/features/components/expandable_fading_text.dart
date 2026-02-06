import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExpandableFadingText extends StatefulWidget {
  final String text;
  final int collapsedLines;

  const ExpandableFadingText({
    super.key,
    required this.text,
    this.collapsedLines = 4,
  });

  @override
  State<ExpandableFadingText> createState() => _ExpandableFadingTextState();
}

class _ExpandableFadingTextState extends State<ExpandableFadingText> {
  bool _expanded = false;
  bool _overflow = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium!;
    final color = style.color ?? Theme.of(context).colorScheme.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Detect overflow
        final tp = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: widget.collapsedLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        _overflow = tp.didExceedMaxLines;

        final lineHeight = (style.height ?? 1.2) * (style.fontSize ?? 14);
        final collapsedHeight = lineHeight * widget.collapsedLines;

        return Stack(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: SizedBox(
                height: _expanded ? null : collapsedHeight,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: _expanded ? 50.0 : 0.0, // 👈 gap after expanded
                  ),
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) {
                      if (_expanded || !_overflow) {
                        return const LinearGradient(
                          colors: [Colors.white, Colors.white],
                        ).createShader(rect);
                      }

                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.4, 0.8],
                        colors: [
                          Colors.white,
                          Colors.white,
                          Colors.transparent,
                        ],
                      ).createShader(rect);
                    },
                    child: Text(
                      widget.text,
                      maxLines: _expanded ? null : widget.collapsedLines,
                      overflow: TextOverflow.clip,
                      style: style.copyWith(color: color, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ),

            if (_overflow)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    icon: AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(CupertinoIcons.chevron_down, size: 16),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
