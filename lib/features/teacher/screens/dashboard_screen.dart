import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/learner.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/notifications_screen.dart';
import '../../../shared/widgets/section_header.dart';
import 'apr_screen.dart';
import 'class_chat_screen.dart';
import 'learners_record_screen.dart';
import 'student_profile_screen.dart';

class _StatTile {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatTile(this.icon, this.label, this.value, this.color, this.onTap);
}

class _CategoryStat {
  final LearnerCategory category;
  final IconData icon;
  final List<Color> gradient;

  const _CategoryStat(this.category, this.icon, this.gradient);
}

const _categoryStats = [
  _CategoryStat(LearnerCategory.kssr, PhosphorIconsFill.bookOpenText, [Color(0xFF7C3AED), Color(0xFF6366F1)]),
  _CategoryStat(LearnerCategory.kssm, PhosphorIconsFill.bookmarkSimple, [Color(0xFF2F80ED), Color(0xFF56CCF2)]),
  _CategoryStat(LearnerCategory.cambridgePrimary, PhosphorIconsFill.notebook, [Color(0xFF11998E), Color(0xFF38EF7D)]),
  _CategoryStat(LearnerCategory.cambridgeSecondary, PhosphorIconsFill.globe, [Color(0xFFF2994A), Color(0xFFF2C94C)]),
];

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatTile(
        PhosphorIconsFill.usersThree,
        'Learners',
        '${MockData.learners.length}',
        AppColors.primary,
        () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LearnersRecordScreen())),
      ),
      _StatTile(
        PhosphorIconsFill.clipboardText,
        "Today's Lessons",
        '3',
        AppColors.accent,
        () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeacherAprScreen(initialTabIndex: 0))),
      ),
      _StatTile(
        PhosphorIconsFill.notebook,
        'Pending Homework',
        '2',
        AppColors.warning,
        () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeacherAprScreen(initialTabIndex: 1))),
      ),
      _StatTile(
        PhosphorIconsFill.chatCircleDots,
        'Unread Messages',
        '2',
        AppColors.success,
        () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeacherClassChatScreen())),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          NotificationBellButton(notifications: MockData.teacherNotifications),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(title: 'Learners by Syllabus'),
          SizedBox(
            height: 152,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categoryStats.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final stat = _categoryStats[index];
                final count = MockData.learners.where((l) => l.category == stat.category).length;
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LearnersRecordScreen(initialCategory: stat.category)),
                  ),
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: stat.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(stat.icon, color: Colors.white, size: 18),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(PhosphorIconsBold.caretRight, color: Colors.white, size: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text('$count', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(learnerCategoryLabel(stat.category),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: stats
                .map((s) => Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: s.onTap,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(s.icon, color: s.color, size: 24),
                              const Spacer(),
                              Text(s.value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                              Text(s.label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Recent Learners'),
          ...MockData.learners.take(3).map((l) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StudentProfileScreen(learner: l)),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Text(l.name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                  title: Text(l.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(l.form),
                  trailing: const Icon(Icons.chevron_right),
                ),
              )),
        ],
      ),
    );
  }
}
