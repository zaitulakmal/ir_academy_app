import 'dart:math';

import '../models/activity.dart';
import '../models/apr_entry.dart';
import '../models/calendar_event.dart';
import '../models/chat_models.dart';
import '../models/app_notification.dart';
import '../models/learner.dart';
import '../models/report_card.dart';
import '../models/story_post.dart';

/// Placeholder data standing in for the real backend until Supabase is wired up.
class MockData {
  MockData._();

  static final studentName = 'Arissa Humaira';
  static final teacherName = 'Cikgu Aiman';
  static final schoolName = 'IR Academy';
  static final studentForm = 'Form 2';
  static final studentId = 'IRA-2026-0142';
  static final studentSyllabus = 'KSSM + Cambridge English';
  static final portalUsername = 'arissa.humaira';
  static final portalPassword = 'IrAcademy@2026';
  static final classGroupLink = 'https://chat.whatsapp.com/example-form2-group';
  static final googleMeetLink = 'https://meet.google.com/example-code';

  static final List<AprEntry> aprEntries = [
    AprEntry(
      learnerName: 'Arissa Humaira',
      date: DateTime(2026, 1, 20),
      subject: 'Mathematics',
      topicCovered: '1.3 Patterns & Sequences',
      progress: ProgressLevel.good,
      homeworkAssigned: 'Workbook pg. 12-14, Q1-10',
      homeworkDone: false,
      observations: 'Solves problems independently, confident with the topic.',
      followUpAction: '2.1 Expansion',
      activityId: 'a1',
    ),
    AprEntry(
      learnerName: 'Arissa Humaira',
      date: DateTime(2026, 1, 18),
      subject: 'English',
      topicCovered: 'Essay structure: narrative writing',
      progress: ProgressLevel.excellent,
      homeworkAssigned: 'Write a 150-word narrative essay',
      homeworkDone: true,
      observations: 'Strong vocabulary, good story flow.',
      followUpAction: 'Persuasive writing techniques',
      activityId: 'a2',
    ),
    AprEntry(
      learnerName: 'Arissa Humaira',
      date: DateTime(2026, 1, 5),
      subject: 'Pendidikan Islam',
      topicCovered: 'Pendidikan Islam Briefing',
      progress: ProgressLevel.good,
      homeworkAssigned: 'Self-study: revise key topics',
      homeworkDone: true,
      observations: 'Understands key topics, asks questions when unsure.',
      followUpAction: 'Continue with next chapter',
    ),
  ];

  static final List<CalendarEvent> calendarEvents = [
    CalendarEvent(
      id: 'ev1',
      title: 'IR Academy - Peperiksaan Percubaan SPM 2026 | SPM Trial Examination 2026',
      description: 'IR Academy SPM Trial Examination 2026\n\n'
          'IR Academy\'s official SPM Trial Examination will begin on 27 July 2026 (Monday).',
      startDate: DateTime(2026, 7, 27),
      endDate: DateTime(2026, 8, 6),
      category: 'School Event',
      signupSlots: [SignupSlot(label: 'Invigilator Volunteer', capacity: 5)],
    ),
    CalendarEvent(
      id: 'ev2',
      title: 'Cambridge Final-Term Examination 2025/26',
      description: 'Final-term examination week for all Cambridge learners.',
      startDate: DateTime(2026, 8, 3),
      endDate: DateTime(2026, 8, 7),
      category: 'School Event',
    ),
    CalendarEvent(
      id: 'ev3',
      title: 'Cambridge IGCSE Mock Examination (October/November Series 2026)',
      description: 'Mock examination in preparation for the Oct/Nov IGCSE series.',
      startDate: DateTime(2026, 8, 3),
      endDate: DateTime(2026, 8, 11),
      category: 'School Event',
    ),
    CalendarEvent(
      id: 'ev4',
      title: 'Final-Term Break/End of Academic Year 2025/26 (Cambridge Learners)',
      description: 'No classes during the final-term break.',
      startDate: DateTime(2026, 8, 24),
      endDate: DateTime(2026, 8, 31),
      category: 'Holiday',
      remindFiveDaysBefore: false,
    ),
    CalendarEvent(
      id: 'ev5',
      title: 'IR Academy - KSSR : Matriks Pembelajaran Tahun 4 (MPT4)',
      description: 'KSSR Tahun 4 learning matrix assessment window.',
      startDate: DateTime(2026, 10, 6),
      endDate: DateTime(2026, 10, 8),
      category: 'School Event',
    ),
  ];

  static final List<Learner> learners = _generateLearners();

