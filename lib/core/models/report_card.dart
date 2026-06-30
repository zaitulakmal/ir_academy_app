class SubjectGrade {
  final String subject;
  final String grade;
  final double score;
  final String? remarks;

  const SubjectGrade({
    required this.subject,
    required this.grade,
    required this.score,
    this.remarks,
  });
}

class ReportCard {
  final String termName;
  final DateTime issuedDate;
  final List<SubjectGrade> subjects;
  final String? teacherRemarks;
  final int? classRank;
  final int? classSize;
  final double attendanceRate;

  const ReportCard({
    required this.termName,
    required this.issuedDate,
    required this.subjects,
    this.teacherRemarks,
    this.classRank,
    this.classSize,
    required this.attendanceRate,
  });

  double get averageScore =>
      subjects.isEmpty ? 0 : subjects.map((s) => s.score).reduce((a, b) => a + b) / subjects.length;
}
