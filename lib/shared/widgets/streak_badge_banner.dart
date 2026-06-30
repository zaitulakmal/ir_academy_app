import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/app_badge.dart';
import '../../core/theme/app_colors.dart';

class StreakBadgeBanner extends StatelessWidget {
  final int streak;
  final Set<String> earnedBadgeIds;
  final VoidCallback onTap;

  const StreakBadgeBanner({super.key, required this.streak, required this.earnedBadgeIds, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: const Icon(PhosphorIconsFill.fire, color: AppColors.accent, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$streak-day streak', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        Text(
                          streak > 0 ? 'Keep it going!' : 'Open the app daily to start a streak',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(PhosphorIconsBold.caretRight, size: 16, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: allBadges.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final badge = allBadges[index];
                    final earned = earnedBadgeIds.contains(badge.id);
                    return Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: earned ? badge.color.withValues(alpha: 0.15) : AppColors.borderLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        badge.icon,
                        color: earned ? badge.color : AppColors.textSecondary.withValues(alpha: 0.4),
                        size: 22,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
