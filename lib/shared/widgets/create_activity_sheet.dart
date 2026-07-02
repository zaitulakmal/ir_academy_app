import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/activity.dart';
import '../../core/theme/app_colors.dart';
import 'attachment_picker.dart';

String responseTypeLabel(ResponseType type) {
  switch (type) {
    case ResponseType.text:
      return 'Text';
    case ResponseType.video:
      return 'Video';
    case ResponseType.photo:
      return 'Photo';
    case ResponseType.drawing:
      return 'Drawing';
    case ResponseType.worksheet:
      return 'Worksheet';
  }
}

IconData responseTypeIcon(ResponseType type) {
  switch (type) {
    case ResponseType.text:
      return PhosphorIconsRegular.textAa;
    case ResponseType.video:
      return PhosphorIconsRegular.videoCamera;
    case ResponseType.photo:
      return PhosphorIconsRegular.camera;
    case ResponseType.drawing:
      return PhosphorIconsRegular.paintBrush;
    case ResponseType.worksheet:
      return PhosphorIconsRegular.fileText;
  }
}


Future<void> showCreateActivitySheet({
  required BuildContext context,
  required List<String> learnerNames,
  required void Function(Activity activity) onCreate,
  String? defaultSubject,
  Activity? existingActivity,
  VoidCallback? onDelete,
}) {
  final isEditing = existingActivity != null;
  final titleController = TextEditingController(text: existingActivity?.title ?? '');
  final instructionsController = TextEditingController(text: existingActivity?.instructions ?? '');
  final studentSearchController = TextEditingController();
  var responseType = existingActivity?.responseType ?? ResponseType.text;
  var wholeClass = existingActivity?.wholeClass ?? true;
  final selectedLearners = <String>{...(existingActivity?.assignedLearners ?? const [])};
  PickedAttachment? attachment = existingActivity?.attachmentPath != null
      ? PickedAttachment(
          path: existingActivity!.attachmentPath!,
          name: existingActivity.attachmentName ?? '',
          bytes: existingActivity.attachmentBytes,
        )
      : null;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEditing ? 'Edit activity' : 'Create activity',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Row(
                    children: [
                      if (isEditing)
                        IconButton(
                          icon: const Icon(PhosphorIconsRegular.trash, color: AppColors.danger),
                          onPressed: () {
                            onDelete?.call();
                            Navigator.of(context).pop();
                          },
                        ),
                      IconButton(
                        icon: const Icon(PhosphorIconsBold.x),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Title', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'e.g. Math worksheet 2.4'),
              ),
              const SizedBox(height: 16),
              const Text('Instructions', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Stack(
                children: [
                  TextField(
                    controller: instructionsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Write instructions',
                      contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 40),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await pickVideo(context);
                        if (picked != null) setSheetState(() => attachment = picked);
                      },
                      icon: const Icon(PhosphorIconsBold.videoCamera, size: 16),
                      label: const Text('Record'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.background,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Response type', style: TextStyle(fontWeight: FontWeight.w700)),
              RadioGroup<ResponseType>(
                groupValue: responseType,
                onChanged: (value) => setSheetState(() => responseType = value!),
                child: Column(
                  children: ResponseType.values
                      .map(
                        (type) => RadioListTile<ResponseType>(
                          value: type,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              Icon(responseTypeIcon(type), size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text(responseTypeLabel(type)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await pickWorksheet();
                  if (picked != null) setSheetState(() => attachment = picked);
                },
                icon: const Icon(PhosphorIconsRegular.uploadSimple, size: 18),
                label: const Text('Upload attachment'),
              ),
              if (attachment != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(PhosphorIconsFill.checkCircle, color: AppColors.success, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text(attachment!.name, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              const Text('Assign to', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: wholeClass,
                activeThumbColor: AppColors.primary,
                title: const Text('Whole class assigned'),
                onChanged: (value) => setSheetState(() => wholeClass = value),
              ),
              if (!wholeClass) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: studentSearchController,
                  decoration: const InputDecoration(
                    hintText: 'Search student name...',
                    prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass),
                  ),
                  onChanged: (_) => setSheetState(() {}),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Builder(builder: (_) {
                    final query = studentSearchController.text.trim().toLowerCase();
                    final filtered = query.isEmpty
                        ? learnerNames
                        : learnerNames.where((n) => n.toLowerCase().contains(query)).toList();
                    if (filtered.isEmpty) {
                      return const Center(child: Text('No students found', style: TextStyle(color: Colors.grey)));
                    }
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final name = filtered[i];
                        final isSelected = selectedLearners.contains(name);
                        return CheckboxListTile(
                          dense: true,
                          value: isSelected,
                          title: Text(name, style: const TextStyle(fontSize: 14)),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (v) => setSheetState(
                            () => v! ? selectedLearners.add(name) : selectedLearners.remove(name),
                          ),
                        );
                      },
                    );
                  }),
                ),
                if (selectedLearners.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('${selectedLearners.length} student(s) selected',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    onCreate(
                      Activity(
                        id: existingActivity?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                        title: titleController.text.trim(),
                        instructions: instructionsController.text.trim(),
                        responseType: responseType,
                        wholeClass: wholeClass,
                        assignedLearners: wholeClass ? const [] : selectedLearners.toList(),
                        subject: existingActivity?.subject ?? defaultSubject,
                        createdAt: existingActivity?.createdAt ?? DateTime.now(),
                        attachmentPath: attachment?.path,
                        attachmentName: attachment?.name,
                        attachmentBytes: attachment?.bytes,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(isEditing ? 'Save changes' : 'Assign to class'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
