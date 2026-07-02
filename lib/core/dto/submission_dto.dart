import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity.dart';

class SubmissionDto {
  final String activityId;
  final String learnerName;
  final bool submitted;
  final String? textResponse;
  final List<String> attachmentPaths;
  final List<String> attachmentNames;
  final List<String?> markupPaths;
  final DateTime? submittedAt;
  final bool graded;
  final String? grade;
  final String? feedback;
  final DateTime? gradedAt;

  const SubmissionDto({
    required this.activityId,
    required this.learnerName,
    required this.submitted,
    this.textResponse,
    required this.attachmentPaths,
    required this.attachmentNames,
    required this.markupPaths,
    this.submittedAt,
    required this.graded,
    this.grade,
    this.feedback,
    this.gradedAt,
  });

  factory SubmissionDto.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SubmissionDto(
      activityId: d['activity_id'] as String,
      learnerName: d['learner_name'] as String,
      submitted: d['submitted'] as bool? ?? false,
      textResponse: d['text_response'] as String?,
      attachmentPaths: List<String>.from(d['attachment_paths'] ?? []),
      attachmentNames: List<String>.from(d['attachment_names'] ?? []),
      markupPaths: List<dynamic>.from(d['markup_paths'] ?? []).map((e) => e as String?).toList(),
      submittedAt: (d['submitted_at'] as Timestamp?)?.toDate(),
      graded: d['graded'] as bool? ?? false,
      grade: d['grade'] as String?,
      feedback: d['feedback'] as String?,
      gradedAt: (d['graded_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'activity_id': activityId,
        'learner_name': learnerName,
        'submitted': submitted,
        if (textResponse != null) 'text_response': textResponse,
        'attachment_paths': attachmentPaths,
        'attachment_names': attachmentNames,
        'markup_paths': markupPaths,
        if (submittedAt != null) 'submitted_at': Timestamp.fromDate(submittedAt!),
        'graded': graded,
        if (grade != null) 'grade': grade,
        if (feedback != null) 'feedback': feedback,
        if (gradedAt != null) 'graded_at': Timestamp.fromDate(gradedAt!),
      };

  Submission toDomain() {
    final attachments = List.generate(
      attachmentPaths.length,
      (i) => SubmissionAttachment(
        path: attachmentPaths[i],
        name: i < attachmentNames.length ? attachmentNames[i] : 'file',
        markupPath: i < markupPaths.length ? markupPaths[i] : null,
      ),
    );
    return Submission(
      activityId: activityId,
      learnerName: learnerName,
      submitted: submitted,
      textResponse: textResponse,
      attachments: attachments,
      submittedAt: submittedAt,
      graded: graded,
      grade: grade,
      feedback: feedback,
      gradedAt: gradedAt,
    );
  }

  static SubmissionDto fromDomain(Submission sub) => SubmissionDto(
        activityId: sub.activityId,
        learnerName: sub.learnerName,
        submitted: sub.submitted,
        textResponse: sub.textResponse,
        attachmentPaths: sub.attachments.map((a) => a.path).toList(),
        attachmentNames: sub.attachments.map((a) => a.name).toList(),
        markupPaths: sub.attachments.map((a) => a.markupPath).toList(),
        submittedAt: sub.submittedAt,
        graded: sub.graded,
        grade: sub.grade,
        feedback: sub.feedback,
        gradedAt: sub.gradedAt,
      );
}
