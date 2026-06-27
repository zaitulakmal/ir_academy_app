import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';

class _AgendaItem {
  final String date;
  final String title;
  final String time;

  const _AgendaItem(this.date, this.title, this.time);
}

/// Simple agenda placeholder — swap for a full month grid (e.g. table_calendar)
/// once we confirm the scheduling requirements.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  static const _items = [
    _AgendaItem('Mon, 2 Feb', 'Mathematics — Form 2', '9:00 AM'),
    _AgendaItem('Mon, 2 Feb', 'English — Form 2', '11:00 AM'),
    _AgendaItem('Tue, 3 Feb', 'Sains — Form 1', '9:00 AM'),
    _AgendaItem('Thu, 5 Feb', 'Mid-term Exam Briefing', '2:00 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(PhosphorIconsFill.calendarBlank, color: Colors.white, size: 18),
              ),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${item.date} · ${item.time}'),
            ),
          );
        },
      ),
    );
  }
}
