import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../shared/widgets/chat_list_screen.dart';

class StudentClassChatScreen extends StatelessWidget {
  const StudentClassChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChatListScreen(
      title: 'Class Chat',
      threads: MockData.studentChats,
      groups: MockData.chatGroups,
      currentUserName: MockData.studentName,
    );
  }
}
