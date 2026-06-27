import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'drawing_canvas_screen.dart';

class PickedAttachment {
  final String path;
  final String name;

  const PickedAttachment({required this.path, required this.name});
}

Future<ImageSource?> _chooseSource(BuildContext context, {required bool isVideo}) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(isVideo ? PhosphorIconsRegular.videoCamera : PhosphorIconsRegular.camera),
            title: Text(isVideo ? 'Record Video' : 'Take Photo'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(PhosphorIconsRegular.imageSquare),
            title: const Text('Choose from Library'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
}

Future<PickedAttachment?> pickPhoto(BuildContext context) async {
  final source = await _chooseSource(context, isVideo: false);
  if (source == null) return null;
  final file = await ImagePicker().pickImage(source: source, imageQuality: 80);
  if (file == null) return null;
  return PickedAttachment(path: file.path, name: file.name);
}

Future<PickedAttachment?> pickVideo(BuildContext context) async {
  final source = await _chooseSource(context, isVideo: true);
  if (source == null) return null;
  final file = await ImagePicker().pickVideo(source: source, maxDuration: const Duration(minutes: 5));
  if (file == null) return null;
  return PickedAttachment(path: file.path, name: file.name);
}

Future<PickedAttachment?> pickWorksheet() async {
  final result = await FilePicker.platform.pickFiles(type: FileType.any);
  if (result == null || result.files.isEmpty) return null;
  final file = result.files.first;
  if (file.path == null) return null;
  return PickedAttachment(path: file.path!, name: file.name);
}

Future<PickedAttachment?> pickDrawing(BuildContext context) async {
  final path = await Navigator.of(context).push<String>(
    MaterialPageRoute(builder: (_) => const DrawingCanvasScreen()),
  );
  if (path == null) return null;
  return PickedAttachment(path: path, name: 'drawing.png');
}
