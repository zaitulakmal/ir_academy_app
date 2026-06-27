import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/activity.dart';
import '../../core/theme/app_colors.dart';
import 'video_preview_screen.dart';

class AttachmentPreview extends StatelessWidget {
  final ResponseType responseType;
  final String path;
  final String name;

  const AttachmentPreview({super.key, required this.responseType, required this.path, required this.name});

  @override
  Widget build(BuildContext context) {
    if (responseType == ResponseType.photo || responseType == ResponseType.drawing) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(File(path), height: 180, width: double.infinity, fit: BoxFit.cover),
      );
    }

    if (responseType == ResponseType.video) {
      return InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => VideoPreviewScreen(path: path)),
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

    return Container(
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
        ],
      ),
    );
  }
}
