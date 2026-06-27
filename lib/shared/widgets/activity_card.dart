import 'package:flutter/material.dart';

import '../../core/models/activity.dart';
import '../../core/theme/app_colors.dart';
import 'create_activity_sheet.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final Widget trailing;
  final VoidCallback? onTap;

  const ActivityCard({super.key, required this.activity, required this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(responseTypeIcon(activity.responseType), color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      '${activity.subject ?? 'General'} · ${responseTypeLabel(activity.responseType)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
