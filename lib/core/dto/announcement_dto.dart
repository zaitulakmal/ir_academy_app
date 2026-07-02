import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_models.dart';

class AnnouncementDto {
  final String id;
  final String body;
  final String author;
  final String attachmentType;
  final String? attachmentPath;
  final String? attachmentName;
  final DateTime createdAt;

  const AnnouncementDto({
    required this.id,
    required this.body,
    required this.author,
    required this.attachmentType,
    this.attachmentPath,
    this.attachmentName,
    required this.createdAt,
  });

  factory AnnouncementDto.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AnnouncementDto(
      id: doc.id,
      body: d['body'] as String,
      author: d['author'] as String,
      attachmentType: d['attachment_type'] as String? ?? 'none',
      attachmentPath: d['attachment_path'] as String?,
      attachmentName: d['attachment_name'] as String?,
      createdAt: (d['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'body': body,
        'author': author,
        'attachment_type': attachmentType,
        if (attachmentPath != null) 'attachment_path': attachmentPath,
        if (attachmentName != null) 'attachment_name': attachmentName,
        'created_at': Timestamp.fromDate(createdAt),
      };

  AnnouncementPost toDomain() => AnnouncementPost(
        id: id,
        body: body,
        author: author,
        timeLabel: _relativeTime(createdAt),
        attachmentType: AnnouncementAttachmentType.values.firstWhere(
          (e) => e.name == attachmentType,
          orElse: () => AnnouncementAttachmentType.none,
        ),
        attachmentPath: attachmentPath,
        attachmentName: attachmentName,
      );

  static AnnouncementDto fromDomain(AnnouncementPost post, {String? overrideId}) => AnnouncementDto(
        id: overrideId ?? post.id ?? '',
        body: post.body,
        author: post.author,
        attachmentType: post.attachmentType.name,
        attachmentPath: post.attachmentPath,
        attachmentName: post.attachmentName,
        createdAt: DateTime.now(),
      );

  static String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
