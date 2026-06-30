import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/mock/mock_data.dart';
import '../../core/models/chat_models.dart';
import '../../core/theme/app_colors.dart';

const _roleOrder = [ChatRole.teacher, ChatRole.admin, ChatRole.parent, ChatRole.student];

(Color, IconData) _roleStyle(ChatRole role) {
  switch (role) {
    case ChatRole.teacher:
      return (AppColors.primary, PhosphorIconsFill.chalkboardTeacher);
    case ChatRole.admin:
      return (AppColors.accent, PhosphorIconsFill.shieldCheck);
    case ChatRole.parent:
      return (AppColors.success, PhosphorIconsFill.house);
    case ChatRole.student:
      return (AppColors.warning, PhosphorIconsFill.student);
  }
}

class GroupInfoScreen extends StatefulWidget {
  final ChatGroup group;
  final String currentUserName;

  const GroupInfoScreen({super.key, required this.group, required this.currentUserName});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  bool _left = false;

  bool get _isTeacher => widget.currentUserName == MockData.teacherName;

  Future<void> _openAddMembers() async {
    final memberNames = widget.group.members.map((m) => m.name).toSet();
    final available = MockData.learners.where((l) => !memberNames.contains(l.name)).toList();
    final selected = <String>{};
    final searchController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final query = searchController.text.trim().toLowerCase();
          final filtered =
              query.isEmpty ? available : available.where((l) => l.name.toLowerCase().contains(query)).toList();
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Students', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Their parent will be added automatically.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search students...',
                      prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass),
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text('No students to add.', style: TextStyle(color: AppColors.textSecondary)))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final learner = filtered[index];
                              final isSelected = selected.contains(learner.id);
                              return CheckboxListTile(
                                value: isSelected,
                                title: Text(learner.name),
                                subtitle: Text('${learner.form} · Parent: ${learner.parentName}'),
                                onChanged: (v) => setSheetState(() {
                                  v == true ? selected.add(learner.id) : selected.remove(learner.id);
                                }),
                              );
                            },
                          ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selected.isEmpty
                          ? null
                          : () {
                              setState(() {
                                for (final learner in available.where((l) => selected.contains(l.id))) {
                                  widget.group.members.add(ChatMember(name: learner.name, role: ChatRole.student));
                                  if (!memberNames.contains(learner.parentName)) {
                                    widget.group.members.add(ChatMember(name: learner.parentName, role: ChatRole.parent));
                                  }
                                }
                              });
                              Navigator.of(context).pop();
                            },
                      child: Text('Add ${selected.isEmpty ? '' : '(${selected.length}) '}to Group'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmLeave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave group?'),
        content: Text('You will no longer receive messages from "${widget.group.name}".'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      widget.group.members.removeWhere((m) => m.name == widget.currentUserName);
      _left = true;
    });
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isMember = !_left && widget.group.members.any((m) => m.name == widget.currentUserName);
    final sortedMembers = [...widget.group.members]
      ..sort((a, b) => _roleOrder.indexOf(a.role).compareTo(_roleOrder.indexOf(b.role)));

    return Scaffold(
      appBar: AppBar(title: const Text('Group Info')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(PhosphorIconsFill.usersThree, color: AppColors.accent, size: 36),
                ),
                const SizedBox(height: 12),
                Text(widget.group.name,
                    textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 4),
                Text('${widget.group.members.length} members',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Members', style: TextStyle(fontWeight: FontWeight.w700)),
              if (_isTeacher)
                TextButton.icon(
                  onPressed: _openAddMembers,
                  icon: const Icon(PhosphorIconsBold.userPlus, size: 16),
                  label: const Text('Add'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...sortedMembers.map((member) {
            final (color, icon) = _roleStyle(member.role);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(icon, color: color, size: 18),
                ),
                title: Text(
                  member.name == widget.currentUserName ? '${member.name} (You)' : member.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(chatRoleLabel(member.role), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
            );
          }),
          if (isMember) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmLeave,
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                icon: const Icon(PhosphorIconsRegular.signOut),
                label: const Text('Leave Group'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
