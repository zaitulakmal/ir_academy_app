import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'screens/apr_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/learners_record_screen.dart';
import 'teacher_more_screen.dart';

class TeacherShell extends StatefulWidget {
  const TeacherShell({super.key});

  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  int _index = 0;

  static const _screens = [
    TeacherDashboardScreen(),
    LearnersRecordScreen(),
    TeacherAprScreen(),
    TeacherMoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.squaresFour), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.usersThree), label: 'Learners'),
          BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.clipboardText), label: 'APR'),
          BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.dotsThreeCircle), label: 'More'),
        ],
      ),
    );
  }
}
