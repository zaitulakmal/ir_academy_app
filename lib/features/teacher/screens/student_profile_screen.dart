import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/activity.dart';
import '../../../core/models/learner.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/activity_card.dart';
import '../../../shared/widgets/apr_entry_card.dart';
import 'grade_submission_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  final Learner learner;

  const StudentProfileScreen({super.key, required this.learner});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);

  Learner get learner => widget.learner;

  List<Activity> get _activities => MockData.activities
      .where((a) => a.wholeClass || a.assignedLearners.contains(learner.name))
      .toList();

  Submission? _submissionFor(String activityId) => MockData.submissions
      .where((s) => s.activityId == activityId && s.learnerName == learner.name)
      .firstOrNull;

  @override
  Widget build(BuildContext context) {
    final entries = MockData.aprEntries.where((e) => e.learnerName == learner.name).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(learner.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'APR'),
            Tab(text: 'Homework'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildAprTab(entries),
          _buildHomeworkTab(),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return ListView(
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
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      child: Text(learner.name[0],
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 22)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(learner.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${learnerCategoryLabel(learner.category)} · ${learner.form}',
                              style: const TextStyle(color: AppColors.accentDark, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Student ID', learner.id),
                _detailRow('Parent / Guardian', learner.parentName),
                _detailRow('Parent Phone', learner.parentPhone),
                _detailRow('Attendance Rate', '${(learner.attendanceRate * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildAprTab(List entries) {
    if (entries.isEmpty) {
      return const Center(child: Text('No APR entries yet.', style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => AprEntryCard(entry: entries[index]),
    );
  }

  Widget _buildHomeworkTab() {
    final activities = _activities;
    if (activities.isEmpty) {
      return const Center(child: Text('No homework assigned yet.', style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final activity = activities[index];
        final submission = _submissionFor(activity.id);
        return ActivityCard(
          activity: activity,
          trailing: Icon(
            submission?.graded == true
                ? PhosphorIconsFill.sealCheck
                : submission?.submitted == true
                    ? PhosphorIconsFill.checkCircle
                    : PhosphorIconsRegular.clock,
            color: submission?.graded == true
                ? AppColors.primary
                : submission?.submitted == true
                    ? AppColors.success
                    : AppColors.warning,
          ),
          onTap: submission != null && submission.submitted
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GradeSubmissionScreen(
                        activity: activity,
                        submission: submission,
                        onGraded: (_) => setState(() {}),
                      ),
                    ),
                  )
              : null,
        );
      },
    );
  }
}
