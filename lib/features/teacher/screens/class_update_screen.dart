import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/story_post.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/story_post_card.dart';
import 'class_update_composer_screen.dart';

class TeacherClassUpdateScreen extends StatefulWidget {
  const TeacherClassUpdateScreen({super.key});

  @override
  State<TeacherClassUpdateScreen> createState() => _TeacherClassUpdateScreenState();
}

class _TeacherClassUpdateScreenState extends State<TeacherClassUpdateScreen> {
  late final List<StoryPost> _posts = MockData.storyPosts;

  void _openComposer({StoryPost? post}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClassUpdateComposerScreen(
          existingPost: post,
          onSave: (saved) => setState(() {
            final index = post != null ? _posts.indexWhere((p) => p.id == post.id) : -1;
            if (index == -1) {
              _posts.insert(0, saved);
            } else {
              _posts[index] = saved;
            }
          }),
          onDelete: post != null ? () => setState(() => _posts.removeWhere((p) => p.id == post.id)) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Update')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _openComposer(),
        child: const Icon(PhosphorIconsBold.plus, color: Colors.white),
      ),
      body: _posts.isEmpty
          ? const Center(child: Text('No class updates yet.', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _posts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => StoryPostCard(
                post: _posts[index],
                colorIndex: index,
                onEdit: () => _openComposer(post: _posts[index]),
                onDelete: () => setState(() => _posts.removeAt(index)),
              ),
            ),
    );
  }
}
