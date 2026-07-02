import '../models/activity.dart';
import '../models/apr_entry.dart';
import '../models/calendar_event.dart';
import '../models/chat_models.dart';
import '../models/app_notification.dart';
import '../models/learner.dart';
import '../models/report_card.dart';
import '../models/story_post.dart';

class MockData {
  MockData._();

  // ── current logged-in user (set at login) ────────────────────────────────
  static String currentUserName = '';
  static String currentUserRole = ''; // 'teacher' | 'student' | 'admin'
  static String currentUserForm = '';
  static String currentUserId = '';
  static String currentUserSyllabus = '';
  static String currentPortalUsername = '';
  static String currentPortalPassword = '';
  static String currentClassGroupLink = '';
  static String currentGoogleMeetLink = '';

  // Backward-compat getters used across screens
  static String get studentName => currentUserName;
  static String get teacherName => currentUserName;
  static String get studentForm => currentUserForm;
  static String get studentId => currentUserId;
  static String get studentSyllabus => currentUserSyllabus;
  static String get portalUsername => currentPortalUsername;
  static String get portalPassword => currentPortalPassword;
  static String get classGroupLink => currentClassGroupLink;
  static String get googleMeetLink => currentGoogleMeetLink;
  static String get schoolName => 'IR Academy';
  static const String adminName = 'IR Academy Admin';

  // ── user lists (loaded from app_users table) ─────────────────────────────
  static final List<Learner> learners = [];
  static final List<String> teacherNames = [];

  // Dynamic chat threads — built from real user lists
  static List<ChatThread> get studentChats => teacherNames
      .map((name) => ChatThread(
            title: name,
            subtitle: 'Teacher',
            lastMessage: '',
            timeLabel: '',
            contactName: name,
          ))
      .toList();

  static List<ChatThread> get teacherChats => learners
      .map((l) => ChatThread(
            title: '${l.name} (${l.form})',
            subtitle: 'Student',
            lastMessage: '',
            timeLabel: '',
            contactName: l.name,
          ))
      .toList();

  // ── school content (loaded from Supabase, start empty) ───────────────────
  static final List<AnnouncementPost> announcements = [];
  static final List<StoryPost> storyPosts = [];
  static final List<Activity> activities = [];
  static final List<Submission> submissions = [];
  static final List<AprEntry> aprEntries = [];
  static final List<ChatGroup> chatGroups = [];

  // ── calendar events (school-wide, can be managed from admin later) ────────
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

  // ── notifications (generated at runtime) ────────────────────────────────
  static final List<AppNotification> studentNotifications = [];
  static final List<AppNotification> teacherNotifications = [];

  // ── report cards (loaded per student from Supabase later) ────────────────
  static final List<ReportCard> reportCards = [];

  // ── helpers ──────────────────────────────────────────────────────────────
  static String get classTag => currentUserForm.isEmpty
      ? schoolName
      : '$currentUserForm — $currentUserName';
}
