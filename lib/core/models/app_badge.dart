import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AppBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const AppBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const allBadges = [
  AppBadge(
    id: 'first_homework',
    title: 'First Steps',
    description: 'Submit your very first homework',
    icon: PhosphorIconsFill.footprints,
    color: Color(0xFF2F80ED),
  ),
  AppBadge(
    id: 'homework_5',
    title: 'Homework Hero',
    description: 'Submit 5 homeworks',
    icon: PhosphorIconsFill.medal,
    color: Color(0xFFEA3C12),
  ),
  AppBadge(
    id: 'all_caught_up',
    title: 'All Caught Up',
    description: 'Clear every pending homework',
    icon: PhosphorIconsFill.checkCircle,
    color: Color(0xFF28A745),
  ),
  AppBadge(
    id: 'excellent_3',
    title: 'Star Student',
    description: 'Earn "Excellent" 3 times in your APR',
    icon: PhosphorIconsFill.star,
    color: Color(0xFFFFC107),
  ),
  AppBadge(
    id: 'streak_3',
    title: 'Streak Starter',
    description: 'Open the app 3 days in a row',
    icon: PhosphorIconsFill.fire,
    color: Color(0xFFF2994A),
  ),
  AppBadge(
    id: 'streak_7',
    title: 'Streak Master',
    description: 'Open the app 7 days in a row',
    icon: PhosphorIconsFill.flame,
    color: Color(0xFFEA3C12),
  ),
];
