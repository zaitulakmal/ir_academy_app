enum LearnerCategory { kssr, kssm, cambridgePrimary, cambridgeSecondary }

String learnerCategoryLabel(LearnerCategory category) {
  switch (category) {
    case LearnerCategory.kssr:
      return 'KSSR';
    case LearnerCategory.kssm:
      return 'KSSM';
    case LearnerCategory.cambridgePrimary:
      return 'Cambridge Primary';
    case LearnerCategory.cambridgeSecondary:
      return 'Cambridge Secondary';
  }
}

class Learner {
  final String id;
  final String name;
  final LearnerCategory category;
  final String form;
  final String parentName;
  final String parentPhone;
  final double attendanceRate;

  const Learner({
    required this.id,
    required this.name,
    required this.category,
    required this.form,
    required this.parentName,
    required this.parentPhone,
    required this.attendanceRate,
  });
}
