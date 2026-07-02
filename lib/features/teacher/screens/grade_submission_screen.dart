import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/models/activity.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/supabase_service.dart';
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
  bool _isSaving = false;

  static const _imageExts = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic'};

  bool _isImageAttachment(SubmissionAttachment a) {
    final ext = a.name.split('.').last.split('?').first.toLowerCase();
    return _imageExts.contains(ext);
  }

  /// Markup works on any image attachment — photo/drawing activities always
  /// qualify, and worksheet submissions qualify per-file when they're images.
  bool _canMarkupAttachment(SubmissionAttachment a) =>
      widget.activity.responseType == ResponseType.photo ||
      widget.activity.responseType == ResponseType.drawing ||
      _isImageAttachment(a);

  Future<void> _openMarkup(int index) async {
    final attachment = widget.submission.attachments[index];
    final path = _markupPaths[index] ?? attachment.path;
    Uint8List? bytes = _markupBytes[index] ?? attachment.bytes;

    // On web (and for remote files generally) the attachment is an http URL —
    // fetch the bytes so the drawing canvas can show it as the background.
    if (bytes == null && path.startsWith('http')) {
      try {
        final response = await http.get(Uri.parse(path));
        if (response.statusCode == 200) bytes = response.bodyBytes;
      } catch (_) {}
      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load image for markup. Please try again.')),
          );
        }
        return;
      }
    }

    if (!mounted) return;
    final result = await Navigator.of(context).push<DrawingResult>(
      MaterialPageRoute(
        builder: (_) => DrawingCanvasScreen(
          title: 'Annotate Submission',
          backgroundImagePath: bytes == null ? path : null,
          backgroundImageBytes: bytes,
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

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final submission = widget.submission;
    submission.graded = true;
    submission.gradedAt = DateTime.now();
    submission.grade = _gradeController.text.trim().isEmpty ? null : _gradeController.text.trim();
    submission.feedback = _feedbackController.text.trim().isEmpty ? null : _feedbackController.text.trim();

    for (var i = 0; i < submission.attachments.length; i++) {
      final bytes = _markupBytes[i];
      if (bytes != null) {
        final ts = DateTime.now().microsecondsSinceEpoch;
        final url = await SupabaseService.uploadAttachment(
          storagePath: 'markup/${submission.activityId}_${submission.learnerName}_${ts}_markup.png',
          bytes: bytes,
        );
        submission.attachments[i].markupPath = url ?? _markupPaths[i];
        submission.attachments[i].markupBytes = bytes;
      } else {
        submission.attachments[i].markupPath = _markupPaths[i];
        submission.attachments[i].markupBytes = null;
      }
    }

    widget.onGraded(submission);
    FirebaseService.upsertSubmission(submission);
    if (mounted) Navigator.of(context).pop();
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
                      responseType: _canMarkupAttachment(attachment)
                          ? ResponseType.photo
                          : widget.activity.responseType,
                      path: _markupPaths[index] ?? attachment.path,
                      name: attachment.name,
                      bytes: _markupBytes[index] ?? attachment.bytes,
                    ),
                    if (_canMarkupAttachment(attachment)) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _openMarkup(index),
                        icon: const Icon(PhosphorIconsBold.pencilSimpleLine),
                        label: Text(_markupPaths[index] != null || _markupBytes[index] != null
                            ? 'Edit markup'
                            : 'Annotate / Markup'),
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
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(PhosphorIconsFill.checkCircle),
              label: const Text('Save Mark'),
            ),
          ),
        ],
      ),
    );
  }
}
