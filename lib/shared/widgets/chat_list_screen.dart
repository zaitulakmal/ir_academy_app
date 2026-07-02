import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/chat_models.dart';
import '../../core/services/firebase_service.dart';
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
  // groupId → last message
  final Map<String, GroupMessage> _groupLatest = {};
  // thread contactName → last message
  final Map<String, GroupMessage> _threadLatest = {};

  List<ChatGroup> get _myGroups =>
      widget.groups.where((g) => g.members.any((m) => m.name == widget.currentUserName)).toList();

  @override
  void initState() {
    super.initState();
    _refreshGroups();
  }

  Future<void> _refreshGroups() async {
    // Pick up groups created after login (e.g. teacher just made one).
    try {
      await FirebaseService.reloadChatGroups();
    } catch (_) {}
    if (mounted) setState(() {});
    await _loadLatest();
  }

  Future<void> _loadLatest() async {
    for (final group in _myGroups) {
      final msgs = await FirebaseService.loadGroupMessages(group.id);
      if (msgs.isNotEmpty && mounted) {
        setState(() => _groupLatest[group.id] = msgs.first);
      }
    }
    for (final thread in widget.threads) {
      final msgs = await FirebaseService.loadChatMessages(
          thread.threadIdWith(widget.currentUserName));
      if (msgs.isNotEmpty && mounted) {
        setState(() => _threadLatest[thread.contactName] = msgs.first);
      }
    }
  }

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
            final latest = _groupLatest[group.id];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                child: const Icon(PhosphorIconsFill.usersThree, color: AppColors.accent),
              ),
              title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                latest != null ? '${latest.senderName}: ${latest.text}' : 'No messages yet',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: latest != null
                  ? Text(_formatTime(latest.sentAt),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
                  : null,
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(
                    builder: (_) => GroupChatScreen(
                        group: group, currentUserName: widget.currentUserName),
                  ))
                  .then((_) => _loadLatest()),
            );
          }),
          if (groups.isNotEmpty && widget.threads.isNotEmpty)
            const Divider(height: 1, color: AppColors.borderLight),
          ...widget.threads.map((thread) {
            final latest = _threadLatest[thread.contactName];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: const Icon(PhosphorIconsFill.user, color: AppColors.primary),
              ),
              title: Text(thread.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                latest?.text ?? thread.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    latest != null ? _formatTime(latest.sentAt) : thread.timeLabel,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  if (thread.unreadCount > 0) ...[
                    const SizedBox(height: 4),
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: AppColors.accent,
                      child: Text(
                        '${thread.unreadCount}',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ],
              ),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(
                    builder: (_) => ChatThreadScreen(
                        thread: thread, currentUserName: widget.currentUserName),
                  ))
                  .then((_) => _loadLatest()),
            );
          }),
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

class ChatThreadScreen extends StatefulWidget {
  final ChatThread thread;
  final String currentUserName;

  const ChatThreadScreen({super.key, required this.thread, required this.currentUserName});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final _messageController = TextEditingController();
  List<GroupMessage> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  late final String _threadId = widget.thread.threadIdWith(widget.currentUserName);

  Future<void> _loadMessages() async {
    final msgs = await FirebaseService.loadChatMessages(_threadId);
    if (!mounted) return;
    setState(() {
      _messages = msgs;
      _loading = false;
    });
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    final msg = GroupMessage(
      senderName: widget.currentUserName,
      text: text,
      sentAt: DateTime.now(),
    );
    setState(() => _messages.insert(0, msg));
    try {
      await FirebaseService.sendChatMessage(
        _threadId,
        widget.currentUserName,
        text,
        recipientName: widget.thread.contactName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatTimeMsg(DateTime date) {
    final h = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$h:${date.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.thread.title)),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          'No messages yet.\nStart the conversation!',
                          style: TextStyle(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMine = message.senderName == widget.currentUserName;
                          return Align(
                            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              constraints: const BoxConstraints(maxWidth: 260),
                              decoration: BoxDecoration(
                                color: isMine ? AppColors.primary : AppColors.borderLight,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.text,
                                    style: TextStyle(
                                        color: isMine ? Colors.white : AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTimeMsg(message.sentAt),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMine ? Colors.white70 : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      icon: const Icon(PhosphorIconsFill.paperPlaneTilt,
                          color: Colors.white, size: 18),
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
