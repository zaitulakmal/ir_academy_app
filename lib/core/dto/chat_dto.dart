import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_models.dart';

class ChatGroupDto {
  final String id;
  final String name;

  const ChatGroupDto({required this.id, required this.name});

  factory ChatGroupDto.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatGroupDto(id: doc.id, name: d['name'] as String);
  }

  Map<String, dynamic> toFirestore() => {'name': name};

  ChatGroup toDomain({List<ChatMember> members = const []}) =>
      ChatGroup(id: id, name: name, members: members);
}

class ChatMemberDto {
  final String userName;
  final String userRole;

  const ChatMemberDto({required this.userName, required this.userRole});

  factory ChatMemberDto.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatMemberDto(
      userName: d['user_name'] as String,
      userRole: d['user_role'] as String,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'user_name': userName,
        'user_role': userRole,
      };

  ChatMember toDomain() => ChatMember(
        name: userName,
        role: ChatRole.values.firstWhere(
          (r) => r.name == userRole,
          orElse: () => ChatRole.student,
        ),
      );
}

class GroupMessageDto {
  final String senderName;
  final String text;
  final DateTime sentAt;

  const GroupMessageDto({
    required this.senderName,
    required this.text,
    required this.sentAt,
  });

  factory GroupMessageDto.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GroupMessageDto(
      senderName: d['sender_name'] as String,
      text: d['text'] as String,
      sentAt: (d['sent_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'sender_name': senderName,
        'text': text,
        'sent_at': Timestamp.fromDate(sentAt),
      };

  GroupMessage toDomain() =>
      GroupMessage(senderName: senderName, text: text, sentAt: sentAt);
}
