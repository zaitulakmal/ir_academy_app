import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/models/calendar_event.dart';
import '../../../core/theme/app_colors.dart';

const _categories = ['School Event', 'Examination', 'Holiday', 'Class Schedule'];

class EditCalendarEventScreen extends StatefulWidget {
  final CalendarEvent? event;
  final void Function(CalendarEvent event) onSave;
  final void Function(CalendarEvent event)? onDelete;

  const EditCalendarEventScreen({super.key, this.event, required this.onSave, this.onDelete});

  @override
  State<EditCalendarEventScreen> createState() => _EditCalendarEventScreenState();
}

class _EditCalendarEventScreenState extends State<EditCalendarEventScreen> {
  late final TextEditingController _titleController = TextEditingController(text: widget.event?.title ?? '');
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.event?.description ?? '');
  late bool _allDay = widget.event?.allDay ?? true;
  late DateTime _startDate = widget.event?.startDate ?? DateTime.now();
  late DateTime _endDate = widget.event?.endDate ?? DateTime.now();
  late String _category = widget.event?.category ?? _categories.first;
  late final List<SignupSlot> _slots = widget.event?.signupSlots
          .map((s) => SignupSlot(label: s.label, capacity: s.capacity, signedUpNames: [...s.signedUpNames]))
          .toList() ??
      [];
  late bool _remindSendNow = widget.event?.remindSendNow ?? true;
  late bool _remindFiveDaysBefore = widget.event?.remindFiveDaysBefore ?? true;
  late bool _remindOneDayBefore = widget.event?.remindOneDayBefore ?? true;
  late bool _remindOnThatDay = widget.event?.remindOnThatDay ?? true;

  bool get _isEditing => widget.event != null;

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
      } else {
        _endDate = picked.isBefore(_startDate) ? _startDate : picked;
      }
    });
  }

  void _addSlot() {
    setState(() => _slots.add(SignupSlot(label: '', capacity: 1)));
  }

  void _removeSlot(int index) => setState(() => _slots.removeAt(index));

  void _save() {
    if (_titleController.text.trim().isEmpty) return;
    final event = CalendarEvent(
      id: widget.event?.id ?? 'ev${DateTime.now().microsecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      allDay: _allDay,
      startDate: _startDate,
      endDate: _endDate,
      category: _category,
      signupSlots: _slots.where((s) => s.label.trim().isNotEmpty).toList(),
      remindSendNow: _remindSendNow,
      remindFiveDaysBefore: _remindFiveDaysBefore,
      remindOneDayBefore: _remindOneDayBefore,
      remindOnThatDay: _remindOnThatDay,
    );
    widget.onSave(event);
    Navigator.of(context).pop();
  }

  void _delete() {
    if (widget.event != null) widget.onDelete?.call(widget.event!);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit event' : 'New event'),
        actions: [TextButton(onPressed: _save, child: const Text('Update'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Title', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(controller: _titleController, decoration: const InputDecoration(hintText: 'Event title')),
          const SizedBox(height: 16),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Event description'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (value) => setState(() => _category = value ?? _category),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Text('All day', style: TextStyle(fontWeight: FontWeight.w700))),
              Switch(value: _allDay, onChanged: (v) => setState(() => _allDay = v)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickDate(isStart: true),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Start date'),
                    child: Text(_formatDate(_startDate)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickDate(isStart: false),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'End date'),
                    child: Text(_formatDate(_endDate)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Sign-ups', style: TextStyle(fontWeight: FontWeight.w700)),
          const Text('Create spots for conference, volunteers, supplies, etc.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 10),
          ..._slots.asMap().entries.map((entry) {
            final index = entry.key;
            final slot = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      initialValue: slot.label,
                      decoration: const InputDecoration(labelText: 'Spot label'),
                      onChanged: (v) => slot.label = v,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: slot.capacity.toString(),
                      decoration: const InputDecoration(labelText: 'Slots'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => slot.capacity = int.tryParse(v) ?? slot.capacity,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsBold.x, size: 18),
                    onPressed: () => _removeSlot(index),
                  ),
                ],
              ),
            );
          }),
          OutlinedButton.icon(
            onPressed: _addSlot,
            icon: const Icon(PhosphorIconsBold.plus),
            label: const Text('Add spot'),
          ),
          const SizedBox(height: 24),
          const Text('Reminders', style: TextStyle(fontWeight: FontWeight.w700)),
          const Text('Send notifications to families automatically',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Send now'),
            value: _remindSendNow,
            onChanged: (v) => setState(() => _remindSendNow = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('5 days before'),
            value: _remindFiveDaysBefore,
            onChanged: (v) => setState(() => _remindFiveDaysBefore = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('1 day before'),
            value: _remindOneDayBefore,
            onChanged: (v) => setState(() => _remindOneDayBefore = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('On that day'),
            value: _remindOnThatDay,
            onChanged: (v) => setState(() => _remindOnThatDay = v),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (_isEditing) ...[
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                    onPressed: _delete,
                    child: const Text('Delete'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(_isEditing ? 'Update' : 'Create'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
