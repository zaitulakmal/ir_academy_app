class SignupSlot {
  String label;
  int capacity;
  final List<String> signedUpNames;

  SignupSlot({required this.label, required this.capacity, List<String>? signedUpNames})
      : signedUpNames = signedUpNames ?? [];
}

class CalendarEvent {
  final String id;
  String title;
  String description;
  bool allDay;
  DateTime startDate;
  DateTime endDate;
  String category;
  List<SignupSlot> signupSlots;
  bool remindSendNow;
  bool remindFiveDaysBefore;
  bool remindOneDayBefore;
  bool remindOnThatDay;

  CalendarEvent({
    required this.id,
    required this.title,
    this.description = '',
    this.allDay = true,
    required this.startDate,
    required this.endDate,
    this.category = 'School Event',
    List<SignupSlot>? signupSlots,
    this.remindSendNow = true,
    this.remindFiveDaysBefore = true,
    this.remindOneDayBefore = true,
    this.remindOnThatDay = true,
  }) : signupSlots = signupSlots ?? [];

  bool get isMultiDay =>
      startDate.year != endDate.year || startDate.month != endDate.month || startDate.day != endDate.day;
}
