import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity.dart';

class ActivityDto {
  final String id;
  final String title;
  final String instructions;
  final String responseType;
  final bool wholeClass;
  final List<String> assignedLearners;
  final String? subject;
  final DateTime createdAt;
  final String? attachmentName;
  final String? attachmentPath;

  const ActivityDto({
    required this.id,
    required this.title,
    required this.instructions,
    required this.responseType,
    required this.wholeClass,
    required this.assignedLearners,
    this.subject,
    required this.createdAt,
    this.attachmentName,
    this.attachmentPath,
  });

  factory ActivityDto.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ActivityDto(
      id: doc.id,
      title: d['title'] as String,
      instructions: d['instructions'] as String? ?? '',
      responseType: d['response_type'] as String? ?? 'text',
      wholeClass: d['whole_class'] as bool? ?? true,
      assignedLearners: List<String>.from(d['assigned_learners'] ?? []),
      subject: d['subject'] as String?,
      createdAt: (d['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      attachmentName: d['attachment_name'] as String?,
      attachmentPath: d['attachment_path'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'instructions': instructions,
        'response_type': responseType,
        'whole_class': wholeClass,
        'assigned_learners': assignedLearners,
        if (subject != null) 'subject': subject,
        'created_at': Timestamp.fromDate(createdAt),
        if (attachmentName != null) 'attachment_name': attachmentName,
        if (attachmentPath != null) 'attachment_path': attachmentPath,
      };

  Activity toDomain() => Activity(
        id: id,
        title: title,
        instructions: instructions,
        responseType: ResponseType.values.firstWhere(
          (e) => e.name == responseType,
          orElse: () => ResponseType.text,
        ),
        wholeClass: wholeClass,
        assignedLearners: assignedLearners,
        subject: subject,
        createdAt: createdAt,
        attachmentName: attachmentName,
        attachmentPath: attachmentPath,
      );

  static ActivityDto fromDomain(Activity act) => ActivityDto(
        id: act.id,
        title: act.title,
        instructions: act.instructions,
        responseType: act.responseType.name,
        wholeClass: act.wholeClass,
        assignedLearners: act.assignedLearners,
        subject: act.subject,
        createdAt: act.createdAt,
        attachmentName: act.attachmentName,
        attachmentPath: act.attachmentPath,
      );
}
