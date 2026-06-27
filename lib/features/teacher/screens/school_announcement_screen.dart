import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/chat_models.dart';
import '../../../core/theme/app_colors.dart';

class SchoolAnnouncementScreen extends StatefulWidget {
  const SchoolAnnouncementScreen({super.key});

  @override
  State<SchoolAnnouncementScreen> createState() => _SchoolAnnouncementScreenState();
}

class _SchoolAnnouncementScreenState extends State<SchoolAnnouncementScreen> {
  late final List<AnnouncementPost> _posts = [...MockData.announcements];
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  void _showComposer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Announcement', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: _bodyController, maxLines: 3, decoration: const InputDecoration(labelText: 'Message')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.trim().isEmpty) return;
                  setState(() {
                    _posts.insert(
                      0,
                      AnnouncementPost(
                        title: _titleController.text.trim(),
                        body: _bodyController.text.trim(),
                        author: 'You',
                        timeLabel: 'Just now',
                      ),
                    );
                  });
                  _titleController.clear();
                  _bodyController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('School Announcement')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: _showComposer,
        child: const Icon(PhosphorIconsBold.plus, color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final post = _posts[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(post.author, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      Text(post.timeLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(post.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(post.body),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
