import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../shared/utils/logout.dart';
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
    return MoreMenuScreen(items: [
      const MoreMenuItem(label: 'Homework', icon: PhosphorIconsRegular.notebook, screen: HomeworkScreen()),
      const MoreMenuItem(label: 'Calendar', icon: PhosphorIconsRegular.calendarBlank, screen: StudentCalendarScreen()),
      const MoreMenuItem(
        label: 'School Announcement',
        icon: PhosphorIconsRegular.megaphone,
        screen: StudentSchoolAnnouncementScreen(),
      ),
      const MoreMenuItem(label: 'Report Card', icon: PhosphorIconsRegular.chartBar, screen: ReportCardScreen()),
      const MoreMenuItem(label: 'Class Chat', icon: PhosphorIconsRegular.chatCircleDots, screen: StudentClassChatScreen()),
      const MoreMenuItem(
        label: 'Welcome Kit',
        icon: PhosphorIconsRegular.gift,
        url: 'https://iracademyeducation.com/welcomekit',
      ),
      MoreMenuItem(
        label: 'Log Out',
        icon: PhosphorIconsRegular.signOut,
        color: Colors.red,
        onTap: () => logout(context),
      ),
    ]);
  }
}
