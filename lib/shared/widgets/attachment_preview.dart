import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      return InkWell(
        onTap: () => openAttachment(path: path, bytes: bytes, name: name),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: kIsWeb && bytes != null
              ? Image.memory(bytes!, height: 180, width: double.infinity, fit: BoxFit.cover)
              : Image.file(File(path), height: 180, width: double.infinity, fit: BoxFit.cover),
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
