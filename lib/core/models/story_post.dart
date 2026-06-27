enum StoryAttachmentType { none, link, file }

class StoryPost {
  final String id;
  final String teacherName;
  final String classTag;
  final DateTime date;
  final String body;
  final StoryAttachmentType attachmentType;
  final String? attachmentUrl;
  final String? attachmentName;
  final String? attachmentSizeLabel;
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
    this.attachmentName,
    this.attachmentSizeLabel,
    this.likeCount = 0,
    this.likedByMe = false,
    List<String>? comments,
  }) : comments = comments ?? [];
}
