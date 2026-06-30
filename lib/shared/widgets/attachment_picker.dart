import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'drawing_canvas_screen.dart';

class PickedAttachment {
  final String path;
  final String name;
  final Uint8List? bytes;

  const PickedAttachment({required this.path, required this.name, this.bytes});
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

Future<PickedAttachment> _toPickedAttachment(XFile file) async {
  final bytes = kIsWeb ? await file.readAsBytes() : null;
  return PickedAttachment(path: file.path, name: file.name, bytes: bytes);
}

Future<PickedAttachment?> pickPhoto(BuildContext context) async {
  final source = await _chooseSource(context, isVideo: false);
  if (source == null) return null;
  final file = await ImagePicker().pickImage(source: source, imageQuality: 80);
  if (file == null) return null;
  return _toPickedAttachment(file);
}

Future<PickedAttachment?> pickVideo(BuildContext context) async {
  final source = await _chooseSource(context, isVideo: true);
  if (source == null) return null;
  final file = await ImagePicker().pickVideo(source: source, maxDuration: const Duration(minutes: 5));
  if (file == null) return null;
  return _toPickedAttachment(file);
}

PickedAttachment? _platformFileToPicked(PlatformFile file) {
  // On web, PlatformFile.path is a throwing getter — never access it there.
  if (kIsWeb) {
    if (file.bytes == null) return null;
    return PickedAttachment(path: file.name, name: file.name, bytes: file.bytes);
  }
  if (file.path == null) return null;
  return PickedAttachment(path: file.path!, name: file.name);
}

Future<PickedAttachment?> pickWorksheet() async {
  final result = await FilePicker.platform.pickFiles(type: FileType.any, withData: kIsWeb);
  if (result == null || result.files.isEmpty) return null;
  return _platformFileToPicked(result.files.first);
}

Future<List<PickedAttachment>> pickWorksheets() async {
  final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true, withData: kIsWeb);
  if (result == null) return [];
  return result.files.map(_platformFileToPicked).whereType<PickedAttachment>().toList();
}

Future<List<PickedAttachment>> pickPhotos(BuildContext context) async {
  final source = await _chooseSource(context, isVideo: false);
  if (source == null) return [];
  if (source == ImageSource.camera) {
    final file = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
    if (file == null) return [];
    return [await _toPickedAttachment(file)];
  }
  final files = await ImagePicker().pickMultiImage(imageQuality: 80);
  return Future.wait(files.map(_toPickedAttachment));
}

Future<PickedAttachment?> pickDrawing(BuildContext context) async {
  final result = await Navigator.of(context).push<DrawingResult>(
    MaterialPageRoute(builder: (_) => const DrawingCanvasScreen()),
  );
  if (result == null) return null;
  return PickedAttachment(path: result.path ?? 'drawing.png', name: 'drawing.png', bytes: result.bytes);
}
