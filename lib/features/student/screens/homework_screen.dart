import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/activity.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/activity_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/submit_activity_sheet.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  late final List<Activity> _myActivities = MockData.activities
      .where((a) => a.wholeClass || a.assignedLearners.contains(MockData.studentName))
      .toList();
  late final List<Submission> _submissions = [...MockData.submissions];

  Submission _submissionFor(String activityId) => _submissions.firstWhere(
        (s) => s.activityId == activityId && s.learnerName == MockData.studentName,
      );

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
          ...pending.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ActivityCard(
                  activity: a,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openActivity(a),
                ),
              )),
          const SizedBox(height: 12),
          SectionHeader(title: 'Completed (${done.length})'),
          ...done.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ActivityCard(
                  activity: a,
                  trailing: const Icon(PhosphorIconsFill.checkCircle, color: AppColors.success),
                  onTap: () => _openActivity(a),
                ),
              )),
        ],
      ),
    );
  }

  void _openActivity(Activity activity) {
    showSubmitActivitySheet(
      context: context,
      activity: activity,
      submission: _submissionFor(activity.id),
      onSubmitted: (_) => setState(() {}),
    );
  }
}
