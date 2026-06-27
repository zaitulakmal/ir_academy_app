import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/models/activity.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/attachment_preview.dart';
import '../../../shared/widgets/create_activity_sheet.dart';

class ActivityDetailScreen extends StatelessWidget {
  final Activity activity;
  final List<Submission> submissions;

  const ActivityDetailScreen({super.key, required this.activity, required this.submissions});

  @override
  Widget build(BuildContext context) {
    final submittedCount = submissions.where((s) => s.submitted).length;

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
                  subtitle: s.submitted && s.textResponse != null
                      ? Text(s.textResponse!, maxLines: 1, overflow: TextOverflow.ellipsis)
                      : s.submitted && s.attachmentName != null
                          ? Text(s.attachmentName!, maxLines: 1, overflow: TextOverflow.ellipsis)
                          : null,
                  trailing: Icon(
                    s.submitted ? PhosphorIconsFill.checkCircle : PhosphorIconsRegular.clock,
                    color: s.submitted ? AppColors.success : AppColors.warning,
                  ),
                  onTap: s.submitted && s.attachmentPath != null
                      ? () => showModalBottomSheet(
                            context: context,
                            builder: (context) => Padding(
                              padding: const EdgeInsets.all(16),
                              child: AttachmentPreview(
                                responseType: activity.responseType,
                                path: s.attachmentPath!,
                                name: s.attachmentName ?? 'Submission',
                              ),
                            ),
                          )
                      : null,
                ),
              )),
        ],
      ),
    );
  }
}
