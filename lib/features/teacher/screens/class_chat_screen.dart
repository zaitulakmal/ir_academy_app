import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../shared/widgets/chat_list_screen.dart';
import 'create_group_screen.dart';

class TeacherClassChatScreen extends StatefulWidget {
  const TeacherClassChatScreen({super.key});

  @override
  State<TeacherClassChatScreen> createState() => _TeacherClassChatScreenState();
}

class _TeacherClassChatScreenState extends State<TeacherClassChatScreen> {
  void _createGroup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateGroupScreen(
          onCreate: (group) => setState(() => MockData.chatGroups.add(group)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChatListScreen(
      title: 'Class Chat',
      threads: MockData.teacherChats,
      groups: MockData.chatGroups,
      currentUserName: MockData.teacherName,
      onCreateGroup: _createGroup,
    );
  }
}
