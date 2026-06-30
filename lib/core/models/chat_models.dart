import 'dart:typed_data';

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
  final String body;
  final String author;
  final String timeLabel;
  final AnnouncementAttachmentType attachmentType;
  final String? attachmentPath;
  final String? attachmentName;
  final Uint8List? attachmentBytes;

  const AnnouncementPost({
    required this.body,
    required this.author,
    required this.timeLabel,
    this.attachmentType = AnnouncementAttachmentType.none,
    this.attachmentPath,
    this.attachmentName,
    this.attachmentBytes,
  });
}
