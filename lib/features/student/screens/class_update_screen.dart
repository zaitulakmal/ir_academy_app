import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/story_post.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/story_post_card.dart';

class ClassUpdateScreen extends StatefulWidget {
  const ClassUpdateScreen({super.key});

  @override
  State<ClassUpdateScreen> createState() => _ClassUpdateScreenState();
}

class _ClassUpdateScreenState extends State<ClassUpdateScreen> {
  late final List<StoryPost> _posts = [...MockData.storyPosts];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Update')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(PhosphorIconsRegular.info, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Work submitted by you will also appear here.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            );
          }

          return StoryPostCard(post: _posts[index - 1], colorIndex: index);
        },
      ),
    );
  }
}
