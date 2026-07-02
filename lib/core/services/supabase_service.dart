import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const _url = 'https://hckuzikcvwwpaxxifxox.supabase.co';
  static const _anonKey = 'sb_publishable_XCfw1jdm4-kup0eQh4SIMA_YXyYhl_-';

  static SupabaseClient get _db => Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(url: _url, publishableKey: _anonKey);
  }

  // ── storage ───────────────────────────────────────────────────────────────

  static Future<String?> uploadAttachment({
    required String storagePath,
    required Uint8List bytes,
  }) async {
    final safePath = storagePath.replaceAll(' ', '_');
    try {
      await _db.storage.from('attachments').uploadBinary(
        safePath,
        bytes,
        fileOptions: FileOptions(upsert: true, contentType: _mimeType(safePath)),
      );
      return _db.storage.from('attachments').getPublicUrl(safePath);
    } catch (_) {
      return null;
    }
  }

  static String _mimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
