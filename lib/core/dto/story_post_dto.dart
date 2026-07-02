import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/story_post.dart';

class StoryPostDto {
  final String id;
  final String teacherName;
  final String classTag;
  final DateTime date;
  final String body;
  final String attachmentType;
  final String? attachmentUrl;
  final String? attachmentName;
  final String? attachmentSizeLabel;
  final bool wholeClass;
  final List<String> assignedLearners;
  final int likeCount;
  final List<String> comments;

  const StoryPostDto({
    required this.id,
    required this.teacherName,
    required this.classTag,
    required this.date,
    required this.body,
    required this.attachmentType,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSizeLabel,
    required this.wholeClass,
    required this.assignedLearners,
    required this.likeCount,
    required this.comments,
  });

  factory StoryPostDto.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return StoryPostDto(
      id: doc.id,
      teacherName: d['teacher_name'] as String,
      classTag: d['class_tag'] as String,
      date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      body: d['body'] as String,
      attachmentType: d['attachment_type'] as String? ?? 'none',
      attachmentUrl: d['attachment_url'] as String?,
      attachmentName: d['attachment_name'] as String?,
      attachmentSizeLabel: d['attachment_size_label'] as String?,
      wholeClass: d['whole_class'] as bool? ?? true,
      assignedLearners: List<String>.from(d['assigned_learners'] ?? []),
      likeCount: d['like_count'] as int? ?? 0,
      comments: List<String>.from(d['comments'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'teacher_name': teacherName,
        'class_tag': classTag,
        'date': Timestamp.fromDate(date),
        'body': body,
        'attachment_type': attachmentType,
        if (attachmentUrl != null) 'attachment_url': attachmentUrl,
        if (attachmentName != null) 'attachment_name': attachmentName,
        if (attachmentSizeLabel != null) 'attachment_size_label': attachmentSizeLabel,
        'whole_class': wholeClass,
        'assigned_learners': assignedLearners,
        'like_count': likeCount,
        'comments': comments,
      };

  StoryPost toDomain() => StoryPost(
        id: id,
        teacherName: teacherName,
        classTag: classTag,
        date: date,
        body: body,
        attachmentType: StoryAttachmentType.values.firstWhere(
          (e) => e.name == attachmentType,
          orElse: () => StoryAttachmentType.none,
        ),
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
        attachmentSizeLabel: attachmentSizeLabel,
        wholeClass: wholeClass,
        assignedLearners: assignedLearners,
        likeCount: likeCount,
        comments: comments,
      );

  static StoryPostDto fromDomain(StoryPost post) => StoryPostDto(
        id: post.id,
        teacherName: post.teacherName,
        classTag: post.classTag,
        date: post.date,
        body: post.body,
        attachmentType: post.attachmentType.name,
        attachmentUrl: post.attachmentUrl,
        attachmentName: post.attachmentName,
        attachmentSizeLabel: post.attachmentSizeLabel,
        wholeClass: post.wholeClass,
        assignedLearners: post.assignedLearners,
        likeCount: post.likeCount,
        comments: post.comments,
      );
}
