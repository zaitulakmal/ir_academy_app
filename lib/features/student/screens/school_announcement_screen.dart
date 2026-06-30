import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/chat_models.dart';
import '../../../core/theme/app_colors.dart';

class StudentSchoolAnnouncementScreen extends StatelessWidget {
  const StudentSchoolAnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = MockData.announcements;

    return Scaffold(
      appBar: AppBar(title: const Text('School Announcement')),
      body: posts.isEmpty
          ? const Center(child: Text('No announcements yet.', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                              child: const Icon(PhosphorIconsFill.megaphone, color: AppColors.accent, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(post.author, style: const TextStyle(fontWeight: FontWeight.w700)),
                            ),
                            Text(post.timeLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(post.body),
                        if (post.attachmentType != AnnouncementAttachmentType.none) ...[
                          const SizedBox(height: 12),
                          _buildAttachment(post),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAttachment(AnnouncementPost post) {
    if (post.attachmentType == AnnouncementAttachmentType.photo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: kIsWeb && post.attachmentBytes != null
            ? Image.memory(post.attachmentBytes!, height: 180, width: double.infinity, fit: BoxFit.cover)
            : Image.file(File(post.attachmentPath!), height: 180, width: double.infinity, fit: BoxFit.cover),
      );
    }
    final icon =
        post.attachmentType == AnnouncementAttachmentType.video ? PhosphorIconsFill.playCircle : PhosphorIconsFill.fileText;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppColors.primary, child: Icon(icon, color: Colors.white, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(post.attachmentName ?? 'Attachment', overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
