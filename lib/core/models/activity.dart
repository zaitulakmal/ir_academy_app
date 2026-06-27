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
  });
}

class Submission {
  final String activityId;
  final String learnerName;
  bool submitted;
  String? textResponse;
  String? attachmentPath;
  String? attachmentName;
  DateTime? submittedAt;

  Submission({
    required this.activityId,
    required this.learnerName,
    this.submitted = false,
    this.textResponse,
    this.attachmentPath,
    this.attachmentName,
    this.submittedAt,
  });
}
