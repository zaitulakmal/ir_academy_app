import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/chat_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/attachment_picker.dart';

class AnnouncementComposerScreen extends StatefulWidget {
  final AnnouncementPost? existingPost;
  final void Function(AnnouncementPost post) onPost;
  final VoidCallback? onDelete;

  const AnnouncementComposerScreen({super.key, this.existingPost, required this.onPost, this.onDelete});

  @override
  State<AnnouncementComposerScreen> createState() => _AnnouncementComposerScreenState();
}

class _AnnouncementComposerScreenState extends State<AnnouncementComposerScreen> {
  late final _bodyController = TextEditingController(text: widget.existingPost?.body ?? '');
  late PickedAttachment? _attachment = widget.existingPost?.attachmentPath != null
      ? PickedAttachment(
          path: widget.existingPost!.attachmentPath!,
          name: widget.existingPost!.attachmentName ?? '',
          bytes: widget.existingPost!.attachmentBytes,
        )
      : null;
  late AnnouncementAttachmentType _attachmentType = widget.existingPost?.attachmentType ?? AnnouncementAttachmentType.none;

  bool get _isEditing => widget.existingPost != null;
  bool get _canPost => _bodyController.text.trim().isNotEmpty || _attachment != null;

  Future<void> _pickPhotoVideo({required bool isVideo}) async {
    final PickedAttachment? picked;
    if (isVideo) {
      picked = await pickVideo(context);
    } else {
      picked = await pickPhoto(context);
    }
    if (picked == null) return;
    setState(() {
      _attachment = picked;
      _attachmentType = isVideo ? AnnouncementAttachmentType.video : AnnouncementAttachmentType.photo;
    });
  }

  Future<void> _pickFile() async {
    final picked = await pickWorksheet();
    if (picked == null) return;
    setState(() {
      _attachment = picked;
      _attachmentType = AnnouncementAttachmentType.file;
    });
  }

  void _removeAttachment() => setState(() {
        _attachment = null;
        _attachmentType = AnnouncementAttachmentType.none;
      });

  void _post() {
    if (!_canPost) return;
    widget.onPost(AnnouncementPost(
      body: _bodyController.text.trim(),
      author: widget.existingPost?.author ?? MockData.teacherName,
      timeLabel: widget.existingPost?.timeLabel ?? 'Just now',
      attachmentType: _attachmentType,
      attachmentPath: _attachment?.path,
      attachmentName: _attachment?.name,
      attachmentBytes: _attachment?.bytes,
    ));
    Navigator.of(context).pop();
  }

  void _delete() {
    widget.onDelete?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEditing ? 'Edit post' : 'New post'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(PhosphorIconsRegular.trash, color: AppColors.danger),
              onPressed: _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(MockData.teacherName[0],
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Text(MockData.teacherName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bodyController,
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'What\'s happening at ${MockData.schoolName}?',
              border: InputBorder.none,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          if (_attachment != null) ...[
            Stack(
              children: [
                _AttachmentPreview(type: _attachmentType, attachment: _attachment!),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: _removeAttachment,
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.black54,
                      child: Icon(PhosphorIconsBold.x, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ] else
            InkWell(
              onTap: () => _pickPhotoVideo(isVideo: false),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight, width: 1.5),
                ),
                child: const Column(
                  children: [
                    Icon(PhosphorIconsRegular.image, size: 28, color: AppColors.textSecondary),
                    SizedBox(height: 8),
                    Text('Add photos/videos', style: TextStyle(fontWeight: FontWeight.w700)),
                    Text('or tap to choose', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              IconButton(
                icon: const Icon(PhosphorIconsFill.image, color: AppColors.primary),
                onPressed: () => _pickPhotoVideo(isVideo: false),
              ),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.paperclip),
                onPressed: _pickFile,
              ),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.videoCamera),
                onPressed: () => _pickPhotoVideo(isVideo: true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canPost ? _post : null,
              child: Text(_isEditing ? 'Update' : 'Post to entire School'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  final AnnouncementAttachmentType type;
  final PickedAttachment attachment;

  const _AttachmentPreview({required this.type, required this.attachment});

  @override
  Widget build(BuildContext context) {
    if (type == AnnouncementAttachmentType.photo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: kIsWeb && attachment.bytes != null
            ? Image.memory(attachment.bytes!, height: 180, width: double.infinity, fit: BoxFit.cover)
            : Image.file(File(attachment.path), height: 180, width: double.infinity, fit: BoxFit.cover),
      );
    }
    final icon = type == AnnouncementAttachmentType.video ? PhosphorIconsFill.playCircle : PhosphorIconsFill.fileText;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppColors.primary, child: Icon(icon, color: Colors.white, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(attachment.name, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
