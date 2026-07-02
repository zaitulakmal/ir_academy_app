enum NotificationType { homework, grade, announcement, calendar, chat }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final NotificationType type;
  bool read;

  AppNotification({
    this.id = '',
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.read = false,
  });
}
