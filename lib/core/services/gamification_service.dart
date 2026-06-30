import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_badge.dart';
import '../mock/mock_data.dart';

class StreakResult {
  final int streak;
  final bool isNewDay;

  const StreakResult({required this.streak, required this.isNewDay});
}

class GamificationService {
  GamificationService._();

  static const _kLastActiveDate = 'gamification.lastActiveDate';
  static const _kStreak = 'gamification.streak';
  static const _kEarnedBadges = 'gamification.earnedBadges';

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  static String _yesterday() {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return '${y.year}-${y.month}-${y.day}';
  }

  /// Call once per app session (e.g. Home screen init). Bumps the streak if
  /// today hasn't been recorded yet, resets it if a day was missed.
  static Future<StreakResult> recordActivityToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    final lastActive = prefs.getString(_kLastActiveDate);

    if (lastActive == today) {
      return StreakResult(streak: prefs.getInt(_kStreak) ?? 1, isNewDay: false);
    }

    final currentStreak = prefs.getInt(_kStreak) ?? 0;
    final newStreak = lastActive == _yesterday() ? currentStreak + 1 : 1;

    await prefs.setString(_kLastActiveDate, today);
    await prefs.setInt(_kStreak, newStreak);
    return StreakResult(streak: newStreak, isNewDay: true);
  }

  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kStreak) ?? 0;
  }

  static Future<Set<String>> getEarnedBadgeIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kEarnedBadges) ?? []).toSet();
  }

  /// Computes which badges are currently earned based on live app data + streak,
  /// persists any newly-earned ones, and returns the badges that were JUST earned
  /// (i.e. earned now but not before) so the UI can celebrate them.
  static Future<List<AppBadge>> evaluateNewBadges(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyEarned = (prefs.getStringList(_kEarnedBadges) ?? []).toSet();

    final submittedCount =
        MockData.submissions.where((s) => s.learnerName == MockData.studentName && s.submitted).length;
    final pending = MockData.activities
        .where((a) => a.wholeClass || a.assignedLearners.contains(MockData.studentName))
        .where((a) => !MockData.submissions
            .any((s) => s.activityId == a.id && s.learnerName == MockData.studentName && s.submitted))
        .length;
    final excellentCount = MockData.aprEntries
        .where((e) => e.learnerName == MockData.studentName && e.progress.name == 'excellent')
        .length;

    final qualifies = <String, bool>{
      'first_homework': submittedCount >= 1,
      'homework_5': submittedCount >= 5,
      'all_caught_up': submittedCount > 0 && pending == 0,
      'excellent_3': excellentCount >= 3,
      'streak_3': streak >= 3,
      'streak_7': streak >= 7,
    };

    final newlyEarned = <AppBadge>[];
    final updatedEarned = {...alreadyEarned};
    for (final badge in allBadges) {
      if (qualifies[badge.id] == true && !alreadyEarned.contains(badge.id)) {
        newlyEarned.add(badge);
        updatedEarned.add(badge.id);
      }
    }

    if (newlyEarned.isNotEmpty) {
      await prefs.setStringList(_kEarnedBadges, updatedEarned.toList());
    }
    return newlyEarned;
  }
}
