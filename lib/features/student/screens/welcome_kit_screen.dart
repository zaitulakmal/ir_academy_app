import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';

class _KitItem {
  final IconData icon;
  final String title;
  final String description;

  const _KitItem(this.icon, this.title, this.description);
}

class WelcomeKitScreen extends StatelessWidget {
  const WelcomeKitScreen({super.key});

  static const _items = [
    _KitItem(PhosphorIconsFill.bookOpenText, 'Curriculum Overview',
        'KSSM-aligned subjects with Cambridge English enrichment.'),
    _KitItem(PhosphorIconsFill.calendarCheck, 'Class Schedule',
        'Weekly timetable and term dates — check Calendar for updates.'),
    _KitItem(PhosphorIconsFill.usersThree, 'Mirai Club',
        'Co-curricular activities and clubs available this term.'),
    _KitItem(PhosphorIconsFill.phoneCall, 'Need Help?',
        'Reach your class teacher directly via Class Chat.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome Kit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome to IR Academy! 🎉',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text('Online School · Cambridge English · Mirai Club',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ..._items.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Icon(item.icon, color: AppColors.primary, size: 20),
                  ),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(item.description),
                ),
              )),
        ],
      ),
    );
  }
}
