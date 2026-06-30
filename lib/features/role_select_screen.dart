import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'student/student_shell.dart';
import 'teacher/teacher_shell.dart';

/// Temporary entry point standing in for real login until auth is wired up.
/// Lets us preview both role experiences during development.
class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 280, fit: BoxFit.contain),
              const SizedBox(height: 16),
              const Text('Choose a role to preview', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StudentShell()),
                  ),
                  child: const Text('Continue as Student'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TeacherShell()),
                  ),
                  child: const Text('Continue as Teacher'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