  static List<Learner> _generateLearners() {
    final random = Random(42);

    const maleFirstNames = [
      'Ahmad', 'Muhammad', 'Amir', 'Aiman', 'Daniel', 'Hakim', 'Irfan', 'Zaki', 'Haris', 'Faiz',
      'Naqib', 'Adam', 'Danial', 'Luqman', 'Hafiz', 'Rayyan', 'Arif', 'Iskandar', 'Zikri', 'Hadi',
    ];
    const femaleFirstNames = [
      'Aisyah', 'Nur', 'Arissa', 'Humaira', 'Sofea', 'Mira', 'Alya', 'Husna', 'Iman', 'Qistina',
      'Damia', 'Balqis', 'Farah', 'Nabila', 'Adriana', 'Maisarah', 'Wani', 'Izzati', 'Khadijah', 'Sarah',
    ];
    const familyNames = [
      'Razak', 'Hassan', 'Ibrahim', 'Yusof', 'Rahman', 'Karim', 'Salleh', 'Aziz', 'Latif', 'Bakar',
      'Hamid', 'Mansor', 'Zainal', 'Othman', 'Idris', 'Rashid', 'Kassim', 'Halim', 'Nordin', 'Shukor',
    ];
    const categoryForms = {
      LearnerCategory.kssr: ['Tahun 1', 'Tahun 2', 'Tahun 3', 'Tahun 4', 'Tahun 5', 'Tahun 6'],
      LearnerCategory.kssm: ['Tingkatan 1', 'Tingkatan 2', 'Tingkatan 3', 'Tingkatan 4', 'Tingkatan 5'],
      LearnerCategory.cambridgePrimary: ['Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5', 'Year 6'],
      LearnerCategory.cambridgeSecondary: ['Form 1', 'Form 2', 'Form 3', 'Form 4', 'Form 5'],
    };
    const targetCounts = {
      LearnerCategory.kssr: 90,
      LearnerCategory.kssm: 60,
      LearnerCategory.cambridgePrimary: 90,
      LearnerCategory.cambridgeSecondary: 57,
    };

    final learners = <Learner>[
      const Learner(
        id: 'IRA-2026-0001',
        name: 'Arissa Humaira',
        category: LearnerCategory.cambridgeSecondary,
        form: 'Form 2',
        parentName: 'Pn. Salmah',
        parentPhone: '012-3456789',
        attendanceRate: 0.96,
      ),
      const Learner(
        id: 'IRA-2026-0002',
        name: 'Daniel Hakimi',
        category: LearnerCategory.cambridgeSecondary,
        form: 'Form 2',
        parentName: 'En. Rashid',
        parentPhone: '013-2345678',
        attendanceRate: 0.88,
      ),
      const Learner(
        id: 'IRA-2026-0003',
        name: 'Nur Iman',
        category: LearnerCategory.cambridgeSecondary,
        form: 'Form 1',
        parentName: 'Pn. Aishah',
        parentPhone: '014-9876543',
        attendanceRate: 0.92,
      ),
    ];

    var counter = 4;
    for (final entry in targetCounts.entries) {
      final forms = categoryForms[entry.key]!;
      for (var i = 0; i < entry.value; i++) {
        final isMale = random.nextBool();
        final first = isMale
            ? maleFirstNames[random.nextInt(maleFirstNames.length)]
            : femaleFirstNames[random.nextInt(femaleFirstNames.length)];
        final family = familyNames[random.nextInt(familyNames.length)];
        final name = '$first ${isMale ? "bin" : "binti"} $family';
        final form = forms[random.nextInt(forms.length)];
        final parentName = '${random.nextBool() ? "En." : "Pn."} ${familyNames[random.nextInt(familyNames.length)]}';
        final phone = '01${1 + random.nextInt(9)}-${1000000 + random.nextInt(8999999)}';
        final attendance = double.parse((0.75 + random.nextDouble() * 0.25).toStringAsFixed(2));
        learners.add(Learner(
          id: 'IRA-2026-${counter.toString().padLeft(4, '0')}',
          name: name,
          category: entry.key,
          form: form,
          parentName: parentName,
          parentPhone: phone,
          attendanceRate: attendance,
        ));
        counter++;
      }
    }

    return learners;
  }

  static final List<AnnouncementPost> announcements = [
    AnnouncementPost(
      body: 'Cuti sempena Hari Wesak\n\nTiada kelas pada 1 Mei. Kelas akan disambung seperti biasa pada 3 Mei.',
      author: 'IR Academy Admin',
      timeLabel: '2d ago',
    ),
    AnnouncementPost(
      body: 'Peperiksaan Pertengahan Tahun\n\nJadual peperiksaan akan dimuat naik minggu depan. Sila semak Calendar.',
      author: 'Cikgu Aiman',
      timeLabel: '5d ago',
    ),
  ];

