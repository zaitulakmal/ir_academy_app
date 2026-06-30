import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/app_colors.dart';

class _Stroke {
  final List<Offset> points;
  final Color color;

  _Stroke(this.color) : points = [];
}

class _DrawingPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final bool paintWhiteBackground;

  _DrawingPainter(this.strokes, {this.paintWhiteBackground = true});

  @override
  void paint(Canvas canvas, Size size) {
    if (paintWhiteBackground) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);
    }
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (var i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}

/// Returns the saved PNG file path, or null if the user cancelled without drawing.
class DrawingCanvasScreen extends StatefulWidget {
  final String? backgroundImagePath;
  final String title;

  const DrawingCanvasScreen({super.key, this.backgroundImagePath, this.title = 'Drawing'});

  @override
  State<DrawingCanvasScreen> createState() => _DrawingCanvasScreenState();
}

class _DrawingCanvasScreenState extends State<DrawingCanvasScreen> {
  final _repaintKey = GlobalKey();
  final List<_Stroke> _strokes = [];
  Color _color = AppColors.accent;

  static const _palette = [AppColors.accent, AppColors.primary, Colors.black, AppColors.success, AppColors.warning];

  Future<void> _saveAndExit() async {
    if (_strokes.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/drawing_${DateTime.now().microsecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);

    if (mounted) Navigator.of(context).pop(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.trash),
            onPressed: () => setState(_strokes.clear),
          ),
          TextButton(
            onPressed: _saveAndExit,
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _repaintKey,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.backgroundImagePath != null) Image.file(File(widget.backgroundImagePath!), fit: BoxFit.contain),
                  GestureDetector(
                    onPanStart: (details) =>
                        setState(() => _strokes.add(_Stroke(_color)..points.add(details.localPosition))),
                    onPanUpdate: (details) => setState(() => _strokes.last.points.add(details.localPosition)),
                    child: CustomPaint(
                      painter: _DrawingPainter(_strokes, paintWhiteBackground: widget.backgroundImagePath == null),
                      size: Size.infinite,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderLight))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _palette.map((c) {
                final selected = c == _color;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: selected ? 36 : 28,
                    height: selected ? 36 : 28,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected ? Border.all(color: AppColors.textPrimary, width: 2) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
