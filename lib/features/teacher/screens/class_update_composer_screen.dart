import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/story_post.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/attachment_picker.dart';

class ClassUpdateComposerScreen extends StatefulWidget {
  final StoryPost? existingPost;
  final void Function(StoryPost post) onSave;
  final VoidCallback? onDelete;

  const ClassUpdateComposerScreen({super.key, this.existingPost, required this.onSave, this.onDelete});

  @override
  State<ClassUpdateComposerScreen> createState() => _ClassUpdateComposerScreenState();
}

class _ClassUpdateComposerScreenState extends State<ClassUpdateComposerScreen> {
  late final _bodyController = TextEditingController(text: widget.existingPost?.body ?? '');
  late PickedAttachment? _attachment = widget.existingPost?.attachmentPath != null || widget.existingPost?.attachmentUrl != null
      ? PickedAttachment(
          path: widget.existingPost!.attachmentPath ?? widget.existingPost!.attachmentUrl!,
          name: widget.existingPost!.attachmentName ?? '',
        )
      : null;
  late StoryAttachmentType _attachmentType = widget.existingPost?.attachmentType ?? StoryAttachmentType.none;
  late bool _wholeClass = widget.existingPost?.wholeClass ?? true;
  late final Set<String> _selectedLearners = {...(widget.existingPost?.assignedLearners ?? const [])};
  final _studentSearchController = TextEditingController();

  bool get _isEditing => widget.existingPost != null;
  bool get _canPost =>
      (_bodyController.text.trim().isNotEmpty || _attachment != null) && (_wholeClass || _selectedLearners.isNotEmpty);

  Future<void> _openStudentPicker() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final query = _studentSearchController.text.trim().toLowerCase();
          final filtered =
              query.isEmpty ? MockData.learners : MockData.learners.where((l) => l.name.toLowerCase().contains(query)).toList();
          return Dialog(
            child: SizedBox(
              height: 480,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text('Select Students', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                        IconButton(
                          icon: const Icon(PhosphorIconsBold.x),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _studentSearchController,
                      decoration: const InputDecoration(
                        hintText: 'Search student name...',
                        prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass),
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final l = filtered[index];
                        final selected = _selectedLearners.contains(l.name);
                        return CheckboxListTile(
                          value: selected,
                          title: Text(l.name),
                          subtitle: Text(l.form),
                          onChanged: (v) => setDialogState(
                            () => v == true ? _selectedLearners.add(l.name) : _selectedLearners.remove(l.name),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text('Done (${_selectedLearners.length} selected)'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    setState(() {});
  }

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
      _attachmentType = isVideo ? StoryAttachmentType.video : StoryAttachmentType.photo;
    });
  }

  Future<void> _pickFile() async {
    final picked = await pickWorksheet();
    if (picked == null) return;
    setState(() {
      _attachment = picked;
      _attachmentType = StoryAttachmentType.file;
    });
  }

  void _removeAttachment() => setState(() {
        _attachment = null;
        _attachmentType = StoryAttachmentType.none;
      });

  void _post() {
    if (!_canPost) return;
    widget.onSave(StoryPost(
      id: widget.existingPost?.id ?? 'sp${DateTime.now().microsecondsSinceEpoch}',
      teacherName: MockData.teacherName,
      classTag: MockData.classTag,
      date: widget.existingPost?.date ?? DateTime.now(),
      body: _bodyController.text.trim(),
      attachmentType: _attachmentType,
      attachmentPath: _attachmentType == StoryAttachmentType.photo || _attachmentType == StoryAttachmentType.video
          ? _attachment?.path
          : null,
      attachmentUrl: widget.existingPost?.attachmentUrl,
      attachmentName: _attachment?.name,
      attachmentSizeLabel: widget.existingPost?.attachmentSizeLabel,
      wholeClass: _wholeClass,
      assignedLearners: _wholeClass ? const [] : _selectedLearners.toList(),
      likeCount: widget.existingPost?.likeCount ?? 0,
      likedByMe: widget.existingPost?.likedByMe ?? false,
      comments: widget.existingPost?.comments,
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
        title: Text(_isEditing ? 'Edit Class Update' : 'New Class Update'),
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
          Row(
            children: [
              const Expanded(
                child: Text('Whole class', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Switch(
                value: _wholeClass,
                onChanged: (v) => setState(() => _wholeClass = v),
              ),
            ],
          ),
          if (!_wholeClass) ...[
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _openStudentPicker,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Students'),
                child: Text(
                  _selectedLearners.isEmpty ? 'Tap to select students' : '${_selectedLearners.length} student(s) selected',
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _bodyController,
            maxLines: 5,
            minLines: 3,
            decoration: const InputDecoration(
              hintText: 'Share an update with the class...',
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
              child: Text(_isEditing ? 'Update' : 'Post to Class'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  final StoryAttachmentType type;
  final PickedAttachment attachment;

  const _AttachmentPreview({required this.type, required this.attachment});

  @override
  Widget build(BuildContext context) {
    if (type == StoryAttachmentType.photo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(File(attachment.path), height: 180, width: double.infinity, fit: BoxFit.cover),
      );
    }
    final icon = type == StoryAttachmentType.video ? PhosphorIconsFill.playCircle : PhosphorIconsFill.fileText;
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
