import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/section_header.dart';

class _StatTile {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile(this.icon, this.label, this.value, this.color);
}

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatTile(PhosphorIconsFill.usersThree, 'Learners', '${MockData.learners.length}', AppColors.primary),
      _StatTile(PhosphorIconsFill.clipboardText, "Today's Lessons", '3', AppColors.accent),
      _StatTile(PhosphorIconsFill.notebook, 'Pending Homework', '2', AppColors.warning),
      _StatTile(PhosphorIconsFill.chatCircleDots, 'Unread Messages', '2', AppColors.success),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: stats
                .map((s) => Card(
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
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Recent Learners'),
          ...MockData.learners.take(3).map((l) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Text(l.name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                  title: Text(l.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(l.form),
                ),
              )),
        ],
      ),
    );
  }
}
