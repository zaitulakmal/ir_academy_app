import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class _SubjectGrade {
  final String subject;
  final String grade;
  final double score;

  const _SubjectGrade(this.subject, this.grade, this.score);
}

class ReportCardScreen extends StatelessWidget {
  const ReportCardScreen({super.key});

  static const _grades = [
    _SubjectGrade('Mathematics', 'A', 0.88),
    _SubjectGrade('English', 'A+', 0.94),
    _SubjectGrade('Sains', 'B+', 0.78),
    _SubjectGrade('Sejarah', 'A', 0.85),
    _SubjectGrade('Bahasa Melayu', 'A', 0.86),
    _SubjectGrade('Pendidikan Islam', 'A+', 0.92),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Card')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _grades.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final g = _grades[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.subject, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: g.score,
                            minHeight: 8,
                            backgroundColor: AppColors.borderLight,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      g.grade,
                      style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
