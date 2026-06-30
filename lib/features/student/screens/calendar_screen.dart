import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/calendar_event.dart';
import '../../../core/theme/app_colors.dart';

const _months = [
  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
];

class StudentCalendarScreen extends StatefulWidget {
  const StudentCalendarScreen({super.key});

  @override
  State<StudentCalendarScreen> createState() => _StudentCalendarScreenState();
}

class _StudentCalendarScreenState extends State<StudentCalendarScreen> {
  String _formatRange(CalendarEvent event) {
    String fmt(DateTime d) => '${d.day} ${_months[d.month - 1].substring(0, 1)}${_months[d.month - 1].substring(1).toLowerCase()}';
    if (!event.isMultiDay) return fmt(event.startDate);
    return '${fmt(event.startDate)}–${fmt(event.endDate)}';
  }

  void _openDetail(CalendarEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(_formatRange(event), style: const TextStyle(color: AppColors.textSecondary)),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(event.description),
                ],
                if (event.signupSlots.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Sign-ups', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ...event.signupSlots.map((slot) {
                    final signedUp = slot.signedUpNames.contains(MockData.studentName);
                    final full = slot.signedUpNames.length >= slot.capacity;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('${slot.label} (${slot.signedUpNames.length}/${slot.capacity})'),
                          ),
                          TextButton(
                            onPressed: signedUp
                                ? () => setSheetState(() => slot.signedUpNames.remove(MockData.studentName))
                                : full
                                    ? null
                                    : () => setSheetState(() => slot.signedUpNames.add(MockData.studentName)),
                            child: Text(signedUp ? 'Cancel' : full ? 'Full' : 'Sign Up'),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...MockData.calendarEvents]..sort((a, b) => a.startDate.compareTo(b.startDate));

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: sorted.isEmpty
          ? const Center(child: Text('No events yet.', style: TextStyle(color: AppColors.textSecondary)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('On the horizon', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 12),
                ...sorted.map((event) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        onTap: () => _openDetail(event),
                        leading: Container(
                          width: 48,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(event.startDate.day.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
                              Text(_months[event.startDate.month - 1],
                                  style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        title: Text(
                          (event.isMultiDay ? 'MULTI-DAY · ' : '') + event.category.toUpperCase(),
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text(_formatRange(event), style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        isThreeLine: true,
                      ),
                    )),
              ],
            ),
    );
  }
}
