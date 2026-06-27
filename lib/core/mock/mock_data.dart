import '../models/activity.dart';
import '../models/apr_entry.dart';
import '../models/chat_models.dart';
import '../models/learner.dart';
import '../models/story_post.dart';

/// Placeholder data standing in for the real backend until Supabase is wired up.
class MockData {
  MockData._();

  static final studentName = 'Arissa Humaira';
  static final studentForm = 'Form 2';
  static final studentId = 'IRA-2026-0142';
  static final studentSyllabus = 'KSSM + Cambridge English';
  static final portalUsername = 'arissa.humaira';
  static final portalPassword = 'IrAcademy@2026';
  static final classGroupLink = 'https://chat.whatsapp.com/example-form2-group';
  static final googleMeetLink = 'https://meet.google.com/example-code';

  static final List<AprEntry> aprEntries = [
    AprEntry(
      date: DateTime(2026, 1, 20),
      subject: 'Mathematics',
      topicCovered: '1.3 Patterns & Sequences',
      progress: ProgressLevel.good,
      homeworkAssigned: 'Workbook pg. 12-14, Q1-10',
      homeworkDone: false,
      observations: 'Solves problems independently, confident with the topic.',
      followUpAction: '2.1 Expansion',
    ),
    AprEntry(
      date: DateTime(2026, 1, 18),
      subject: 'English',
      topicCovered: 'Essay structure: narrative writing',
      progress: ProgressLevel.excellent,
      homeworkAssigned: 'Write a 150-word narrative essay',
      homeworkDone: true,
      observations: 'Strong vocabulary, good story flow.',
      followUpAction: 'Persuasive writing techniques',
    ),
    AprEntry(
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

  static final List<Learner> learners = const [
    Learner(name: 'Arissa Humaira', form: 'Form 2', parentName: 'Pn. Salmah', attendanceRate: 0.96),
    Learner(name: 'Daniel Hakimi', form: 'Form 2', parentName: 'En. Rashid', attendanceRate: 0.88),
    Learner(name: 'Nur Iman', form: 'Form 1', parentName: 'Pn. Aishah', attendanceRate: 0.92),
  ];

  static final List<AnnouncementPost> announcements = const [
    AnnouncementPost(
      title: 'Cuti sempena Hari Wesak',
      body: 'Tiada kelas pada 1 Mei. Kelas akan disambung seperti biasa pada 3 Mei.',
      author: 'IR Academy Admin',
      timeLabel: '2d ago',
    ),
    AnnouncementPost(
      title: 'Peperiksaan Pertengahan Tahun',
      body: 'Jadual peperiksaan akan dimuat naik minggu depan. Sila semak Calendar.',
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
    ),
    Submission(activityId: 'a2', learnerName: 'Daniel Hakimi', submitted: true, submittedAt: DateTime(2026, 1, 20)),
    Submission(activityId: 'a2', learnerName: 'Nur Iman'),
    Submission(activityId: 'a3', learnerName: 'Arissa Humaira', submitted: true, submittedAt: DateTime(2026, 1, 7)),
  ];

  static String get _classTag =>
      'Cambridge (${MockData.studentForm}) ${MockData.studentName.split(' ').first} (${MockData.studentId})';

  static final List<StoryPost> storyPosts = [
    StoryPost(
      id: 's1',
      teacherName: 'Ms. Husna Mazlan',
      classTag: _classTag,
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
      classTag: _classTag,
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
      classTag: _classTag,
      date: DateTime(2026, 1, 20),
      body: 'Great participation in today\'s English class discussion! '
          'Keep practising your vocabulary for the upcoming essay.',
      likeCount: 4,
      comments: ['Thank you Ms. Fatini!', 'Looking forward to next class.'],
    ),
  ];
}
