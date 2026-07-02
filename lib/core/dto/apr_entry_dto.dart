import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/apr_entry.dart';

class AprEntryDto {
  final String id;
  final String learnerName;
  final DateTime date;
  final String subject;
  final String topicCovered;
  final String progress;
  final String homeworkAssigned;
  final bool homeworkDone;
  final String observations;
  final String followUpAction;
  final String? activityId;

  const AprEntryDto({
    required this.id,
    required this.learnerName,
    required this.date,
    required this.subject,
    required this.topicCovered,
    required this.progress,
    required this.homeworkAssigned,
    required this.homeworkDone,
    required this.observations,
    required this.followUpAction,
    this.activityId,
  });

  factory AprEntryDto.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AprEntryDto(
      id: doc.id,
      learnerName: d['learner_name'] as String,
      date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      subject: d['subject'] as String,
      topicCovered: d['topic_covered'] as String,
      progress: d['progress'] as String? ?? 'good',
      homeworkAssigned: d['homework_assigned'] as String? ?? '',
      homeworkDone: d['homework_done'] as bool? ?? false,
      observations: d['observations'] as String? ?? '',
      followUpAction: d['follow_up_action'] as String? ?? '',
      activityId: d['activity_id'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'learner_name': learnerName,
        'date': Timestamp.fromDate(date),
        'subject': subject,
        'topic_covered': topicCovered,
        'progress': progress,
        'homework_assigned': homeworkAssigned,
        'homework_done': homeworkDone,
        'observations': observations,
        'follow_up_action': followUpAction,
        if (activityId != null) 'activity_id': activityId,
      };

  AprEntry toDomain() => AprEntry(
        id: id,
        learnerName: learnerName,
        date: date,
        subject: subject,
        topicCovered: topicCovered,
        progress: ProgressLevel.values.firstWhere(
          (e) => e.name == progress,
          orElse: () => ProgressLevel.good,
        ),
        homeworkAssigned: homeworkAssigned,
        homeworkDone: homeworkDone,
        observations: observations,
        followUpAction: followUpAction,
        activityId: activityId,
      );

  static AprEntryDto fromDomain(AprEntry entry, {String? overrideId}) => AprEntryDto(
        id: overrideId ?? entry.id ?? '',
        learnerName: entry.learnerName,
        date: entry.date,
        subject: entry.subject,
        topicCovered: entry.topicCovered,
        progress: entry.progress.name,
        homeworkAssigned: entry.homeworkAssigned,
        homeworkDone: entry.homeworkDone,
        observations: entry.observations,
        followUpAction: entry.followUpAction,
        activityId: entry.activityId,
      );
}
