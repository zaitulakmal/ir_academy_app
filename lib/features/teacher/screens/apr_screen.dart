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
import 'grade_submission_screen.dart';

class TeacherAprScreen extends StatefulWidget {
  final int initialTabIndex;

  const TeacherAprScreen({super.key, this.initialTabIndex = 0});

  @override
  State<TeacherAprScreen> createState() => _TeacherAprScreenState();
}

class _TeacherAprScreenState extends State<TeacherAprScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
  late final List<AprEntry> _entries = MockData.aprEntries;
  late final List<Activity> _activities = MockData.activities;
  late final List<Submission> _submissions = MockData.submissions;

  List<Submission> _submissionsFor(String activityId) =>
      _submissions.where((s) => s.activityId == activityId).toList();

  Submission? _submissionForEntry(AprEntry entry) {
    if (entry.activityId == null) return null;
    return _submissions
        .where((s) => s.activityId == entry.activityId && s.learnerName == entry.learnerName)
        .firstOrNull;
  }

  Activity? _activityById(String id) => _activities.where((a) => a.id == id).firstOrNull;

  void _openLessonLogForm({String? forLearner, AprEntry? existing}) {
    final subjectController = TextEditingController(text: existing?.subject ?? '');
    final topicController = TextEditingController(text: existing?.topicCovered ?? '');
    final homeworkController =
        TextEditingController(text: existing?.homeworkAssigned == 'No homework assigned' ? '' : existing?.homeworkAssigned ?? '');
    final notesController = TextEditingController(text: existing?.observations ?? '');
    final followUpController = TextEditingController(text: existing?.followUpAction ?? '');
    var progress = existing?.progress ?? ProgressLevel.good;
    var selectedLearner = existing?.learnerName ?? forLearner ?? MockData.learners.first.name;
    var wholeClass = false;
    final selectedLearners = <String>{};
    final studentSearchController = TextEditingController();
    var submittable = existing?.activityId != null;
    var responseType = existing?.activityId != null
        ? _activityById(existing!.activityId!)?.responseType ?? ResponseType.text
        : ResponseType.text;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(PhosphorIconsBold.arrowLeft),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(existing != null ? 'Edit APR Entry' : 'New APR Entry',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    if (existing != null)
                      IconButton(
                        icon: const Icon(PhosphorIconsRegular.trash, color: AppColors.danger),
                        onPressed: () {
                          setState(() {
                            _entries.remove(existing);
                            if (existing.activityId != null) {
                              _activities.removeWhere((a) => a.id == existing.activityId);
                              _submissions.removeWhere((s) => s.activityId == existing.activityId);
                            }
                          });
                          Navigator.of(context).pop();
                        },
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 4),
                if (forLearner != null)
                  Text('For: $forLearner', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary))
                else if (existing != null) ...[
                  DropdownButtonFormField<String>(
                    initialValue: selectedLearner,
                    decoration: const InputDecoration(labelText: 'Student'),
                    items: MockData.learners
                        .map((l) => DropdownMenuItem(value: l.name, child: Text(l.name, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (value) => setSheetState(() => selectedLearner = value ?? selectedLearner),
                  ),
                ] else ...[
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Whole class', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Switch(
                        value: wholeClass,
                        onChanged: (v) => setSheetState(() => wholeClass = v),
                      ),
                    ],
                  ),
                  if (!wholeClass) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        await showDialog<void>(
                          context: context,
                          builder: (dialogContext) => StatefulBuilder(
                            builder: (dialogContext, setDialogState) {
                              final query = studentSearchController.text.trim().toLowerCase();
                              final filtered = query.isEmpty
                                  ? MockData.learners
                                  : MockData.learners.where((l) => l.name.toLowerCase().contains(query)).toList();
                              return Dialog(
                                child: SizedBox(
                                  height: 480,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                        child: Row(
                                          children: [
                                            const Expanded(
                                              child: Text('Select Students', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                            ),
                                            IconButton(
                                              icon: const Icon(PhosphorIconsBold.x),
                                              onPressed: () => Navigator.of(dialogContext).pop(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: TextField(
                                          controller: studentSearchController,
                                          decoration: const InputDecoration(
                                            hintText: 'Search student name...',
                                            prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass),
                                          ),
                                          onChanged: (_) => setDialogState(() {}),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: filtered.length,
                                          itemBuilder: (context, index) {
                                            final l = filtered[index];
                                            final selected = selectedLearners.contains(l.name);
                                            return CheckboxListTile(
                                              value: selected,
                                              title: Text(l.name),
                                              subtitle: Text(l.form),
                                              onChanged: (v) => setDialogState(
                                                () => v == true ? selectedLearners.add(l.name) : selectedLearners.remove(l.name),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () => Navigator.of(dialogContext).pop(),
                                            child: Text('Done (${selectedLearners.length} selected)'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                        setSheetState(() {});
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Students'),
                        child: Text(
                          selectedLearners.isEmpty ? 'Tap to select students' : '${selectedLearners.length} student(s) selected',
                        ),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 8),
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
                Row(
                  children: [
                    const Expanded(
                      child: Text('Make this submittable', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Switch(
                      value: submittable,
                      onChanged: (v) => setSheetState(() => submittable = v),
                    ),
                  ],
                ),
                if (submittable) ...[
                  DropdownButtonFormField<ResponseType>(
                    initialValue: responseType,
                    decoration: const InputDecoration(labelText: 'Response Type'),
                    items: ResponseType.values
                        .map((r) => DropdownMenuItem(value: r, child: Text(responseTypeLabel(r))))
                        .toList(),
                    onChanged: (value) => setSheetState(() => responseType = value ?? responseType),
                  ),
                  const SizedBox(height: 8),
                ],
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
                      final targets = forLearner != null
                          ? [forLearner]
                          : existing != null
                              ? [selectedLearner]
                              : wholeClass
                                  ? MockData.learners.map((l) => l.name).toList()
                                  : selectedLearners.toList();
                      if (subjectController.text.trim().isEmpty ||
                          topicController.text.trim().isEmpty ||
                          targets.isEmpty) {
                        return;
                      }
                      final homeworkText =
                          homeworkController.text.trim().isEmpty ? 'No homework assigned' : homeworkController.text.trim();
                      final canLink = submittable && homeworkController.text.trim().isNotEmpty;
                      setState(() {
                        if (existing == null) {
                          String? sharedActivityId;
                          if (canLink) {
                            final activity = Activity(
                              id: 'hw${DateTime.now().microsecondsSinceEpoch}',
                              title: homeworkText,
                              instructions: homeworkText,
                              responseType: responseType,
                              wholeClass: wholeClass,
                              assignedLearners: wholeClass ? const [] : targets,
                              subject: subjectController.text.trim(),
                              createdAt: DateTime.now(),
                            );
                            _activities.insert(0, activity);
                            _submissions.addAll(targets.map((name) => Submission(activityId: activity.id, learnerName: name)));
                            sharedActivityId = activity.id;
                          }
                          for (final name in targets) {
                            _entries.insert(
                              0,
                              AprEntry(
                                learnerName: name,
                                date: DateTime.now(),
                                subject: subjectController.text.trim(),
                                topicCovered: topicController.text.trim(),
                                progress: progress,
                                homeworkAssigned: homeworkText,
                                homeworkDone: false,
                                observations: notesController.text.trim(),
                                followUpAction: followUpController.text.trim(),
                                activityId: sharedActivityId,
                              ),
                            );
                          }
                        } else {
                          var activityId = existing.activityId;
                          if (canLink && activityId == null) {
                            final activity = Activity(
                              id: 'hw${DateTime.now().microsecondsSinceEpoch}',
                              title: homeworkText,
                              instructions: homeworkText,
                              responseType: responseType,
                              wholeClass: false,
                              assignedLearners: [selectedLearner],
                              subject: subjectController.text.trim(),
                              createdAt: DateTime.now(),
                            );
                            _activities.insert(0, activity);
                            _submissions.add(Submission(activityId: activity.id, learnerName: selectedLearner));
                            activityId = activity.id;
                          } else if (!canLink && activityId != null) {
                            _activities.removeWhere((a) => a.id == activityId);
                            _submissions.removeWhere((s) => s.activityId == activityId);
                            activityId = null;
                          }
                          final updatedEntry = AprEntry(
                            learnerName: selectedLearner,
                            date: existing.date,
                            subject: subjectController.text.trim(),
                            topicCovered: topicController.text.trim(),
                            progress: progress,
                            homeworkAssigned: homeworkText,
                            homeworkDone: existing.homeworkDone,
                            observations: notesController.text.trim(),
                            followUpAction: followUpController.text.trim(),
                            activityId: activityId,
                          );
                          _entries[_entries.indexOf(existing)] = updatedEntry;
                        }
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(existing != null ? 'Update Entry' : 'Save Entry'),
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
            itemBuilder: (context, index) {
              final entry = _entries[index];
              final submission = _submissionForEntry(entry);
              final activity = entry.activityId != null ? _activityById(entry.activityId!) : null;
              return Stack(
                children: [
                  AprEntryCard(
                    entry: entry,
                    showLearnerName: true,
                    linkedSubmission: submission,
                    linkedActivity: activity,
                    onLinkedActivityTap: activity == null
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ActivityDetailScreen(
                                  activity: activity,
                                  submissions: _submissionsFor(activity.id),
                                  learnerNames: MockData.learners.map((l) => l.name).toList(),
                                  onUpdated: (updated) => setState(() {
                                    final i = _activities.indexWhere((a) => a.id == updated.id);
                                    if (i != -1) _activities[i] = updated;
                                  }),
                                  onDeleted: () => setState(() {
                                    _activities.removeWhere((a) => a.id == activity.id);
                                    _submissions.removeWhere((s) => s.activityId == activity.id);
                                  }),
                                ),
                              ),
                            ),
                    onSubmitTap: submission != null && submission.submitted
                        ? () {
                            final activity = _activityById(entry.activityId!);
                            if (activity == null) return;
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
                        : null,
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: PopupMenuButton<String>(
                      icon: const Icon(PhosphorIconsBold.dotsThreeVertical, size: 18, color: AppColors.textSecondary),
                      onSelected: (value) => value == 'edit'
                          ? _openLessonLogForm(existing: entry)
                          : setState(() {
                              _entries.remove(entry);
                              if (entry.activityId != null) {
                                _activities.removeWhere((a) => a.id == entry.activityId);
                                _submissions.removeWhere((s) => s.activityId == entry.activityId);
                              }
                            }),
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                ],
              );
            },
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
                  MaterialPageRoute(
                    builder: (_) => ActivityDetailScreen(
                      activity: activity,
                      submissions: subs,
                      learnerNames: MockData.learners.map((l) => l.name).toList(),
                      onUpdated: (updated) => setState(() {
                        final i = _activities.indexWhere((a) => a.id == updated.id);
                        if (i != -1) _activities[i] = updated;
                      }),
                      onDeleted: () => setState(() {
                        _activities.removeWhere((a) => a.id == activity.id);
                        _submissions.removeWhere((s) => s.activityId == activity.id);
                      }),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
