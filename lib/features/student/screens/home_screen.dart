import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/apr_entry_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/story_post_card.dart';
import '../../../shared/widgets/student_info_card.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final latestEntry = MockData.aprEntries.first;
    final latestPosts = MockData.storyPosts;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(PhosphorIconsFill.graduationCap, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('IR Academy'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.bell, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${MockData.studentName.split(' ').first}! 👋',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        MockData.studentForm,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Icon(PhosphorIconsFill.smiley, color: Colors.white, size: 48),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const StudentInfoCard(),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Latest Class Update'),
          ...latestPosts.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StoryPostCard(post: entry.value, colorIndex: entry.key),
              )),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Latest APR Entry'),
          AprEntryCard(entry: latestEntry),
        ],
      ),
    );
  }
}
