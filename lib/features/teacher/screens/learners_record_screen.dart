import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';

class LearnersRecordScreen extends StatelessWidget {
  const LearnersRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learners Record')),
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
              subtitle: Text('${l.form} · Parent: ${l.parentName}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(PhosphorIconsFill.checkCircle,
                      color: l.attendanceRate >= 0.9 ? AppColors.success : AppColors.warning, size: 18),
                  Text('${(l.attendanceRate * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
