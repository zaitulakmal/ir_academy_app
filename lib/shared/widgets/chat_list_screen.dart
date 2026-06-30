import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/chat_models.dart';
import '../../core/theme/app_colors.dart';
import 'group_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String title;
  final List<ChatThread> threads;
  final List<ChatGroup> groups;
  final String currentUserName;
  final VoidCallback? onCreateGroup;

  const ChatListScreen({
    super.key,
    required this.title,
    required this.threads,
    this.groups = const [],
    required this.currentUserName,
    this.onCreateGroup,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<ChatGroup> get _myGroups =>
      widget.groups.where((g) => g.members.any((m) => m.name == widget.currentUserName)).toList();

  @override
  Widget build(BuildContext context) {
    final groups = _myGroups;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: widget.onCreateGroup != null
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.accent,
              onPressed: widget.onCreateGroup,
              icon: const Icon(PhosphorIconsBold.usersThree, color: Colors.white),
              label: const Text('New Group', style: TextStyle(color: Colors.white)),
            )
          : null,
      body: ListView(
        children: [
          ...groups.map((group) {
            final lastMessage = group.messages.isNotEmpty ? group.messages.last : null;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                child: const Icon(PhosphorIconsFill.usersThree, color: AppColors.accent),
              ),
              title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                lastMessage != null ? '${lastMessage.senderName}: ${lastMessage.text}' : 'No messages yet',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: lastMessage != null
                  ? Text(_formatTime(lastMessage.sentAt), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
                  : null,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GroupChatScreen(group: group, currentUserName: widget.currentUserName),
                ),
              ).then((_) => setState(() {})),
            );
          }),
          if (groups.isNotEmpty && widget.threads.isNotEmpty) const Divider(height: 1, color: AppColors.borderLight),
          ...widget.threads.map((thread) => ListTile(
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
              )),
        ],
      ),
    );
  }
}

String _formatTime(DateTime date) {
  final h = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$h:${date.minute.toString().padLeft(2, '0')} $period';
}

class _ThreadMessage {
  final String text;
  final bool isMine;

  const _ThreadMessage(this.text, this.isMine);
}

class ChatThreadScreen extends StatefulWidget {
  final ChatThread thread;

  const ChatThreadScreen({super.key, required this.thread});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  late final List<_ThreadMessage> _messages = [_ThreadMessage(widget.thread.lastMessage, false)];
  final _messageController = TextEditingController();

  void _send() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ThreadMessage(text, true));
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.thread.title)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 260),
                    decoration: BoxDecoration(
                      color: message.isMine ? AppColors.primary : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(color: message.isMine ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                );
              },
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
                      controller: _messageController,
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
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: IconButton(
                      icon: const Icon(PhosphorIconsFill.paperPlaneTilt, color: Colors.white, size: 18),
                      onPressed: _send,
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
