import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/chat_models.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/theme/app_colors.dart';
import 'announcement_composer_screen.dart';

class SchoolAnnouncementScreen extends StatefulWidget {
  const SchoolAnnouncementScreen({super.key});

  @override
  State<SchoolAnnouncementScreen> createState() => _SchoolAnnouncementScreenState();
}

class _SchoolAnnouncementScreenState extends State<SchoolAnnouncementScreen> {
  late final List<AnnouncementPost> _posts = MockData.announcements;

  void _openComposer({AnnouncementPost? post}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnnouncementComposerScreen(
          existingPost: post,
          onPost: (saved) {
            setState(() {
              final index = post != null ? _posts.indexWhere((p) => p.id == post.id) : -1;
              if (index == -1) {
                _posts.insert(0, saved);
              } else {
                _posts[index] = saved;
              }
            });
            FirebaseService.saveAnnouncement(saved);
          },
          onDelete: post != null
              ? () {
                  setState(() => _posts.removeWhere((p) => p.id == post.id));
                  if (post.id != null) FirebaseService.deleteAnnouncement(post.id!);
                }
              : null,
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
        onPressed: _openComposer,
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
                      PopupMenuButton<String>(
                        icon: const Icon(PhosphorIconsBold.dotsThreeVertical, size: 18, color: AppColors.textSecondary),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openComposer(post: post);
                          } else {
                            setState(() => _posts.remove(post));
                            if (post.id != null) FirebaseService.deleteAnnouncement(post.id!);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
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
            : post.attachmentPath != null && post.attachmentPath!.startsWith('http')
                ? Image.network(post.attachmentPath!, height: 180, width: double.infinity, fit: BoxFit.cover)
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
