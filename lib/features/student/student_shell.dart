import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'screens/apr_screen.dart';
import 'screens/class_update_screen.dart';
import 'screens/home_screen.dart';
import 'student_more_screen.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  static const _screens = [
    StudentHomeScreen(),
    ClassUpdateScreen(),
    StudentAprScreen(),
    StudentMoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.house), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.newspaper), label: 'Class Update'),
          BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.clipboardText), label: 'APR'),
          BottomNavigationBarItem(icon: Icon(PhosphorIconsRegular.squaresFour), label: 'More'),
        ],
      ),
    );
  }
}
