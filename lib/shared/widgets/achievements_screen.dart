import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/app_badge.dart';
import '../../core/theme/app_colors.dart';

class AchievementsScreen extends StatelessWidget {
  final int streak;
  final Set<String> earnedBadgeIds;

  const AchievementsScreen({super.key, required this.streak, required this.earnedBadgeIds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const Icon(PhosphorIconsFill.fire, color: Colors.white, size: 36),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$streak-day streak',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                    Text('${earnedBadgeIds.length} of ${allBadges.length} badges earned',
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Badges', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: allBadges.map((badge) {
              final earned = earnedBadgeIds.contains(badge.id);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: earned ? badge.color.withValues(alpha: 0.15) : AppColors.borderLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          badge.icon,
                          color: earned ? badge.color : AppColors.textSecondary.withValues(alpha: 0.4),
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        badge.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: earned ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badge.description,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
