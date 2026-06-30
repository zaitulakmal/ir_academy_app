import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/models/activity.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/attachment_preview.dart';
import '../../../shared/widgets/create_activity_sheet.dart';
import 'grade_submission_screen.dart';

class ActivityDetailScreen extends StatefulWidget {
  final Activity activity;
  final List<Submission> submissions;
  final List<String> learnerNames;
  final void Function(Activity updated)? onUpdated;
  final VoidCallback? onDeleted;

  const ActivityDetailScreen({
    super.key,
    required this.activity,
    required this.submissions,
    this.learnerNames = const [],
    this.onUpdated,
    this.onDeleted,
  });

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  Activity get activity => widget.activity;
  List<Submission> get submissions => widget.submissions;

  Future<void> _openEdit() async {
    var deleted = false;
    await showCreateActivitySheet(
      context: context,
      learnerNames: widget.learnerNames,
      existingActivity: activity,
      onCreate: (updated) => widget.onUpdated?.call(updated),
      onDelete: () {
        deleted = true;
        widget.onDeleted?.call();
      },
    );
    if (deleted && mounted) Navigator.of(context).pop();
  }

  void _openGrading(Submission submission) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GradeSubmissionScreen(
          activity: activity,
          submission: submission,
          onGraded: (_) => setState(() {}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submittedCount = submissions.where((s) => s.submitted).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.title),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.pencilSimple),
            onPressed: _openEdit,
          ),
        ],
      ),
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
                      const Spacer(),
                      Text('$submittedCount/${submissions.length} submitted',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(activity.instructions),
                  if (activity.attachmentPath != null) ...[
                    const SizedBox(height: 12),
                    AttachmentPreview(
                      responseType: ResponseType.worksheet,
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
          const Text('Submissions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          ...submissions.map((s) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Text(s.learnerName[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                  title: Text(s.learnerName),
                  subtitle: s.graded
                      ? Text(
                          s.grade != null ? 'Marked · ${s.grade}' : 'Marked',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                        )
                      : s.submitted && s.textResponse != null
                          ? Text(s.textResponse!, maxLines: 1, overflow: TextOverflow.ellipsis)
                          : s.submitted && s.attachments.isNotEmpty
                              ? Text(
                                  s.attachments.length == 1 ? s.attachments.first.name : '${s.attachments.length} files',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                  trailing: Icon(
                    s.graded
                        ? PhosphorIconsFill.sealCheck
                        : s.submitted
                            ? PhosphorIconsFill.checkCircle
                            : PhosphorIconsRegular.clock,
                    color: s.graded
                        ? AppColors.primary
                        : s.submitted
                            ? AppColors.success
                            : AppColors.warning,
                  ),
                  onTap: s.submitted ? () => _openGrading(s) : null,
                ),
              )),
        ],
      ),
    );
  }
}
