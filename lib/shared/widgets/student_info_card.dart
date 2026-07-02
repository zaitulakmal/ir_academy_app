import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_colors.dart';

class StudentInfoCard extends StatefulWidget {
  const StudentInfoCard({super.key});

  @override
  State<StudentInfoCard> createState() => _StudentInfoCardState();
}

class _StudentInfoCardState extends State<StudentInfoCard> {
  bool _showPassword = false;

  Future<void> _copy(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label copied')));
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCredentials = MockData.portalUsername.isNotEmpty || MockData.portalPassword.isNotEmpty;
    final hasClassGroup = MockData.classGroupLink.isNotEmpty;
    final hasGoogleMeet = MockData.googleMeetLink.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      child: Text(
                        MockData.studentName.isNotEmpty ? MockData.studentName[0] : '?',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(MockData.studentName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          if (MockData.currentUserId.isNotEmpty)
                            Text('ID: ${MockData.currentUserId}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (MockData.studentSyllabus.isNotEmpty || MockData.currentUserForm.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: AppColors.borderLight),
                  ),
                  if (MockData.studentSyllabus.isNotEmpty) ...[
                    _InfoRow(label: 'Syllabus', value: MockData.studentSyllabus),
                    const SizedBox(height: 8),
                  ],
                  if (MockData.currentUserForm.isNotEmpty)
                    _InfoRow(label: 'Class', value: MockData.studentForm),
                ],
              ],
            ),
          ),
        ),
        if (hasCredentials) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Learning Portal Access', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  if (MockData.portalUsername.isNotEmpty)
                    _CredentialRow(
                      label: 'Username',
                      value: MockData.portalUsername,
                      onCopy: () => _copy(MockData.portalUsername, 'Username'),
                    ),
                  if (MockData.portalPassword.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _CredentialRow(
                      label: 'Password',
                      value: MockData.portalPassword,
                      obscure: !_showPassword,
                      onToggleObscure: () => setState(() => _showPassword = !_showPassword),
                      onCopy: () => _copy(MockData.portalPassword, 'Password'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        if (hasClassGroup || hasGoogleMeet) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (hasClassGroup)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openLink(MockData.classGroupLink),
                    icon: const Icon(PhosphorIconsRegular.chatsCircle, size: 18),
                    label: const Text('Class Group'),
                  ),
                ),
              if (hasClassGroup && hasGoogleMeet) const SizedBox(width: 10),
              if (hasGoogleMeet)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openLink(MockData.googleMeetLink),
                    icon: const Icon(PhosphorIconsRegular.videoCamera, size: 18),
                    label: const Text('Google Meet'),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
      ],
    );
  }
}

class _CredentialRow extends StatelessWidget {
  final String label;
  final String value;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final VoidCallback onCopy;

  const _CredentialRow({
    required this.label,
    required this.value,
    this.obscure = false,
    this.onToggleObscure,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
          Expanded(
            child: Text(
              obscure ? '•' * value.length : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onToggleObscure != null)
            IconButton(
              icon: Icon(obscure ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash, size: 18),
              onPressed: onToggleObscure,
              visualDensity: VisualDensity.compact,
            ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.copy, size: 18),
            onPressed: onCopy,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
