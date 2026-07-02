import 'dart:typed_data';

class ChatThread {
  final String title;
  final String subtitle;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
  // The other person's actual name — used to compute a shared thread_id
  final String contactName;

  const ChatThread({
    required this.title,
    required this.subtitle,
    required this.lastMessage,
    required this.timeLabel,
    this.unreadCount = 0,
    required this.contactName,
  });

  // Deterministic thread ID for any two participants — scales to any number of users
  String threadIdWith(String myName) {
    String sanitize(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final parts = [sanitize(myName), sanitize(contactName)]..sort();
    return 'dm_${parts[0]}__${parts[1]}';
  }
}

enum ChatRole { admin, teacher, student, parent }

String chatRoleLabel(ChatRole role) {
  switch (role) {
    case ChatRole.admin:
      return 'Admin';
    case ChatRole.teacher:
      return 'Teacher';
    case ChatRole.student:
      return 'Student';
    case ChatRole.parent:
      return 'Parent';
  }
}

class ChatMember {
  final String name;
  final ChatRole role;

  const ChatMember({required this.name, required this.role});
}

class GroupMessage {
  final String senderName;
  final String text;
  final DateTime sentAt;

  GroupMessage({required this.senderName, required this.text, required this.sentAt});
}

class ChatGroup {
  final String id;
  String name;
  List<ChatMember> members;
  final List<GroupMessage> messages;

  ChatGroup({
    required this.id,
    required this.name,
    required this.members,
    List<GroupMessage>? messages,
  }) : messages = messages ?? [];
}

enum AnnouncementAttachmentType { none, photo, video, file }

class AnnouncementPost {
  final String? id;
  final String body;
  final String author;
  final String timeLabel;
  final AnnouncementAttachmentType attachmentType;
  final String? attachmentPath;
  final String? attachmentName;
  final Uint8List? attachmentBytes;

  const AnnouncementPost({
    this.id,
    required this.body,
    required this.author,
    required this.timeLabel,
    this.attachmentType = AnnouncementAttachmentType.none,
    this.attachmentPath,
    this.attachmentName,
    this.attachmentBytes,
  });
}
