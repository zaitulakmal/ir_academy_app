class ChatThread {
  final String title;
  final String subtitle;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;

  const ChatThread({
    required this.title,
    required this.subtitle,
    required this.lastMessage,
    required this.timeLabel,
    this.unreadCount = 0,
  });
}

class AnnouncementPost {
  final String title;
  final String body;
  final String author;
  final String timeLabel;

  const AnnouncementPost({
    required this.title,
    required this.body,
    required this.author,
    required this.timeLabel,
  });
}
