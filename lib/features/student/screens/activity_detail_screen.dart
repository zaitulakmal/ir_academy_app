import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/models/activity.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/attachment_picker.dart';
import '../../../shared/widgets/attachment_preview.dart';
import '../../../shared/widgets/create_activity_sheet.dart';

class StudentActivityDetailScreen extends StatefulWidget {
  final Activity activity;
  final Submission submission;
  final void Function(Submission updated) onSubmitted;

  const StudentActivityDetailScreen({
    super.key,
    required this.activity,
    required this.submission,
    required this.onSubmitted,
  });

  @override
  State<StudentActivityDetailScreen> createState() => _StudentActivityDetailScreenState();
}

class _StudentActivityDetailScreenState extends State<StudentActivityDetailScreen> {
  late final TextEditingController _textController =
      TextEditingController(text: widget.submission.textResponse ?? '');
  late final List<PickedAttachment> _attachments = widget.submission.attachments
      .map((a) => PickedAttachment(path: a.path, name: a.name, bytes: a.bytes))
      .toList();
  bool _isSubmitting = false;

  Future<void> _addAttachment() async {
    List<PickedAttachment> picked = [];
    switch (widget.activity.responseType) {
      case ResponseType.video:
        final v = await pickVideo(context);
        if (v != null) picked = [v];
      case ResponseType.photo:
        picked = await pickPhotos(context);
      case ResponseType.drawing:
        final d = await pickDrawing(context);
        if (d != null) picked = [d];
      case ResponseType.worksheet:
        picked = await pickWorksheets();
      case ResponseType.text:
        return;
    }
    if (picked.isNotEmpty) setState(() => _attachments.addAll(picked));
  }

  void _removeAttachment(int index) => setState(() => _attachments.removeAt(index));

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final activity = widget.activity;
    final submission = widget.submission;
    submission.submitted = true;
    submission.submittedAt = DateTime.now();

    if (activity.responseType == ResponseType.text) {
      submission.textResponse = _textController.text.trim();
    } else {
      final uploaded = <SubmissionAttachment>[];
      for (final a in _attachments) {
        Uint8List? bytes = a.bytes;
        if (bytes == null && !kIsWeb && a.path.isNotEmpty) {
          try {
            bytes = await File(a.path).readAsBytes();
          } catch (_) {}
        }
        String path = a.path;
        if (bytes != null) {
          final ts = DateTime.now().microsecondsSinceEpoch;
          final url = await SupabaseService.uploadAttachment(
            storagePath: 'submissions/${submission.activityId}_${submission.learnerName}_${ts}_${a.name}',
            bytes: bytes,
          );
          if (url != null) path = url;
        }
        uploaded.add(SubmissionAttachment(path: path, name: a.name, bytes: a.bytes));
      }
      submission.attachments = uploaded;
    }

    widget.onSubmitted(submission);
    FirebaseService.upsertSubmission(submission);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final submission = widget.submission;
    final alreadySubmitted = submission.submitted;
    final canSubmit =
        activity.responseType == ResponseType.text ? _textController.text.trim().isNotEmpty : _attachments.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(activity.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(responseTypeIcon(activity.responseType), color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(responseTypeLabel(activity.responseType), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Instructions', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(activity.instructions.isEmpty ? 'No instructions provided.' : activity.instructions),
                  if (activity.attachmentPath != null) ...[
                    const SizedBox(height: 12),
                    AttachmentPreview(
                      responseType: _responseTypeFromFile(activity.attachmentName ?? activity.attachmentPath!),
                      path: activity.attachmentPath!,
                      name: activity.attachmentName ?? 'Attachment',
                      bytes: activity.attachmentBytes,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Your response', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          if (alreadySubmitted) ...[
            if (submission.textResponse != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(PhosphorIconsFill.checkCircle, color: AppColors.success),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(submission.textResponse!,
                          style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              )
            else
              ...submission.attachments.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AttachmentPreview(
                      responseType: activity.responseType,
                      path: a.markupPath ?? a.path,
                      name: a.name,
                      bytes: a.markupBytes ?? a.bytes,
                    ),
                  )),
          ] else if (activity.responseType == ResponseType.text) ...[
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Write your answer here...'),
              onChanged: (_) => setState(() {}),
            ),
          ] else ...[
            ..._attachments.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Stack(
                    children: [
                      AttachmentPreview(
                        responseType: activity.responseType,
                        path: entry.value.path,
                        name: entry.value.name,
                        bytes: entry.value.bytes,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeAttachment(entry.key),
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black54,
                            child: Icon(PhosphorIconsBold.x, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            OutlinedButton.icon(
              onPressed: _addAttachment,
              icon: Icon(_attachments.isNotEmpty ? PhosphorIconsBold.plus : responseTypeIcon(activity.responseType)),
              label: Text(_attachments.isNotEmpty ? 'Add another' : _attachLabel(activity.responseType)),
            ),
          ],
          if (submission.graded) ...[
            const SizedBox(height: 24),
            Row(
              children: const [
                Icon(PhosphorIconsFill.sealCheck, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Teacher\'s Mark', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (submission.grade != null)
                    Text('Grade: ${submission.grade}',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  if (submission.feedback != null) ...[
                    if (submission.grade != null) const SizedBox(height: 6),
                    Text(submission.feedback!),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (!alreadySubmitted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSubmit && !_isSubmitting ? _submit : null,
                child: _isSubmitting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit'),
              ),
            ),
        ],
      ),
    );
  }
}

ResponseType _responseTypeFromFile(String nameOrPath) {
  final ext = nameOrPath.split('.').last.split('?').first.toLowerCase();
  if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) return ResponseType.photo;
  if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) return ResponseType.video;
  return ResponseType.worksheet;
}

String _attachLabel(ResponseType type) {
  switch (type) {
    case ResponseType.video:
      return 'Record Video';
    case ResponseType.photo:
      return 'Take Photo';
    case ResponseType.drawing:
      return 'Open Drawing Canvas';
    case ResponseType.worksheet:
      return 'Upload Worksheet';
    case ResponseType.text:
      return '';
  }
}
