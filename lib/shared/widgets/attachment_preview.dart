import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/activity.dart';
import '../../core/theme/app_colors.dart';
import '../utils/file_opener.dart';
import 'video_preview_screen.dart';

class AttachmentPreview extends StatelessWidget {
  final ResponseType responseType;
  final String path;
  final String name;
  final Uint8List? bytes;

  const AttachmentPreview({
    super.key,
    required this.responseType,
    required this.path,
    required this.name,
    this.bytes,
  });

  @override
  Widget build(BuildContext context) {
    if (responseType == ResponseType.photo || responseType == ResponseType.drawing) {
      final Widget image = kIsWeb && bytes != null
          ? Image.memory(bytes!, width: double.infinity, fit: BoxFit.contain)
          : path.startsWith('http')
              ? NetworkPhoto(url: path)
              : Image.file(File(path), width: double.infinity, fit: BoxFit.contain);
      return InkWell(
        onTap: () => openAttachment(path: path, bytes: bytes, name: name),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 120, maxHeight: 360),
            color: AppColors.borderLight,
            alignment: Alignment.center,
            child: image,
          ),
        ),
      );
    }

    if (responseType == ResponseType.video) {
      return InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => VideoPreviewScreen(path: path, bytes: bytes)),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.borderLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(PhosphorIconsFill.playCircle, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => openAttachment(path: path, bytes: bytes, name: name),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(PhosphorIconsFill.fileText, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
            const Icon(PhosphorIconsRegular.arrowSquareOut, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// Image.network silently fails to paint on the CanvasKit web renderer for
// some remote JPEGs even though the bytes fetch and decode fine — fetching
// the bytes ourselves and handing them to Image.memory sidesteps it.
class NetworkPhoto extends StatefulWidget {
  final String url;

  const NetworkPhoto({super.key, required this.url});

  @override
  State<NetworkPhoto> createState() => _NetworkPhotoState();
}

class _NetworkPhotoState extends State<NetworkPhoto> {
  late Future<Uint8List> _future = _fetch();

  Future<Uint8List> _fetch() async {
    final response = await http.get(Uri.parse(widget.url));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    return response.bodyBytes;
  }

  @override
  void didUpdateWidget(NetworkPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      setState(() => _future = _fetch());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(snapshot.data!, width: double.infinity, fit: BoxFit.contain);
        }
        if (snapshot.hasError) {
          return const SizedBox(
            height: 180,
            child: Center(child: Icon(PhosphorIconsRegular.imageBroken, size: 32, color: AppColors.textSecondary)),
          );
        }
        return const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }
}
