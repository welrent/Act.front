import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';

class LegalDocumentRenderer extends StatelessWidget {
  final String html;
  final Map<String, String>? placeholders;

  const LegalDocumentRenderer({
    super.key,
    required this.html,
    this.placeholders,
  });

  @override
  Widget build(BuildContext context) {
    if (html.trim().isEmpty) {
      return const Text(
        'No content available.',
        style: TextStyle(color: AppColors.designMuted, fontSize: 15),
      );
    }

    String processed = html;
    if (placeholders != null && placeholders!.isNotEmpty) {
      placeholders!.forEach((key, val) {
        processed = processed.replaceAll('[$key]', val);
      });
    }

    final blocks = _parseBlocks(processed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((b) => _buildBlock(context, b)).toList(),
    );
  }

  Widget _buildBlock(BuildContext context, _Block block) {
    switch (block.type) {
      case _BlockType.h1:
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Text(
            block.text,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.designText,
              letterSpacing: -0.5,
              height: 1.3,
            ),
          ),
        );
      case _BlockType.h2:
        return Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Text(
            block.text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.designText,
              letterSpacing: -0.3,
              height: 1.3,
            ),
          ),
        );
      case _BlockType.h3:
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            block.text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.designText,
              height: 1.3,
            ),
          ),
        );
      case _BlockType.hr:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          height: 1,
          color: const Color(0xFFEAECF0),
        );
      case _BlockType.ul:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: block.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.designText,
                      ),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: _parseInlineSpans(item),
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.8,
                            color: AppColors.designText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      case _BlockType.p:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text.rich(
            TextSpan(
              children: _parseInlineSpans(block.text),
              style: const TextStyle(
                fontSize: 15,
                height: 1.8,
                color: AppColors.designText,
              ),
            ),
          ),
        );
    }
  }

  List<_Block> _parseBlocks(String raw) {
    // Strip outer article tags
    var clean = raw
        .replaceAll(RegExp(r'<article[^>]*>', caseSensitive: false), '')
        .replaceAll('</article>', '')
        .trim();

    final blocks = <_Block>[];

    // Regex to identify top-level blocks: h1, h2, h3, hr, ul, p
    final blockRegex = RegExp(
      r'(<h1[^>]*>.*?</h1>|<h2[^>]*>.*?</h2>|<h3[^>]*>.*?</h3>|<hr\s*/?>|<ul[^>]*>.*?</ul>|<p[^>]*>.*?</p>)',
      caseSensitive: false,
      dotAll: true,
    );

    final matches = blockRegex.allMatches(clean);

    for (final m in matches) {
      final chunk = m.group(0)!;
      final tagMatch =
          RegExp(r'^<([a-z0-9]+)', caseSensitive: false).firstMatch(chunk);
      final tag = tagMatch?.group(1)?.toLowerCase() ?? '';

      if (tag == 'h1') {
        final inner = _stripHtml(chunk
            .replaceFirst(RegExp(r'^<h1[^>]*>', caseSensitive: false), '')
            .replaceFirst(RegExp(r'</h1>$', caseSensitive: false), ''));
        blocks.add(_Block(type: _BlockType.h1, text: inner));
      } else if (tag == 'h2') {
        final inner = _stripHtml(chunk
            .replaceFirst(RegExp(r'^<h2[^>]*>', caseSensitive: false), '')
            .replaceFirst(RegExp(r'</h2>$', caseSensitive: false), ''));
        blocks.add(_Block(type: _BlockType.h2, text: inner));
      } else if (tag == 'h3') {
        final inner = _stripHtml(chunk
            .replaceFirst(RegExp(r'^<h3[^>]*>', caseSensitive: false), '')
            .replaceFirst(RegExp(r'</h3>$', caseSensitive: false), ''));
        blocks.add(_Block(type: _BlockType.h3, text: inner));
      } else if (tag == 'hr') {
        blocks.add(_Block(type: _BlockType.hr, text: ''));
      } else if (tag == 'ul') {
        final liRegex =
            RegExp(r'<li[^>]*>(.*?)</li>', caseSensitive: false, dotAll: true);
        final items = <String>[];
        for (final lim in liRegex.allMatches(chunk)) {
          items.add(lim.group(1) ?? '');
        }
        blocks.add(_Block(type: _BlockType.ul, text: '', items: items));
      } else if (tag == 'p') {
        final inner = chunk
            .replaceFirst(RegExp(r'^<p[^>]*>', caseSensitive: false), '')
            .replaceFirst(RegExp(r'</p>$', caseSensitive: false), '');
        blocks.add(_Block(type: _BlockType.p, text: inner));
      }
    }

    // If no blocks parsed (e.g. raw text), split by lines
    if (blocks.isEmpty && clean.isNotEmpty) {
      final lines = clean.split('\n');
      for (final line in lines) {
        if (line.trim().isNotEmpty) {
          blocks.add(_Block(type: _BlockType.p, text: line.trim()));
        }
      }
    }

    return blocks;
  }

  static String _stripHtml(String s) {
    return _decodeEntities(s.replaceAll(RegExp(r'<[^>]*>'), '').trim());
  }

  static String _decodeEntities(String s) {
    return s
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  static List<InlineSpan> _parseInlineSpans(String html) {
    // Replace <br> with \n
    final text =
        html.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    final spans = <InlineSpan>[];

    // Regex for inline tags: <strong>, <em>, <a href="...">
    final inlineRegex = RegExp(
      r'(<strong[^>]*>.*?</strong>|<b[^>]*>.*?</b>|<em[^>]*>.*?</em>|<i[^>]*>.*?</i>|<a\s+[^>]*href=["'
      "'"
      r']([^"'
      "'"
      r']+)["'
      "'"
      r'][^>]*>(.*?)</a>)',
      caseSensitive: false,
      dotAll: true,
    );

    int index = 0;
    for (final m in inlineRegex.allMatches(text)) {
      if (m.start > index) {
        final prefix = text.substring(index, m.start);
        spans.add(TextSpan(text: _decodeEntities(prefix)));
      }

      final chunk = m.group(0)!;
      if (chunk.toLowerCase().startsWith('<strong') ||
          chunk.toLowerCase().startsWith('<b')) {
        final inner = chunk.replaceAll(
            RegExp(r'</?(strong|b)[^>]*>', caseSensitive: false), '');
        spans.add(
          TextSpan(
            text: _decodeEntities(inner),
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.designText),
          ),
        );
      } else if (chunk.toLowerCase().startsWith('<em') ||
          chunk.toLowerCase().startsWith('<i')) {
        final inner = chunk.replaceAll(
            RegExp(r'</?(em|i)[^>]*>', caseSensitive: false), '');
        spans.add(
          TextSpan(
            text: _decodeEntities(inner),
            style: const TextStyle(
                fontStyle: FontStyle.italic, color: Color(0xFF666666)),
          ),
        );
      } else if (chunk.toLowerCase().startsWith('<a')) {
        final url = m.group(2) ?? '';
        final label = m.group(3) ?? url;
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: InkWell(
              onTap: () {
                if (url.startsWith('http://') ||
                    url.startsWith('https://') ||
                    url.startsWith('mailto:')) {
                  launchUrl(Uri.parse(url));
                }
              },
              child: Text(
                _decodeEntities(label),
                style: const TextStyle(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  fontSize: 15,
                  height: 1.8,
                ),
              ),
            ),
          ),
        );
      }
      index = m.end;
    }

    if (index < text.length) {
      spans.add(TextSpan(text: _decodeEntities(text.substring(index))));
    }

    return spans;
  }
}

enum _BlockType { h1, h2, h3, hr, ul, p }

class _Block {
  final _BlockType type;
  final String text;
  final List<String> items;

  _Block({
    required this.type,
    required this.text,
    this.items = const [],
  });
}
