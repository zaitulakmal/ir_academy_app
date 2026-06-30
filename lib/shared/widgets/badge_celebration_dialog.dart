import 'package:flutter/material.dart';

import '../../core/models/app_badge.dart';
import '../../core/theme/app_colors.dart';

Future<void> showBadgeCelebration(BuildContext context, AppBadge badge) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Badge celebration',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (context, animation, secondaryAnimation) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final scale = Curves.elasticOut.transform(animation.value);
      return Opacity(
        opacity: animation.value.clamp(0, 1),
        child: Transform.scale(
          scale: scale,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(color: badge.color.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: Icon(badge.icon, color: badge.color, size: 44),
                  ),
                  const SizedBox(height: 16),
                  const Text('New Badge Unlocked! 🎉', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(badge.title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: badge.color)),
                  const SizedBox(height: 6),
                  Text(
                    badge.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Awesome!'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
