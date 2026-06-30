import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/models/chat_models.dart';
import '../../../core/models/learner.dart';

class CreateGroupScreen extends StatefulWidget {
  final void Function(ChatGroup group) onCreate;

  const CreateGroupScreen({super.key, required this.onCreate});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final Set<String> _selectedLearnerIds = {};
  bool _includeAdmin = true;

  List<Learner> get _filteredLearners {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return MockData.learners;
    return MockData.learners.where((l) => l.name.toLowerCase().contains(query)).toList();
  }

  void _create() {
    if (_nameController.text.trim().isEmpty || _selectedLearnerIds.isEmpty) return;
    final selectedLearners = MockData.learners.where((l) => _selectedLearnerIds.contains(l.id));
    final members = <ChatMember>[
      ChatMember(name: MockData.teacherName, role: ChatRole.teacher),
      if (_includeAdmin) const ChatMember(name: MockData.adminName, role: ChatRole.admin),
      for (final learner in selectedLearners) ...[
        ChatMember(name: learner.name, role: ChatRole.student),
        ChatMember(name: learner.parentName, role: ChatRole.parent),
      ],
    ];
    widget.onCreate(ChatGroup(
      id: 'cg${DateTime.now().microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      members: members,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Group')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Group name', hintText: 'e.g. Form 2 Cendekia Group'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Include School Admin', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: _includeAdmin,
                  onChanged: (v) => setState(() => _includeAdmin = v),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add students (${_selectedLearnerIds.length} selected — their parents are added automatically)',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search students...',
                    prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _filteredLearners.length,
              itemBuilder: (context, index) {
                final learner = _filteredLearners[index];
                final selected = _selectedLearnerIds.contains(learner.id);
                return CheckboxListTile(
                  value: selected,
                  title: Text(learner.name),
                  subtitle: Text('${learner.form} · Parent: ${learner.parentName}'),
                  onChanged: (v) => setState(() {
                    v == true ? _selectedLearnerIds.add(learner.id) : _selectedLearnerIds.remove(learner.id);
                  }),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nameController.text.trim().isNotEmpty && _selectedLearnerIds.isNotEmpty ? _create : null,
                  child: const Text('Create Group'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
