import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/report_card.dart';
import '../../../core/theme/app_colors.dart';

class ReportCardScreen extends StatefulWidget {
  final String learnerName;

  const ReportCardScreen({super.key, String? learnerName}) : learnerName = learnerName ?? '';

  @override
  State<ReportCardScreen> createState() => _ReportCardScreenState();
}

class _ReportCardScreenState extends State<ReportCardScreen> {
  late int _termIndex = 0;

  List<ReportCard> get _reportCards =>
      widget.learnerName.isEmpty || widget.learnerName == MockData.studentName ? MockData.reportCards : const [];

  String _scoreGrade(double score) {
    if (score >= 0.9) return 'A+';
    if (score >= 0.8) return 'A';
    if (score >= 0.7) return 'B+';
    if (score >= 0.6) return 'B';
    return 'C';
  }

  Color _gradeColor(String grade) {
    if (grade.startsWith('A')) return AppColors.success;
    if (grade.startsWith('B')) return AppColors.primary;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final reportCards = _reportCards;

    return Scaffold(
      appBar: AppBar(title: const Text('Report Card')),
      body: reportCards.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No report card data available for this student yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          : _buildContent(reportCards),
    );
  }

  Widget _buildContent(List<ReportCard> reportCards) {
    final card = reportCards[_termIndex];
    final averageGrade = _scoreGrade(card.averageScore);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (reportCards.length > 1)
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: reportCards.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final selected = index == _termIndex;
                return ChoiceChip(
                  label: Text(reportCards[index].termName),
                  selected: selected,
                  onSelected: (_) => setState(() => _termIndex = index),
                  selectedColor: AppColors.primary.withValues(alpha: 0.16),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          )
        else
          Text(card.termName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Text(
                  averageGrade,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Average: ${(card.averageScore * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    if (card.classRank != null && card.classSize != null)
                      Text('Class Rank: ${card.classRank} of ${card.classSize}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('Attendance: ${(card.attendanceRate * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Subjects', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 10),
        ...card.subjects.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                    color: _gradeColor(g.grade),
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
                              color: _gradeColor(g.grade).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              g.grade,
                              style: TextStyle(color: _gradeColor(g.grade), fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      if (g.remarks != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(PhosphorIconsRegular.chatTeardropText, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(g.remarks!,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )),
        if (card.teacherRemarks != null) ...[
          const SizedBox(height: 10),
          const Text('Teacher\'s Remarks', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(PhosphorIconsFill.quotes, color: AppColors.accent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(card.teacherRemarks!)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
