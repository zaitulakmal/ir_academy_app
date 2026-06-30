import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/learner.dart';
import '../../../core/theme/app_colors.dart';
import 'student_profile_screen.dart';

class LearnersRecordScreen extends StatefulWidget {
  final LearnerCategory? initialCategory;

  const LearnersRecordScreen({super.key, this.initialCategory});

  @override
  State<LearnersRecordScreen> createState() => _LearnersRecordScreenState();
}

class _LearnersRecordScreenState extends State<LearnersRecordScreen> {
  late LearnerCategory? _selectedCategory = widget.initialCategory;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = MockData.learners.where((l) {
      final matchesCategory = _selectedCategory == null || l.category == _selectedCategory;
      final matchesQuery = _query.isEmpty || l.name.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Learners Record')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search student name...',
                prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass),
                filled: true,
                fillColor: AppColors.borderLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _categoryChip(null, 'All (${MockData.learners.length})'),
                for (final category in LearnerCategory.values)
                  _categoryChip(
                    category,
                    '${learnerCategoryLabel(category)} (${MockData.learners.where((l) => l.category == category).length})',
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No students found.', style: TextStyle(color: AppColors.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final l = filtered[index];
                      return Card(
                        child: ListTile(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => StudentProfileScreen(learner: l)),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                            child:
                                Text(l.name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ),
                          title: Text(l.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('${learnerCategoryLabel(l.category)} · ${l.form}'),
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
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(LearnerCategory? category, String label) {
    final selected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _selectedCategory = category),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w600),
      ),
    );
  }
}
