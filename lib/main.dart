import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/role_select_screen.dart';

void main() {
  runApp(const IrAcademyApp());
}

class IrAcademyApp extends StatelessWidget {
  const IrAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IR Academy',
      theme: AppTheme.light,
      home: const RoleSelectScreen(),
    );
  }
}
