import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../core/mock/mock_data.dart';
import '../core/services/firebase_service.dart';
import '../core/theme/app_colors.dart';
import 'student/student_shell.dart';
import 'teacher/teacher_shell.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String? _role; // 'student' | 'teacher'
  final _nameController = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _login() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() { _loading = true; _error = null; });

    final user = await FirebaseService.lookupUser(name);

    if (!mounted) return;

    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'Name not found. Please contact the admin.';
      });
      return;
    }

    final role = user['role'] as String;
    MockData.currentUserName = user['name'] as String;
    MockData.currentUserRole = role;
    MockData.currentUserForm = user['form'] as String? ?? '';
    MockData.currentUserId = user['id'] as String;
    MockData.currentUserSyllabus = user['syllabus'] as String? ?? '';
    MockData.currentPortalUsername = user['portal_username'] as String? ?? '';
    MockData.currentPortalPassword = user['portal_password'] as String? ?? '';
    MockData.currentClassGroupLink = user['class_group_link'] as String? ?? '';
    MockData.currentGoogleMeetLink = user['google_meet_link'] as String? ?? '';

    // Load all school data now that we know who's logged in
    try {
      await FirebaseService.loadAll();
    } catch (_) {}

    if (!mounted) return;

    final dest = (role == 'teacher' || role == 'admin')
        ? const TeacherShell()
        : const StudentShell();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => dest),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset('assets/images/logo.png', width: 220, fit: BoxFit.contain),
              ),
              const SizedBox(height: 40),

              // Role picker
              if (_role == null) ...[
                const Text('Log In', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Choose your role', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text(
                  '${MockData.learners.length} students · ${MockData.teacherNames.length} teachers loaded',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 20),
                _RoleCard(
                  icon: PhosphorIconsFill.student,
                  label: 'Student',
                  onTap: () => setState(() => _role = 'student'),
                ),
                const SizedBox(height: 14),
                _RoleCard(
                  icon: PhosphorIconsFill.chalkboardTeacher,
                  label: 'Teacher',
                  onTap: () => setState(() => _role = 'teacher'),
                ),
              ] else ...[
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() { _role = null; _error = null; _nameController.clear(); }),
                      child: const Icon(PhosphorIconsBold.arrowLeft, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _role == 'student' ? 'Log in as Student' : 'Log in as Teacher',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Search + autocomplete
                Autocomplete<String>(
                  optionsBuilder: (textEditingValue) {
                    final q = textEditingValue.text.trim().toLowerCase();
                    final names = _role == 'student'
                        ? MockData.learners.map((l) => l.name).toList()
                        : MockData.teacherNames;
                    if (q.isEmpty) return names;
                    return names.where((n) => n.toLowerCase().contains(q)).toList();
                  },
                  onSelected: (val) {
                    _nameController.text = val;
                    setState(() {});
                  },
                  fieldViewBuilder: (ctx, ctrl, focusNode, onSubmit) {
                    // keep our controller in sync
                    ctrl.addListener(() {
                      if (_nameController.text != ctrl.text) {
                        _nameController.text = ctrl.text;
                        setState(() => _error = null);
                      }
                    });
                    return TextField(
                      controller: ctrl,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Full name',
                        hintText: _role == 'student' ? 'e.g. Ahmad bin Hassan' : 'e.g. Cikgu Aiman',
                        prefixIcon: const Icon(PhosphorIconsRegular.user),
                        errorText: _error,
                      ),
                      onSubmitted: (_) => _login(),
                    );
                  },
                  optionsViewBuilder: (ctx, onSelected, options) => Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(10),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (_, i) {
                            final name = options.elementAt(i);
                            return ListTile(
                              dense: true,
                              title: Text(name),
                              onTap: () => onSelected(name),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Log In'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RoleCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const Spacer(),
            const Icon(PhosphorIconsRegular.arrowRight, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
