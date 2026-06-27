import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/chat_models.dart';
import '../../core/theme/app_colors.dart';

class ChatListScreen extends StatelessWidget {
  final String title;
  final List<ChatThread> threads;

  const ChatListScreen({super.key, required this.title, required this.threads});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        itemCount: threads.length,
        separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
        itemBuilder: (context, index) {
          final thread = threads[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: const Icon(PhosphorIconsFill.user, color: AppColors.primary),
            ),
            title: Text(thread.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(thread.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(thread.timeLabel, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                if (thread.unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  CircleAvatar(
                    radius: 9,
                    backgroundColor: AppColors.accent,
                    child: Text(
                      '${thread.unreadCount}',
                      style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ChatThreadScreen(thread: thread)),
            ),
          );
        },
      ),
    );
  }
}

class ChatThreadScreen extends StatelessWidget {
  final ChatThread thread;

  const ChatThreadScreen({super.key, required this.thread});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(thread.title)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 260),
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(thread.lastMessage),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: IconButton(
                      icon: const Icon(PhosphorIconsFill.paperPlaneTilt, color: Colors.white, size: 18),
                      onPressed: () {},
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
