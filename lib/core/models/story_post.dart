import 'dart:typed_data';

enum StoryAttachmentType { none, link, file, photo, video }

class StoryPost {
  final String id;
  final String teacherName;
  final String classTag;
  final DateTime date;
  final String body;
  final StoryAttachmentType attachmentType;
  final String? attachmentUrl;
  final String? attachmentPath;
  final String? attachmentName;
  final String? attachmentSizeLabel;
  final Uint8List? attachmentBytes;
  final bool wholeClass;
  final List<String> assignedLearners;
  int likeCount;
  bool likedByMe;
  final List<String> comments;

  StoryPost({
    required this.id,
    required this.teacherName,
    required this.classTag,
    required this.date,
    required this.body,
    this.attachmentType = StoryAttachmentType.none,
    this.attachmentUrl,
    this.attachmentPath,
    this.attachmentName,
    this.attachmentSizeLabel,
    this.attachmentBytes,
    this.wholeClass = true,
    this.assignedLearners = const [],
    this.likeCount = 0,
    this.likedByMe = false,
    List<String>? comments,
  }) : comments = comments ?? [];
}
