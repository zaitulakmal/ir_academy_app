import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int collapsedMaxLines;

  const ExpandableText({super.key, required this.text, this.collapsedMaxLines = 3});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: const TextStyle(color: AppColors.textPrimary));
        final painter = TextPainter(
          text: span,
          maxLines: widget.collapsedMaxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);
        final isOverflowing = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.text,
              maxLines: _expanded ? null : widget.collapsedMaxLines,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (isOverflowing)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? 'Show less' : 'Show more',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
          ],
        );
      },
    );
  }
}
