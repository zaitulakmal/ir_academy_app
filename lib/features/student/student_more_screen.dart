import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../shared/widgets/more_menu.dart';
import 'screens/calendar_screen.dart';
import 'screens/homework_screen.dart';
import 'screens/report_card_screen.dart';
import 'screens/class_chat_screen.dart';
import 'screens/school_announcement_screen.dart';

class StudentMoreScreen extends StatelessWidget {
  const StudentMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MoreMenuScreen(items: [
      MoreMenuItem(label: 'Homework', icon: PhosphorIconsRegular.notebook, screen: HomeworkScreen()),
      MoreMenuItem(label: 'Calendar', icon: PhosphorIconsRegular.calendarBlank, screen: StudentCalendarScreen()),
      MoreMenuItem(
        label: 'School Announcement',
        icon: PhosphorIconsRegular.megaphone,
        screen: StudentSchoolAnnouncementScreen(),
      ),
      MoreMenuItem(label: 'Report Card', icon: PhosphorIconsRegular.chartBar, screen: ReportCardScreen()),
      MoreMenuItem(label: 'Class Chat', icon: PhosphorIconsRegular.chatCircleDots, screen: StudentClassChatScreen()),
      MoreMenuItem(
        label: 'Welcome Kit',
        icon: PhosphorIconsRegular.gift,
        url: 'https://iracademyeducation.com/welcomekit',
      ),
    ]);
  }
}
