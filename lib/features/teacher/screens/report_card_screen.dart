import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../student/screens/report_card_screen.dart';

class TeacherReportCardScreen extends StatelessWidget {
  const TeacherReportCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Card')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.learners.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final l = MockData.learners[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(l.name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
              title: Text(l.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(l.form),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReportCardScreen()),
              ),
            ),
          );
        },
      ),
    );
  }
}
