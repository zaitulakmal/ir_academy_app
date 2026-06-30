import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/calendar_event.dart';
import '../../../core/theme/app_colors.dart';
import 'edit_calendar_event_screen.dart';

const _months = [
  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
];

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final List<CalendarEvent> _events = MockData.calendarEvents;

  String _formatRange(CalendarEvent event) {
    String fmt(DateTime d) => '${d.day} ${_months[d.month - 1].substring(0, 1)}${_months[d.month - 1].substring(1).toLowerCase()}';
    if (!event.isMultiDay) return fmt(event.startDate);
    return '${fmt(event.startDate)}–${fmt(event.endDate)}';
  }

  void _openEditor({CalendarEvent? event}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditCalendarEventScreen(
          event: event,
          onSave: (saved) => setState(() {
            final index = _events.indexWhere((e) => e.id == saved.id);
            if (index == -1) {
              _events.add(saved);
            } else {
              _events[index] = saved;
            }
            _events.sort((a, b) => a.startDate.compareTo(b.startDate));
          }),
          onDelete: (toDelete) => setState(() => _events.removeWhere((e) => e.id == toDelete.id)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [..._events]..sort((a, b) => a.startDate.compareTo(b.startDate));

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _openEditor(),
        child: const Icon(PhosphorIconsBold.plus, color: Colors.white),
      ),
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
                        onTap: () => _openEditor(event: event),
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
                        trailing: IconButton(
                          icon: const Icon(PhosphorIconsRegular.pencilSimple, size: 18),
                          onPressed: () => _openEditor(event: event),
                        ),
                      ),
                    )),
              ],
            ),
    );
  }
}
