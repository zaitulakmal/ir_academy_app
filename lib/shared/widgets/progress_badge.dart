import 'package:flutter/material.dart';

import '../../core/models/apr_entry.dart';
import '../../core/theme/app_colors.dart';

class ProgressBadge extends StatelessWidget {
  final ProgressLevel level;

  const ProgressBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (level) {
      ProgressLevel.excellent => (AppColors.success, 'Excellent'),
      ProgressLevel.good => (AppColors.primary, 'Good'),
      ProgressLevel.needsSupport => (AppColors.warning, 'Needs Support'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
