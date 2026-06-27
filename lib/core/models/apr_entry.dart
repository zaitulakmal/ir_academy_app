enum ProgressLevel { excellent, good, needsSupport }

class AprEntry {
  final DateTime date;
  final String subject;
  final String topicCovered;
  final ProgressLevel progress;
  final String homeworkAssigned;
  final bool homeworkDone;
  final String observations;
  final String followUpAction;

  const AprEntry({
    required this.date,
    required this.subject,
    required this.topicCovered,
    required this.progress,
    required this.homeworkAssigned,
    required this.homeworkDone,
    required this.observations,
    required this.followUpAction,
  });
}
