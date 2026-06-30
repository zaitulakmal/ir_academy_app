import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';

Future<void> openAttachment({String? path, Uint8List? bytes, required String name}) async {
  if (path == null) return;
  await OpenFilex.open(path);
}
