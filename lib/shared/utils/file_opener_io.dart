import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openAttachment({String? path, Uint8List? bytes, required String name}) async {
  if (path == null) return;
  if (path.startsWith('http')) {
    final uri = Uri.parse(path);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    await OpenFilex.open(path);
  }
}
