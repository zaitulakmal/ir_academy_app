import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/models/activity.dart';
import '../../core/theme/app_colors.dart';
import 'attachment_picker.dart';
import 'attachment_preview.dart';
import 'create_activity_sheet.dart';

Future<void> showSubmitActivitySheet({
  required BuildContext context,
  required Activity activity,
  required Submission submission,
  required void Function(Submission updated) onSubmitted,
}) {
  final textController = TextEditingController(text: submission.textResponse ?? '');
  PickedAttachment? attachment = submission.attachmentPath != null
      ? PickedAttachment(path: submission.attachmentPath!, name: submission.attachmentName ?? 'Submission')
      : null;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) {
        final alreadySubmitted = submission.submitted;

        Future<void> pickAttachment() async {
          PickedAttachment? picked;
          switch (activity.responseType) {
            case ResponseType.video:
              picked = await pickVideo(context);
            case ResponseType.photo:
              picked = await pickPhoto(context);
            case ResponseType.drawing:
              picked = await pickDrawing(context);
            case ResponseType.worksheet:
              picked = await pickWorksheet();
            case ResponseType.text:
              return;
          }
          if (picked != null) setSheetState(() => attachment = picked);
        }

        final canSubmit =
            activity.responseType == ResponseType.text ? textController.text.trim().isNotEmpty : attachment != null;

        void submit() {
          submission.submitted = true;
          submission.submittedAt = DateTime.now();
          if (activity.responseType == ResponseType.text) {
            submission.textResponse = textController.text.trim();
          } else {
            submission.attachmentPath = attachment!.path;
            submission.attachmentName = attachment!.name;
          }
          onSubmitted(submission);
          Navigator.of(context).pop();
        }

        return Padding(
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
                    Expanded(
                      child: Text(activity.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ),
                    IconButton(
                      icon: const Icon(PhosphorIconsBold.x),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(responseTypeIcon(activity.responseType), size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(responseTypeLabel(activity.responseType),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Instructions', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(activity.instructions.isEmpty ? 'No instructions provided.' : activity.instructions),
                if (activity.attachmentPath != null) ...[
                  const SizedBox(height: 12),
                  AttachmentPreview(
                    responseType: ResponseType.worksheet,
                    path: activity.attachmentPath!,
                    name: activity.attachmentName ?? 'Attachment',
                  ),
                ],
                const SizedBox(height: 20),
                const Text('Your response', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                if (alreadySubmitted) ...[
                  if (submission.textResponse != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(PhosphorIconsFill.checkCircle, color: AppColors.success),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(submission.textResponse!,
                                style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    )
                  else if (submission.attachmentPath != null)
                    AttachmentPreview(
                      responseType: activity.responseType,
                      path: submission.attachmentPath!,
                      name: submission.attachmentName ?? 'Submission',
                    ),
                ] else if (activity.responseType == ResponseType.text) ...[
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'Write your answer here...'),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                ] else ...[
                  if (attachment != null) ...[
                    AttachmentPreview(
                      responseType: activity.responseType,
                      path: attachment!.path,
                      name: attachment!.name,
                    ),
                    const SizedBox(height: 10),
                  ],
                  OutlinedButton.icon(
                    onPressed: pickAttachment,
                    icon: Icon(attachment != null ? PhosphorIconsFill.checkCircle : responseTypeIcon(activity.responseType)),
                    label: Text(attachment != null ? 'Replace attachment' : _attachLabel(activity.responseType)),
                  ),
                ],
                const SizedBox(height: 20),
                if (!alreadySubmitted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canSubmit ? submit : null,
                      child: const Text('Submit'),
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

String _attachLabel(ResponseType type) {
  switch (type) {
    case ResponseType.video:
      return 'Record Video';
    case ResponseType.photo:
      return 'Take Photo';
    case ResponseType.drawing:
      return 'Open Drawing Canvas';
    case ResponseType.worksheet:
      return 'Upload Worksheet';
    case ResponseType.text:
      return '';
  }
}
