import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/chat_models.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/app_colors.dart';
import 'group_info_screen.dart';

class GroupChatScreen extends StatefulWidget {
  final ChatGroup group;
  final String currentUserName;

  const GroupChatScreen({super.key, required this.group, required this.currentUserName});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _messageController = TextEditingController();
  List<GroupMessage> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final msgs = await FirebaseService.loadGroupMessages(widget.group.id);
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
      await FirebaseService.sendGroupMessage(widget.group.id, widget.currentUserName, text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatTime(DateTime date) {
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
    final stillMember = widget.group.members.any((m) => m.name == widget.currentUserName);
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GroupInfoScreen(group: widget.group, currentUserName: widget.currentUserName),
            ),
          ).then((_) => setState(() {})),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.group.name, overflow: TextOverflow.ellipsis),
              Text(
                '${widget.group.members.length} members',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text('No messages yet.', style: TextStyle(color: AppColors.textSecondary)),
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
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: const BoxConstraints(maxWidth: 280),
                              decoration: BoxDecoration(
                                color: isMine ? AppColors.primary : AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isMine)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: Text(
                                        message.senderName,
                                        style: const TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent),
                                      ),
                                    ),
                                  Text(message.text,
                                      style: TextStyle(color: isMine ? Colors.white : AppColors.textPrimary)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(message.sentAt),
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
          if (stillMember)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderLight))),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
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
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderLight))),
              child: const SafeArea(
                top: false,
                child: Text(
                  'You left this group.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
