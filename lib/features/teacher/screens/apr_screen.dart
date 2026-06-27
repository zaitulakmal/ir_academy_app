import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/activity.dart';
import '../../../core/models/apr_entry.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/activity_card.dart';
import '../../../shared/widgets/apr_entry_card.dart';
import '../../../shared/widgets/create_activity_sheet.dart';
import 'activity_detail_screen.dart';

class TeacherAprScreen extends StatefulWidget {
  const TeacherAprScreen({super.key});

  @override
  State<TeacherAprScreen> createState() => _TeacherAprScreenState();
}

class _TeacherAprScreenState extends State<TeacherAprScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);
  late final List<AprEntry> _entries = [...MockData.aprEntries];
  late final List<Activity> _activities = [...MockData.activities];
  late final List<Submission> _submissions = [...MockData.submissions];

  List<Submission> _submissionsFor(String activityId) =>
      _submissions.where((s) => s.activityId == activityId).toList();

  void _openLessonLogForm() {
    final subjectController = TextEditingController();
    final topicController = TextEditingController();
    final homeworkController = TextEditingController();
    final notesController = TextEditingController();
    final followUpController = TextEditingController();
    var progress = ProgressLevel.good;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New APR Entry', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 12),
                TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject')),
                const SizedBox(height: 8),
                TextField(controller: topicController, decoration: const InputDecoration(labelText: 'Topic Covered')),
                const SizedBox(height: 8),
                DropdownButtonFormField<ProgressLevel>(
                  initialValue: progress,
                  decoration: const InputDecoration(labelText: 'Progress / Understanding'),
                  items: ProgressLevel.values
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                      .toList(),
                  onChanged: (value) => setSheetState(() => progress = value ?? progress),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: homeworkController,
                  decoration: const InputDecoration(labelText: 'Homework Assigned'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Observations / Notes'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: followUpController,
                  decoration: const InputDecoration(labelText: 'Follow Up Action'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (subjectController.text.trim().isEmpty || topicController.text.trim().isEmpty) return;
                      setState(() {
                        _entries.insert(
                          0,
                          AprEntry(
                            date: DateTime.now(),
                            subject: subjectController.text.trim(),
                            topicCovered: topicController.text.trim(),
                            progress: progress,
                            homeworkAssigned: homeworkController.text.trim().isEmpty
                                ? 'No homework assigned'
                                : homeworkController.text.trim(),
                            homeworkDone: false,
                            observations: notesController.text.trim(),
                            followUpAction: followUpController.text.trim(),
                          ),
                        );
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save Entry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openCreateActivity() {
    showCreateActivitySheet(
      context: context,
      learnerNames: MockData.learners.map((l) => l.name).toList(),
      onCreate: (activity) {
        setState(() {
          _activities.insert(0, activity);
          final targets = activity.wholeClass
              ? MockData.learners.map((l) => l.name)
              : activity.assignedLearners;
          _submissions.addAll(targets.map((name) => Submission(activityId: activity.id, learnerName: name)));
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APR'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'Lesson Log'),
            Tab(text: 'Homework Activities'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _tabController.index == 0 ? _openLessonLogForm() : _openCreateActivity(),
        child: const Icon(PhosphorIconsBold.plus, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => AprEntryCard(entry: _entries[index]),
          ),
          ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _activities.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final activity = _activities[index];
              final subs = _submissionsFor(activity.id);
              final submittedCount = subs.where((s) => s.submitted).length;
              return ActivityCard(
                activity: activity,
                trailing: Text('$submittedCount/${subs.length}',
                    style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ActivityDetailScreen(activity: activity, submissions: subs)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