  static final List<ChatThread> studentChats = const [
    ChatThread(
      title: 'Cikgu Aiman (Mathematics)',
      subtitle: 'Teacher',
      lastMessage: 'Good job on the homework!',
      timeLabel: '10:32 AM',
      unreadCount: 1,
    ),
    ChatThread(
      title: 'Cikgu Huda (English)',
      subtitle: 'Teacher',
      lastMessage: 'Please resubmit the essay draft.',
      timeLabel: 'Yesterday',
    ),
  ];

  static final List<ChatThread> teacherChats = const [
    ChatThread(
      title: 'Pn. Salmah (Arissa\'s parent)',
      subtitle: 'Parent',
      lastMessage: 'Terima kasih cikgu!',
      timeLabel: '9:14 AM',
      unreadCount: 2,
    ),
    ChatThread(
      title: 'En. Rashid (Daniel\'s parent)',
      subtitle: 'Parent',
      lastMessage: 'Boleh share homework hari ni?',
      timeLabel: 'Yesterday',
    ),
  ];

  static const adminName = 'IR Academy Admin';

  static final List<ChatGroup> chatGroups = [
    ChatGroup(
      id: 'cg1',
      name: '$studentForm Cendekia — Class Group',
      members: [
        ChatMember(name: teacherName, role: ChatRole.teacher),
        const ChatMember(name: adminName, role: ChatRole.admin),
        ChatMember(name: studentName, role: ChatRole.student),
        const ChatMember(name: 'Pn. Salmah', role: ChatRole.parent),
      ],
      messages: [
        GroupMessage(
          senderName: teacherName,
          text: 'Welcome to the class group! Please check Calendar for upcoming exam dates.',
          sentAt: DateTime(2026, 1, 20, 9, 0),
        ),
        GroupMessage(
          senderName: 'Pn. Salmah',
          text: 'Noted, thank you cikgu.',
          sentAt: DateTime(2026, 1, 20, 9, 5),
        ),
      ],
    ),
  ];

  static final List<Activity> activities = [
    Activity(
      id: 'a1',
      title: 'Math worksheet 2.4',
      instructions: 'Complete questions 1-10. Show your working for each expansion.',
      responseType: ResponseType.worksheet,
      wholeClass: true,
      subject: 'Mathematics',
      createdAt: DateTime(2026, 1, 21),
    ),
    Activity(
      id: 'a2',
      title: 'Narrative Essay Draft',
      instructions: 'Write a 150-word narrative essay. Focus on story structure and vocabulary.',
      responseType: ResponseType.text,
      wholeClass: true,
      subject: 'English',
      createdAt: DateTime(2026, 1, 18),
    ),
    Activity(
      id: 'a3',
      title: 'Recite Surah Al-Mulk',
      instructions: 'Record yourself reciting Surah Al-Mulk, verses 1-10.',
      responseType: ResponseType.video,
      wholeClass: false,
      assignedLearners: ['Arissa Humaira'],
      subject: 'Pendidikan Islam',
      createdAt: DateTime(2026, 1, 6),
    ),
  ];

  static final List<Submission> submissions = [
    Submission(activityId: 'a1', learnerName: 'Arissa Humaira'),
    Submission(activityId: 'a1', learnerName: 'Daniel Hakimi', submitted: true, submittedAt: DateTime(2026, 1, 22)),
    Submission(activityId: 'a1', learnerName: 'Nur Iman'),
    Submission(
      activityId: 'a2',
      learnerName: 'Arissa Humaira',
      submitted: true,
      textResponse: 'It was a rainy afternoon when Aiman found an old key hidden in his grandmother\'s attic...',
      submittedAt: DateTime(2026, 1, 19),
      graded: true,
      grade: '8/10',
      feedback: 'Great story structure! Try adding more descriptive vocabulary in the next draft.',
      gradedAt: DateTime(2026, 1, 20),
    ),
    Submission(activityId: 'a2', learnerName: 'Daniel Hakimi', submitted: true, submittedAt: DateTime(2026, 1, 20)),
    Submission(activityId: 'a2', learnerName: 'Nur Iman'),
    Submission(activityId: 'a3', learnerName: 'Arissa Humaira', submitted: true, submittedAt: DateTime(2026, 1, 7)),
  ];

  static String get classTag =>
      'Cambridge (${MockData.studentForm}) ${MockData.studentName.split(' ').first} (${MockData.studentId})';

