enum NotificationType { homework, grade, announcement, calendar, chat }

class AppNotification {
  final String title;
  final String body;
  final DateTime time;
  final NotificationType type;
  bool read;

  AppNotification({
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.read = false,
  });
}
