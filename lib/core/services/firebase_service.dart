import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import '../dto/activity_dto.dart';
import '../dto/announcement_dto.dart';
import '../dto/apr_entry_dto.dart';
import '../dto/chat_dto.dart';
import '../dto/story_post_dto.dart';
import '../dto/submission_dto.dart';
import '../dto/user_dto.dart';
import '../mock/mock_data.dart';
import '../models/activity.dart';
import '../models/app_notification.dart';
import '../models/apr_entry.dart';
import '../models/chat_models.dart';
import '../models/story_post.dart';

class FirebaseService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  // In-memory user cache — populated by loadUsers(), used by lookupUser()
  static List<UserDto> _users = [];

  static Future<void> init() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  }

  static Future<void> loadAll() async {
    await Future.wait([
      loadUsers(),
      _loadAnnouncements(),
      _loadStoryPosts(),
      _loadAprEntries(),
      _loadActivitiesAndSubmissions(),
      _loadChatGroups(),
      loadNotifications(),
    ]);
  }

  // ── in-app notifications ───────────────────────────────────────────────────
  //
  // Free-tier design (no Cloud Functions needed): every write also drops a doc
  // in the `notifications` collection; clients read the latest docs directly
  // and filter by audience/targets. Read-state is per-device (SharedPreferences).

  static const _readIdsPrefsKey = 'read_notification_ids';

  /// audience: 'students' | 'teachers' | 'all'.
  /// Empty [targets] means everyone in the audience.
  static Future<void> sendAppNotification({
    required String title,
    required String body,
    required NotificationType type,
    required String audience,
    List<String> targets = const [],
  }) async {
    try {
      await _db.collection('notifications').add({
        'title': title,
        'body': body,
        'type': type.name,
        'audience': audience,
        'targets': targets,
        'actor': MockData.currentUserName,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  static Future<void> loadNotifications() async {
    final name = MockData.currentUserName;
    final role = MockData.currentUserRole;
    if (name.isEmpty) return;

    final snap = await _db
        .collection('notifications')
        .orderBy('created_at', descending: true)
        .limit(100)
        .get();

    final prefs = await SharedPreferences.getInstance();
    final readIds = (prefs.getStringList(_readIdsPrefsKey) ?? []).toSet();

    final myAudience = (role == 'teacher' || role == 'admin') ? 'teachers' : 'students';
    final result = <AppNotification>[];
    for (final doc in snap.docs) {
      final d = doc.data();
      if (d['actor'] == name) continue; // don't notify yourself
      final audience = d['audience'] as String? ?? 'all';
      if (audience != 'all' && audience != myAudience) continue;
      final targets = List<String>.from(d['targets'] ?? []);
      if (targets.isNotEmpty && !targets.contains(name)) continue;
      result.add(AppNotification(
        id: doc.id,
        title: d['title'] as String? ?? '',
        body: d['body'] as String? ?? '',
        time: (d['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        type: NotificationType.values.firstWhere(
          (t) => t.name == d['type'],
          orElse: () => NotificationType.announcement,
        ),
        read: readIds.contains(doc.id),
      ));
    }

    final list = (role == 'teacher' || role == 'admin')
        ? MockData.teacherNotifications
        : MockData.studentNotifications;
    list
      ..clear()
      ..addAll(result);
  }

  static Future<void> markNotificationsRead(Iterable<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = (prefs.getStringList(_readIdsPrefsKey) ?? []).toSet()..addAll(ids);
    // Keep the set from growing forever
    final trimmed = readIds.toList();
    await prefs.setStringList(
      _readIdsPrefsKey,
      trimmed.length > 500 ? trimmed.sublist(trimmed.length - 500) : trimmed,
    );
  }

  // ── users ──────────────────────────────────────────────────────────────────

  static Future<void> loadUsers() async {
    final snap = await _db.collection('users').orderBy('name').get();
    _users = snap.docs.map(UserDto.fromFirestore).toList();

    MockData.learners
      ..clear()
      ..addAll(_users.where((u) => u.role == 'student').map((u) => u.toLearner()));
    MockData.teacherNames
      ..clear()
      ..addAll(_users.where((u) => u.role == 'teacher').map((u) => u.name));
  }

  /// Synchronous lookup from cached user list — call after loadUsers().
  static Future<Map<String, dynamic>?> lookupUser(String name) async {
    final q = name.trim().toLowerCase();
    final match = _users
        .where((u) => u.name.toLowerCase() == q)
        .cast<UserDto?>()
        .firstOrNull ??
        _users
            .where((u) => u.name.toLowerCase().contains(q))
            .cast<UserDto?>()
            .firstOrNull;
    if (match == null) return null;
    return {
      'id': match.id,
      'name': match.name,
      'role': match.role,
      'form': match.form,
      'syllabus': match.syllabus,
      'portal_username': match.portalUsername,
      'portal_password': match.portalPassword,
      'class_group_link': match.classGroupLink,
      'google_meet_link': match.googleMeetLink,
    };
  }

  static Future<void> saveFcmToken(String userId) async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _db.collection('users').doc(userId).update({'fcm_token': token});
      }
    } catch (_) {}
  }

  // ── notifications permission ───────────────────────────────────────────────

  static Future<void> requestNotificationPermission() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
  }

  // ── announcements ──────────────────────────────────────────────────────────

  static Future<void> _loadAnnouncements() async {
    final snap = await _db
        .collection('announcements')
        .orderBy('created_at', descending: true)
        .get();
    MockData.announcements
      ..clear()
      ..addAll(snap.docs.map((d) => AnnouncementDto.fromFirestore(d).toDomain()));
  }

  static Future<void> saveAnnouncement(AnnouncementPost post) async {
    final ref = post.id != null
        ? _db.collection('announcements').doc(post.id)
        : _db.collection('announcements').doc();
    final dto = AnnouncementDto.fromDomain(post, overrideId: ref.id);
    await ref.set(dto.toFirestore());
    await _queueNotification(
      title: 'New Announcement',
      body: post.body.length > 80 ? '${post.body.substring(0, 80)}…' : post.body,
      type: 'announcement',
      targets: 'all',
    );
    await sendAppNotification(
      title: 'New Announcement',
      body: post.body.length > 80 ? '${post.body.substring(0, 80)}…' : post.body,
      type: NotificationType.announcement,
      audience: 'all',
    );
  }

  static Future<void> deleteAnnouncement(String id) async {
    await _db.collection('announcements').doc(id).delete();
  }

  // ── story posts ────────────────────────────────────────────────────────────

  static Future<void> _loadStoryPosts() async {
    final snap = await _db
        .collection('story_posts')
        .orderBy('date', descending: true)
        .get();
    MockData.storyPosts
      ..clear()
      ..addAll(snap.docs.map((d) => StoryPostDto.fromFirestore(d).toDomain()));
  }

  static Future<void> saveStoryPost(StoryPost post) async {
    final dto = StoryPostDto.fromDomain(post);
    await _db.collection('story_posts').doc(post.id).set(dto.toFirestore());
  }

  /// Like [saveStoryPost] but also notifies the targeted students —
  /// call this for newly composed posts (not for likes/comments updates).
  static Future<void> saveNewStoryPost(StoryPost post) async {
    await saveStoryPost(post);
    await sendAppNotification(
      title: 'New Class Update',
      body: post.body.length > 80 ? '${post.body.substring(0, 80)}…' : post.body,
      type: NotificationType.announcement,
      audience: 'students',
      targets: post.wholeClass ? const [] : post.assignedLearners,
    );
  }

  static Future<void> deleteStoryPost(String id) async {
    await _db.collection('story_posts').doc(id).delete();
  }

  // ── APR entries ────────────────────────────────────────────────────────────

  static Future<void> _loadAprEntries() async {
    final snap = await _db
        .collection('apr_entries')
        .orderBy('date', descending: true)
        .get();
    MockData.aprEntries
      ..clear()
      ..addAll(snap.docs.map((d) => AprEntryDto.fromFirestore(d).toDomain()));
  }

  static Future<void> saveAprEntry(AprEntry entry) async {
    final isNew = entry.id == null;
    final ref = entry.id != null
        ? _db.collection('apr_entries').doc(entry.id)
        : _db.collection('apr_entries').doc();
    final dto = AprEntryDto.fromDomain(entry, overrideId: ref.id);
    await ref.set(dto.toFirestore());
    if (isNew) {
      await sendAppNotification(
        title: 'New APR Report',
        body: '${entry.subject} — ${entry.topicCovered}',
        type: NotificationType.grade,
        audience: 'students',
        targets: [entry.learnerName],
      );
    }
  }

  static Future<void> deleteAprEntry(String id) async {
    await _db.collection('apr_entries').doc(id).delete();
  }

  // ── activities + submissions ───────────────────────────────────────────────

  static Future<void> _loadActivitiesAndSubmissions() async {
    final actSnap = await _db
        .collection('activities')
        .orderBy('created_at', descending: true)
        .get();
    final subSnap = await _db.collection('submissions').get();
    MockData.activities
      ..clear()
      ..addAll(actSnap.docs.map((d) => ActivityDto.fromFirestore(d).toDomain()));
    MockData.submissions
      ..clear()
      ..addAll(subSnap.docs.map((d) => SubmissionDto.fromFirestore(d).toDomain()));
  }

  static Future<void> saveActivity(Activity act) async {
    final dto = ActivityDto.fromDomain(act);
    await _db.collection('activities').doc(act.id).set(dto.toFirestore());

    final targets = act.wholeClass
        ? MockData.learners.map((l) => l.name).toList()
        : act.assignedLearners;
    await _queueNotification(
      title: 'New Homework: ${act.title}',
      body: act.instructions.length > 80
          ? '${act.instructions.substring(0, 80)}…'
          : act.instructions,
      type: 'homework',
      targets: targets,
    );
    await sendAppNotification(
      title: 'New Homework: ${act.title}',
      body: act.instructions.length > 80
          ? '${act.instructions.substring(0, 80)}…'
          : act.instructions,
      type: NotificationType.homework,
      audience: 'students',
      targets: act.wholeClass ? const [] : act.assignedLearners,
    );
  }

  static Future<void> deleteActivity(String id) async {
    await _db.collection('activities').doc(id).delete();
  }

  static Future<void> upsertSubmission(Submission sub) async {
    final docId = '${sub.activityId}__${sub.learnerName.replaceAll(' ', '_')}';
    final dto = SubmissionDto.fromDomain(sub);
    await _db
        .collection('submissions')
        .doc(docId)
        .set(dto.toFirestore(), SetOptions(merge: true));

    final activityTitle = MockData.activities
        .where((a) => a.id == sub.activityId)
        .map((a) => a.title)
        .firstOrNull ?? 'Homework';
    if (sub.graded) {
      // Teacher marked it → tell the student
      await sendAppNotification(
        title: 'Homework Marked: $activityTitle',
        body: sub.grade != null ? 'Grade: ${sub.grade}' : 'Your teacher has marked your homework.',
        type: NotificationType.grade,
        audience: 'students',
        targets: [sub.learnerName],
      );
    } else if (sub.submitted) {
      // Student submitted → tell the teachers
      await sendAppNotification(
        title: 'New Submission: $activityTitle',
        body: '${sub.learnerName} has submitted their homework.',
        type: NotificationType.homework,
        audience: 'teachers',
      );
    }
  }

  // ── chat groups ────────────────────────────────────────────────────────────

  /// Public refresh — lets screens pick up groups created after login.
  static Future<void> reloadChatGroups() => _loadChatGroups();

  static Future<void> _loadChatGroups() async {
    final groupSnap = await _db.collection('chat_groups').get();
    final groups = <ChatGroup>[];
    for (final groupDoc in groupSnap.docs) {
      final memberSnap = await _db
          .collection('chat_groups')
          .doc(groupDoc.id)
          .collection('members')
          .get();
      final members =
          memberSnap.docs.map((d) => ChatMemberDto.fromFirestore(d).toDomain()).toList();
      groups.add(ChatGroupDto.fromFirestore(groupDoc).toDomain(members: members));
    }
    MockData.chatGroups
      ..clear()
      ..addAll(groups);
  }

  static Future<void> saveGroup(ChatGroup group) async {
    final dto = ChatGroupDto(id: group.id, name: group.name);
    await _db.collection('chat_groups').doc(group.id).set(dto.toFirestore());
    for (final member in group.members) {
      final mDto = ChatMemberDto(userName: member.name, userRole: member.role.name);
      await _db
          .collection('chat_groups')
          .doc(group.id)
          .collection('members')
          .doc(member.name)
          .set(mDto.toFirestore());
    }
    await sendAppNotification(
      title: 'New Group: ${group.name}',
      body: 'You have been added to the group "${group.name}".',
      type: NotificationType.chat,
      audience: 'all',
      targets: group.members
          .map((m) => m.name)
          .where((n) => n != MockData.currentUserName)
          .toList(),
    );
  }

  // ── group chat real-time ───────────────────────────────────────────────────

  static Stream<List<GroupMessage>> groupMessageStream(String groupId) {
    return _db
        .collection('chat_groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('sent_at')
        .snapshots()
        .map((s) => s.docs.map((d) => GroupMessageDto.fromFirestore(d).toDomain()).toList());
  }

  static Future<void> sendGroupMessage(
      String groupId, String senderName, String text) async {
    final dto = GroupMessageDto(
        senderName: senderName, text: text, sentAt: DateTime.now().toUtc());
    await _db
        .collection('chat_groups')
        .doc(groupId)
        .collection('messages')
        .add(dto.toFirestore());

    final group = MockData.chatGroups.where((g) => g.id == groupId).firstOrNull;
    if (group != null) {
      await sendAppNotification(
        title: group.name,
        body: '$senderName: $text',
        type: NotificationType.chat,
        audience: 'all',
        targets: group.members
            .map((m) => m.name)
            .where((n) => n != senderName)
            .toList(),
      );
    }
  }

  static Future<List<GroupMessage>> loadGroupMessages(String groupId) async {
    final snap = await _db
        .collection('chat_groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('sent_at', descending: true)
        .get();
    return snap.docs.map((d) => GroupMessageDto.fromFirestore(d).toDomain()).toList();
  }

  // ── 1:1 chat real-time ────────────────────────────────────────────────────

  static Stream<List<GroupMessage>> chatMessageStream(String threadId) {
    return _db
        .collection('chat_threads')
        .doc(threadId)
        .collection('messages')
        .orderBy('sent_at')
        .snapshots()
        .map((s) => s.docs.map((d) => GroupMessageDto.fromFirestore(d).toDomain()).toList());
  }

  static Future<void> sendChatMessage(
      String threadId, String senderName, String text,
      {String? recipientName}) async {
    final dto = GroupMessageDto(
        senderName: senderName, text: text, sentAt: DateTime.now().toUtc());
    await _db
        .collection('chat_threads')
        .doc(threadId)
        .collection('messages')
        .add(dto.toFirestore());

    if (recipientName != null && recipientName.isNotEmpty) {
      await sendAppNotification(
        title: 'Message from $senderName',
        body: text,
        type: NotificationType.chat,
        audience: 'all',
        targets: [recipientName],
      );
    }
  }

  static Future<List<GroupMessage>> loadChatMessages(String threadId) async {
    final snap = await _db
        .collection('chat_threads')
        .doc(threadId)
        .collection('messages')
        .orderBy('sent_at', descending: true)
        .get();
    return snap.docs.map((d) => GroupMessageDto.fromFirestore(d).toDomain()).toList();
  }

  // ── FCM notification queue (processed by Cloud Functions) ─────────────────

  static Future<void> _queueNotification({
    required String title,
    required String body,
    required String type,
    required Object targets, // 'all' | List<String>
  }) async {
    try {
      await _db.collection('notification_jobs').add({
        'title': title,
        'body': body,
        'type': type,
        'targets': targets,
        'created_at': FieldValue.serverTimestamp(),
        'sent': false,
      });
    } catch (_) {}
  }
}
