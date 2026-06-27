import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../shared/widgets/more_menu.dart';
import 'screens/calendar_screen.dart';
import 'screens/class_chat_screen.dart';
import 'screens/report_card_screen.dart';
import 'screens/school_announcement_screen.dart';

class TeacherMoreScreen extends StatelessWidget {
  const TeacherMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MoreMenuScreen(items: [
      MoreMenuItem(label: 'School Announcement', icon: PhosphorIconsRegular.megaphone, screen: SchoolAnnouncementScreen()),
      MoreMenuItem(label: 'Calendar', icon: PhosphorIconsRegular.calendarBlank, screen: CalendarScreen()),
      MoreMenuItem(label: 'Report Card', icon: PhosphorIconsRegular.chartBar, screen: TeacherReportCardScreen()),
      MoreMenuItem(label: 'Class Chat', icon: PhosphorIconsRegular.chatCircleDots, screen: TeacherClassChatScreen()),
    ]);
  }
}
