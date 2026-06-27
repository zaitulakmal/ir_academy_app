import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../shared/widgets/chat_list_screen.dart';

class TeacherClassChatScreen extends StatelessWidget {
  const TeacherClassChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChatListScreen(title: 'Class Chat', threads: MockData.teacherChats);
  }
}
