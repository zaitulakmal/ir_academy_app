import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/apr_entry.dart';
import '../../core/theme/app_colors.dart';
import 'progress_badge.dart';

class AprEntryCard extends StatelessWidget {
  final AprEntry entry;
  final bool showHomeworkOnly;

  const AprEntryCard({super.key, required this.entry, this.showHomeworkOnly = false});

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  entry.homeworkDone ? PhosphorIconsFill.checkCircle : PhosphorIconsRegular.clock,
                  size: 18,
                  color: entry.homeworkDone ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(entry.homeworkAssigned, style: const TextStyle(fontSize: 13)),
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
          ],
        ),
      ),
    );
  }
}