  static final List<StoryPost> storyPosts = [
    StoryPost(
      id: 's1',
      teacherName: 'Ms. Husna Mazlan',
      classTag: classTag,
      date: DateTime(2026, 1, 26),
      body: 'Hi ${MockData.studentName.split(' ').first},\n\n'
          'This is the recorded link for Science class (25/1/2026). '
          'Please watch the video and comment the magic code below.',
      attachmentType: StoryAttachmentType.link,
      attachmentUrl: 'https://drive.google.com/file/d/example-science-recording/view',
      attachmentName: 'Science class recording — 25 Jan',
      likeCount: 2,
      comments: ['Noted, thank you cikgu!'],
    ),
    StoryPost(
      id: 's2',
      teacherName: 'Ms. Nabihah',
      classTag: classTag,
      date: DateTime(2026, 1, 22),
      body: 'Hi ${MockData.studentName.split(' ').first},\n\n'
          'Please download this worksheet, we will use it for our class today.\n\n'
          'Thank you.',
      attachmentType: StoryAttachmentType.file,
      attachmentName: 'Math_Worksheet_2.4.pdf',
      attachmentSizeLabel: '1.8 MB',
      likeCount: 1,
    ),
    StoryPost(
      id: 's3',
      teacherName: 'Ms. Fatini',
      classTag: classTag,
      date: DateTime(2026, 1, 20),
      body: 'Great participation in today\'s English class discussion! '
          'Keep practising your vocabulary for the upcoming essay.',
      likeCount: 4,
      comments: ['Thank you Ms. Fatini!', 'Looking forward to next class.'],
    ),
  ];

  static final List<ReportCard> reportCards = [
    ReportCard(
      termName: 'Mid-Year Examination 2026',
      issuedDate: DateTime(2026, 6, 5),
      classRank: 4,
      classSize: 28,
      attendanceRate: 0.96,
      teacherRemarks:
          'Arissa shows strong consistency across all subjects this term. Keep up the steady revision habits, '
          'and continue building confidence in Science problem-solving.',
      subjects: [
        SubjectGrade(subject: 'Mathematics', grade: 'A', score: 0.88, remarks: 'Solid grasp of algebra and patterns.'),
        SubjectGrade(subject: 'English', grade: 'A+', score: 0.94, remarks: 'Excellent essay structure and vocabulary.'),
        SubjectGrade(subject: 'Sains', grade: 'B+', score: 0.78, remarks: 'Needs more practice with lab reports.'),
        SubjectGrade(subject: 'Sejarah', grade: 'A', score: 0.85),
        SubjectGrade(subject: 'Bahasa Melayu', grade: 'A', score: 0.86),
        SubjectGrade(subject: 'Pendidikan Islam', grade: 'A+', score: 0.92),
      ],
    ),
    ReportCard(
      termName: 'Final-Term Examination 2025',
      issuedDate: DateTime(2025, 11, 28),
      classRank: 7,
      classSize: 28,
      attendanceRate: 0.93,
      teacherRemarks: 'A pleasing end to the year. Focus on Science vocabulary and timed-practice for the new term.',
      subjects: [
        SubjectGrade(subject: 'Mathematics', grade: 'A-', score: 0.83),
        SubjectGrade(subject: 'English', grade: 'A', score: 0.89),
        SubjectGrade(subject: 'Sains', grade: 'B', score: 0.74, remarks: 'Revise key terms before next assessment.'),
        SubjectGrade(subject: 'Sejarah', grade: 'A-', score: 0.81),
        SubjectGrade(subject: 'Bahasa Melayu', grade: 'A', score: 0.84),
        SubjectGrade(subject: 'Pendidikan Islam', grade: 'A', score: 0.88),
      ],
    ),
  ];

  static final List<AppNotification> studentNotifications = [
    AppNotification(
      title: 'Homework marked',
      body: '$teacherName marked your "Math worksheet 2.4" submission.',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.grade,
    ),
    AppNotification(
      title: 'New School Announcement',
      body: 'Peperiksaan Pertengahan Tahun — check School Announcement for details.',
      time: DateTime.now().subtract(const Duration(hours: 6)),
      type: NotificationType.announcement,
    ),
    AppNotification(
      title: 'Upcoming exam',
      body: 'Cambridge Final-Term Examination 2025/26 starts Aug 3.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.calendar,
      read: true,
    ),
    AppNotification(
      title: 'New message',
      body: 'New message in "$studentForm Cendekia — Class Group".',
      time: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.chat,
      read: true,
    ),
  ];

  static final List<AppNotification> teacherNotifications = [
    AppNotification(
      title: 'New submission',
      body: '$studentName submitted "Math worksheet 2.4".',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      type: NotificationType.homework,
    ),
    AppNotification(
      title: 'New message',
      body: 'Pn. Salmah replied in "$studentForm Cendekia — Class Group".',
      time: DateTime.now().subtract(const Duration(hours: 4)),
      type: NotificationType.chat,
    ),
    AppNotification(
      title: 'Homework pending',
      body: '2 students have not submitted "English Essay Draft" yet.',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.homework,
      read: true,
    ),
  ];
}
