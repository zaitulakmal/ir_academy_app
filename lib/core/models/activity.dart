import 'dart:typed_data';

enum ResponseType { text, video, photo, drawing, worksheet }

class Activity {
  final String id;
  final String title;
  final String instructions;
  final ResponseType responseType;
  final bool wholeClass;
  final List<String> assignedLearners;
  final String? subject;
  final DateTime createdAt;
  final String? attachmentPath;
  final String? attachmentName;
  final Uint8List? attachmentBytes;

  const Activity({
    required this.id,
    required this.title,
    required this.instructions,
    required this.responseType,
    required this.wholeClass,
    this.assignedLearners = const [],
    this.subject,
    required this.createdAt,
    this.attachmentPath,
    this.attachmentName,
    this.attachmentBytes,
  });
}

class SubmissionAttachment {
  final String path;
  final String name;
  String? markupPath;
  final Uint8List? bytes;
  Uint8List? markupBytes;

  SubmissionAttachment({
    required this.path,
    required this.name,
    this.markupPath,
    this.bytes,
    this.markupBytes,
  });
}

class Submission {
  final String activityId;
  final String learnerName;
  bool submitted;
  String? textResponse;
  List<SubmissionAttachment> attachments;
  DateTime? submittedAt;
  bool graded;
  String? grade;
  String? feedback;
  DateTime? gradedAt;

  Submission({
    required this.activityId,
    required this.learnerName,
    this.submitted = false,
    this.textResponse,
    List<SubmissionAttachment>? attachments,
    this.submittedAt,
    this.graded = false,
    this.grade,
    this.feedback,
    this.gradedAt,
  }) : attachments = attachments ?? [];
}
