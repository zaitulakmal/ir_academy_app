import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/story_post.dart';
import '../../core/theme/app_colors.dart';

const _avatarColors = [AppColors.primary, AppColors.accent, AppColors.success];

String _formatDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${date.day} ${months[date.month - 1]}';
}

class StoryPostDetailScreen extends StatefulWidget {
  final StoryPost post;
  final int colorIndex;

  const StoryPostDetailScreen({super.key, required this.post, this.colorIndex = 0});

  @override
  State<StoryPostDetailScreen> createState() => _StoryPostDetailScreenState();
}

class _StoryPostDetailScreenState extends State<StoryPostDetailScreen> {
  final _commentController = TextEditingController();

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      widget.post.comments.add(text);
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final color = _avatarColors[widget.colorIndex % _avatarColors.length];

    return Scaffold(
      appBar: AppBar(title: Text('${post.teacherName}\'s post')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
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
                            '${post.classTag} · ${_formatDate(post.date)}',
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
                Text(post.body),
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
                    Row(
                      children: [
                        const Icon(PhosphorIconsRegular.chatCircle, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text('${post.comments.length} comments',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.borderLight),
                ),
                ...post.comments.map((comment) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(comment),
                      ),
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderLight))),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _addComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: IconButton(
                      icon: const Icon(PhosphorIconsFill.paperPlaneTilt, color: Colors.white, size: 18),
                      onPressed: _addComment,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
