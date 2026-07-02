import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../features/role_select_screen.dart';

Future<void> logout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Log Out'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log Out')),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  MockData.currentUserName = '';
  MockData.currentUserRole = '';
  MockData.currentUserForm = '';
  MockData.currentUserId = '';
  MockData.currentUserSyllabus = '';
  MockData.currentPortalUsername = '';
  MockData.currentPortalPassword = '';
  MockData.currentClassGroupLink = '';
  MockData.currentGoogleMeetLink = '';

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
    (route) => false,
  );
}
