import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/models/activity.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/attachment_preview.dart';
import '../../../shared/widgets/drawing_canvas_screen.dart';

class GradeSubmissionScreen extends StatefulWidget {
  final Activity activity;
  final Submission submission;
  final void Function(Submission updated) onGraded;

  const GradeSubmissionScreen({
    super.key,
    required this.activity,
    required this.submission,
    required this.onGraded,
  });

  @override
  State<GradeSubmissionScreen> createState() => _GradeSubmissionScreenState();
}

class _GradeSubmissionScreenState extends State<GradeSubmissionScreen> {
  late final TextEditingController _gradeController = TextEditingController(text: widget.submission.grade ?? '');
  late final TextEditingController _feedbackController = TextEditingController(text: widget.submission.feedback ?? '');
  late final List<String?> _markupPaths =
      widget.submission.attachments.map((a) => a.markupPath).toList();
  late final List<Uint8List?> _markupBytes =
      widget.submission.attachments.map((a) => a.markupBytes).toList();

  bool get _canMarkup =>
      widget.activity.responseType == ResponseType.photo || widget.activity.responseType == ResponseType.drawing;

  Future<void> _openMarkup(int index) async {
    final attachment = widget.submission.attachments[index];
    final result = await Navigator.of(context).push<DrawingResult>(
      MaterialPageRoute(
        builder: (_) => DrawingCanvasScreen(
          title: 'Conteng Submission',
          backgroundImagePath: _markupPaths[index] ?? attachment.path,
          backgroundImageBytes: _markupBytes[index] ?? attachment.bytes,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _markupPaths[index] = result.path;
        _markupBytes[index] = result.bytes;
      });
    }
  }

  void _save() {
    final submission = widget.submission;
    submission.graded = true;
    submission.gradedAt = DateTime.now();
    submission.grade = _gradeController.text.trim().isEmpty ? null : _gradeController.text.trim();
    submission.feedback = _feedbackController.text.trim().isEmpty ? null : _feedbackController.text.trim();
    for (var i = 0; i < submission.attachments.length; i++) {
      submission.attachments[i].markupPath = _markupPaths[i];
      submission.attachments[i].markupBytes = _markupBytes[i];
    }
    widget.onGraded(submission);
    Navigator.of(context).pop();
  }

  void _clearMark() {
    final submission = widget.submission;
    submission.graded = false;
    submission.gradedAt = null;
    submission.grade = null;
    submission.feedback = null;
    for (final attachment in submission.attachments) {
      attachment.markupPath = null;
      attachment.markupBytes = null;
    }
    widget.onGraded(submission);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final submission = widget.submission;
    return Scaffold(
      appBar: AppBar(
        title: Text('Mark · ${submission.learnerName}'),
        actions: [
          if (submission.graded)
            TextButton(
              onPressed: _clearMark,
              child: const Text('Clear mark', style: TextStyle(color: AppColors.danger)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Submission', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (submission.textResponse != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(12)),
              child: Text(submission.textResponse!),
            )
          else
            ...submission.attachments.asMap().entries.map((entry) {
              final index = entry.key;
              final attachment = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AttachmentPreview(
                      responseType: widget.activity.responseType,
                      path: _markupPaths[index] ?? attachment.path,
                      name: attachment.name,
                      bytes: _markupBytes[index] ?? attachment.bytes,
                    ),
                    if (_canMarkup) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _openMarkup(index),
                        icon: const Icon(PhosphorIconsBold.pencilSimpleLine),
                        label: Text(_markupPaths[index] != null ? 'Edit markup' : 'Conteng / Markup'),
                      ),
                    ],
                  ],
                ),
              );
            }),
          const SizedBox(height: 16),
          const Text('Grade', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _gradeController,
            decoration: const InputDecoration(hintText: 'e.g. 8/10 or A'),
          ),
          const SizedBox(height: 16),
          const Text('Feedback', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _feedbackController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Write feedback for the student...'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(PhosphorIconsFill.checkCircle),
              label: const Text('Save Mark'),
            ),
          ),
        ],
      ),
    );
  }
}
