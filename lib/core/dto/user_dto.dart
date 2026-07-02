import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/learner.dart';

class UserDto {
  final String id;
  final String name;
  final String role;
  final String? form;
  final String? category;
  final String? subject;
  final String? parentName;
  final String? parentPhone;
  final double attendanceRate;
  final String? fcmToken;
  final String? syllabus;
  final String? portalUsername;
  final String? portalPassword;
  final String? classGroupLink;
  final String? googleMeetLink;

  const UserDto({
    required this.id,
    required this.name,
    required this.role,
    this.form,
    this.category,
    this.subject,
    this.parentName,
    this.parentPhone,
    this.attendanceRate = 1.0,
    this.fcmToken,
    this.syllabus,
    this.portalUsername,
    this.portalPassword,
    this.classGroupLink,
    this.googleMeetLink,
  });

  factory UserDto.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserDto(
      id: doc.id,
      name: d['name'] as String,
      role: d['role'] as String,
      form: d['form'] as String?,
      category: d['category'] as String?,
      subject: d['subject'] as String?,
      parentName: d['parent_name'] as String?,
      parentPhone: d['parent_phone'] as String?,
      attendanceRate: (d['attendance_rate'] as num?)?.toDouble() ?? 1.0,
      fcmToken: d['fcm_token'] as String?,
      syllabus: d['syllabus'] as String?,
      portalUsername: d['portal_username'] as String?,
      portalPassword: d['portal_password'] as String?,
      classGroupLink: d['class_group_link'] as String?,
      googleMeetLink: d['google_meet_link'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'role': role,
        if (form != null) 'form': form,
        if (category != null) 'category': category,
        if (subject != null) 'subject': subject,
        if (parentName != null) 'parent_name': parentName,
        if (parentPhone != null) 'parent_phone': parentPhone,
        'attendance_rate': attendanceRate,
        if (fcmToken != null) 'fcm_token': fcmToken,
        if (syllabus != null) 'syllabus': syllabus,
        if (portalUsername != null) 'portal_username': portalUsername,
        if (portalPassword != null) 'portal_password': portalPassword,
        if (classGroupLink != null) 'class_group_link': classGroupLink,
        if (googleMeetLink != null) 'google_meet_link': googleMeetLink,
      };

  Learner toLearner() => Learner(
        id: id,
        name: name,
        category: LearnerCategory.values.firstWhere(
          (c) => c.name == (category ?? 'kssm'),
          orElse: () => LearnerCategory.kssm,
        ),
        form: form ?? '',
        parentName: parentName ?? '',
        parentPhone: parentPhone ?? '',
        attendanceRate: attendanceRate,
      );
}
