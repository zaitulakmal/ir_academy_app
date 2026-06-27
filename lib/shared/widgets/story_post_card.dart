import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/story_post.dart';
import '../../core/theme/app_colors.dart';
import 'expandable_text.dart';
import 'story_post_detail_screen.dart';

const _avatarColors = [AppColors.primary, AppColors.accent, AppColors.success];

String _formatStoryDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${date.day} ${months[date.month - 1]}';
}

Future<void> _openLink(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class StoryPostCard extends StatefulWidget {
  final StoryPost post;
  final int colorIndex;

  const StoryPostCard({super.key, required this.post, this.colorIndex = 0});

  @override
  State<StoryPostCard> createState() => _StoryPostCardState();
}

class _StoryPostCardState extends State<StoryPostCard> {
  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final color = _avatarColors[widget.colorIndex % _avatarColors.length];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Text(
                    post.teacherName.replaceAll('Ms. ', '').trim().split(' ').map((w) => w[0]).take(2).join(),
                    style: TextStyle(color: color, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.teacherName, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        '${post.classTag} · ${_formatStoryDate(post.date)}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ExpandableText(text: post.body),
            if (post.attachmentType == StoryAttachmentType.link) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _openLink(post.attachmentUrl!),
                child: Text(
                  post.attachmentUrl!,
                  style: const TextStyle(color: AppColors.primary, decoration: TextDecoration.underline),
                ),
              ),
            ] else if (post.attachmentType == StoryAttachmentType.file) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(PhosphorIconsFill.fileText, color: AppColors.danger),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.attachmentName ?? 'Attachment',
                              style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                          if (post.attachmentSizeLabel != null)
                            Text(post.attachmentSizeLabel!,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                InkWell(
                  onTap: () => setState(() {
                    post.likedByMe = !post.likedByMe;
                    post.likeCount += post.likedByMe ? 1 : -1;
                  }),
                  child: Row(
                    children: [
                      Icon(
                        post.likedByMe ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
                        size: 18,
                        color: post.likedByMe ? AppColors.accent : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text('${post.likeCount} likes', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () => Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => StoryPostDetailScreen(post: post, colorIndex: widget.colorIndex),
                        ),
                      )
                      .then((_) => setState(() {})),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsRegular.chatCircle, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text('${post.comments.length} comments',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
