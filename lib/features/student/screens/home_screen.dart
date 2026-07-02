import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/activity.dart';
import '../../../core/models/calendar_event.dart';
import '../../../core/services/gamification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/achievements_screen.dart';
import '../../../shared/widgets/badge_celebration_dialog.dart';
import '../../../shared/widgets/notifications_screen.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/story_post_card.dart';
import '../../../shared/widgets/streak_badge_banner.dart';
import '../../../shared/widgets/student_info_card.dart';
import 'activity_detail_screen.dart';
import 'calendar_screen.dart';
import 'class_update_screen.dart';
import 'school_announcement_screen.dart';

const _months = [
  'JANUARY',
  'FEBRUARY',
  'MARCH',
  'APRIL',
  'MAY',
  'JUNE',
  'JULY',
  'AUGUST',
  'SEPTEMBER',
  'OCTOBER',
  'NOVEMBER',
  'DECEMBER',
];
const _weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  List<Activity> get _myActivities => MockData.activities
      .where((a) => a.wholeClass || a.assignedLearners.contains(MockData.studentName))
      .toList();
  List<Submission> get _submissions => MockData.submissions;
  int _streak = 0;
  Set<String> _earnedBadgeIds = {};

  @override
  void initState() {
    super.initState();
    _initGamification();
  }

  Future<void> _initGamification() async {
    final result = await GamificationService.recordActivityToday();
    final newBadges = await GamificationService.evaluateNewBadges(result.streak);
    final earned = await GamificationService.getEarnedBadgeIds();
    if (!mounted) return;
    setState(() {
      _streak = result.streak;
      _earnedBadgeIds = earned;
    });
    for (final badge in newBadges) {
      if (!mounted) return;
      await showBadgeCelebration(context, badge);
    }
  }

  Submission _submissionFor(String activityId) => _submissions.firstWhere(
    (s) => s.activityId == activityId && s.learnerName == MockData.studentName,
  );

  Map<String, List<CalendarEvent>> _groupByMonth(List<CalendarEvent> events) {
    final grouped = <String, List<CalendarEvent>>{};
    for (final event in events) {
      grouped
          .putIfAbsent(_months[event.startDate.month - 1], () => [])
          .add(event);
    }
    return grouped;
  }

  String _formatEventRange(CalendarEvent event) {
    String titleCase(String s) => '${s[0]}${s.substring(1).toLowerCase()}';
    String fmt(DateTime d) =>
        '${d.day} ${titleCase(_months[d.month - 1].substring(0, 3))}';
    if (!event.isMultiDay) return fmt(event.startDate);
    return '${fmt(event.startDate)}–${fmt(event.endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final latestPosts = MockData.storyPosts
        .where((p) => p.wholeClass || p.assignedLearners.contains(MockData.studentName))
        .toList();
    final pendingHomework = _myActivities
        .where((a) => !_submissionFor(a.id).submitted)
        .toList();
    final upcomingEvents = [...MockData.calendarEvents]
      ..sort((a, b) => a.startDate.compareTo(b.startDate))
      ..removeWhere((e) => e.endDate.isBefore(DateTime.now()));
    final upcomingPreview = upcomingEvents.take(3).toList();
    final latestAnnouncements = MockData.announcements.take(2).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              PhosphorIconsFill.graduationCap,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            const Text('IR Academy'),
          ],
        ),
        actions: [
          NotificationBellButton(notifications: MockData.studentNotifications),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, ${MockData.studentName.split(' ').first}! 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            MockData.studentForm,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        PhosphorIconsFill.smiley,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          StreakBadgeBanner(
            streak: _streak,
            earnedBadgeIds: _earnedBadgeIds,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AchievementsScreen(streak: _streak, earnedBadgeIds: _earnedBadgeIds),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const StudentInfoCard(),
          const SizedBox(height: 24),
          SectionHeader(title: 'To-Do · Homework (${pendingHomework.length})'),
          const SizedBox(height: 8),
          if (pendingHomework.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No pending homework. Great job!',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...pendingHomework.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StudentActivityDetailScreen(
                          activity: a,
                          submission: _submissionFor(a.id),
                          onSubmitted: (_) => setState(() {}),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              PhosphorIconsFill.clock,
                              color: AppColors.warning,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  a.subject ?? 'General',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            PhosphorIconsBold.caretRight,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Upcoming',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StudentCalendarScreen(),
                          ),
                        ),
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                  if (upcomingPreview.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No upcoming events.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ..._groupByMonth(upcomingPreview).entries.expand(
                      (monthEntry) => [
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Text(
                            monthEntry.key,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ...monthEntry.value.map(
                          (event) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.borderLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 44,
                                    child: Column(
                                      children: [
                                        Text(
                                          event.startDate.day.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          _weekdays[event.startDate.weekday -
                                              1],
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatEventRange(event),
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'School Announcement',
            actionLabel: 'View all',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const StudentSchoolAnnouncementScreen(),
              ),
            ),
          ),
          if (latestAnnouncements.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No announcements yet.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            ...latestAnnouncements.map(
              (post) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                              child: const Icon(PhosphorIconsFill.megaphone, color: AppColors.accent, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                post.author,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              post.timeLabel,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          post.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Latest Class Update',
            actionLabel: 'View all',
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ClassUpdateScreen()),
            ),
          ),
          ...latestPosts.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StoryPostCard(post: entry.value, colorIndex: entry.key),
            ),
          ),
        ],
      ),
    );
  }
}
