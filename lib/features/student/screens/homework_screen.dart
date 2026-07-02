import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/activity.dart';
import '../../../core/models/apr_entry.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/activity_card.dart';
import '../../../shared/widgets/apr_entry_card.dart';
import '../../../shared/widgets/section_header.dart';
import 'activity_detail_screen.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  List<Activity> get _myActivities => MockData.activities
      .where((a) => a.wholeClass || a.assignedLearners.contains(MockData.studentName))
      .toList();
  List<Submission> get _submissions => MockData.submissions;

  Submission _submissionFor(String activityId) => _submissions.firstWhere(
        (s) => s.activityId == activityId && s.learnerName == MockData.studentName,
      );

  AprEntry? _linkedEntryFor(String activityId) => MockData.aprEntries
      .where((e) => e.activityId == activityId && e.learnerName == MockData.studentName)
      .firstOrNull;

  @override
  Widget build(BuildContext context) {
    final pending = _myActivities.where((a) => !_submissionFor(a.id).submitted).toList();
    final done = _myActivities.where((a) => _submissionFor(a.id).submitted).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Homework')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(title: 'Pending (${pending.length})'),
          if (pending.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Nothing pending. Great job!', style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            ...pending.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCard(a),
                )),
          const SizedBox(height: 16),
          SectionHeader(title: 'Completed (${done.length})'),
          if (done.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No homework completed yet.', style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            ...done.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCard(a),
                )),
        ],
      ),
    );
  }

  Widget _buildCard(Activity activity) {
    final submission = _submissionFor(activity.id);
    final linkedEntry = _linkedEntryFor(activity.id);

    if (linkedEntry != null) {
      return AprEntryCard(
        entry: linkedEntry,
        linkedSubmission: submission,
        linkedActivity: activity,
        onLinkedActivityTap: () => _openActivity(activity),
        onSubmitTap: () => _openActivity(activity),
      );
    }

    return ActivityCard(
      activity: activity,
      trailing: Icon(
        submission.graded
            ? PhosphorIconsFill.sealCheck
            : submission.submitted
                ? PhosphorIconsFill.checkCircle
                : Icons.chevron_right,
        color: submission.graded
            ? AppColors.primary
            : submission.submitted
                ? AppColors.success
                : null,
      ),
      onTap: () => _openActivity(activity),
    );
  }

  void _openActivity(Activity activity) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StudentActivityDetailScreen(
          activity: activity,
          submission: _submissionFor(activity.id),
          onSubmitted: (_) => setState(() {}),
        ),
      ),
    );
  }
}
