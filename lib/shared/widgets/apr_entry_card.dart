import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/activity.dart';
import '../../core/models/apr_entry.dart';
import '../../core/theme/app_colors.dart';
import 'progress_badge.dart';

class AprEntryCard extends StatelessWidget {
  final AprEntry entry;
  final bool showHomeworkOnly;
  final bool showLearnerName;
  final Submission? linkedSubmission;
  final Activity? linkedActivity;
  final VoidCallback? onSubmitTap;
  final VoidCallback? onLinkedActivityTap;

  const AprEntryCard({
    super.key,
    required this.entry,
    this.showHomeworkOnly = false,
    this.showLearnerName = false,
    this.linkedSubmission,
    this.linkedActivity,
    this.onSubmitTap,
    this.onLinkedActivityTap,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final submission = linkedSubmission;
    final isDone = submission != null ? submission.submitted : entry.homeworkDone;
    final isGraded = submission?.graded ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showLearnerName) ...[
              Text(entry.learnerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 4),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.subject,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 15),
                ),
                Text(_formatDate(entry.date), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            if (!showHomeworkOnly) ...[
              Text(entry.topicCovered, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ProgressBadge(level: entry.progress),
              const SizedBox(height: 12),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isGraded
                      ? PhosphorIconsFill.sealCheck
                      : isDone
                          ? PhosphorIconsFill.checkCircle
                          : PhosphorIconsRegular.clock,
                  size: 18,
                  color: isGraded
                      ? AppColors.primary
                      : isDone
                          ? AppColors.success
                          : AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: linkedActivity != null
                      ? InkWell(
                          onTap: onLinkedActivityTap,
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Linked homework (Homework Activities tab)',
                                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    const SizedBox(height: 2),
                                    Text(linkedActivity!.title,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                              if (onLinkedActivityTap != null)
                                const Icon(PhosphorIconsBold.caretRight, size: 14, color: AppColors.textSecondary),
                            ],
                          ),
                        )
                      : Text(entry.homeworkAssigned, style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
            if (!showHomeworkOnly && entry.observations.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                entry.observations,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
              ),
            ],
            if (onSubmitTap != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onSubmitTap,
                  child: Text(isGraded ? 'Marked · View' : isDone ? 'View Submission' : 'Submit Homework'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
