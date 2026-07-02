import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/app_notification.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/app_colors.dart';

(IconData, Color) _typeStyle(NotificationType type) {
  switch (type) {
    case NotificationType.homework:
      return (PhosphorIconsFill.notebook, AppColors.warning);
    case NotificationType.grade:
      return (PhosphorIconsFill.sealCheck, AppColors.primary);
    case NotificationType.announcement:
      return (PhosphorIconsFill.megaphone, AppColors.accent);
    case NotificationType.calendar:
      return (PhosphorIconsFill.calendarCheck, AppColors.success);
    case NotificationType.chat:
      return (PhosphorIconsFill.chatCircleDots, AppColors.primary);
  }
}

String _formatTimeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

class NotificationBellButton extends StatefulWidget {
  final List<AppNotification> notifications;

  const NotificationBellButton({super.key, required this.notifications});

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  @override
  Widget build(BuildContext context) {
    final unreadCount = widget.notifications.where((n) => !n.read).length;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(PhosphorIconsRegular.bell, color: AppColors.primary),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => NotificationsScreen(notifications: widget.notifications)),
          ).then((_) => setState(() {})),
        ),
        if (unreadCount > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
              constraints: const BoxConstraints(minWidth: 16),
              child: Text(
                '$unreadCount',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  final List<AppNotification> notifications;

  const NotificationsScreen({super.key, required this.notifications});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      await FirebaseService.loadNotifications();
    } catch (_) {}
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = widget.notifications.any((n) => !n.read);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () {
                setState(() {
                  for (final n in widget.notifications) {
                    n.read = true;
                  }
                });
                FirebaseService.markNotificationsRead(
                  widget.notifications.map((n) => n.id).where((id) => id.isNotEmpty),
                );
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: widget.notifications.isEmpty
          ? const Center(child: Text('No notifications yet.', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = widget.notifications[index];
                final (icon, color) = _typeStyle(notification.type);
                return Card(
                  color: notification.read ? null : AppColors.primary.withValues(alpha: 0.04),
                  child: ListTile(
                    onTap: () {
                      setState(() => notification.read = true);
                      if (notification.id.isNotEmpty) {
                        FirebaseService.markNotificationsRead([notification.id]);
                      }
                    },
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(notification.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_formatTimeAgo(notification.time),
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        if (!notification.read) ...[
                          const SizedBox(height: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
