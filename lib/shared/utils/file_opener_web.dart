import 'dart:typed_data';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> openAttachment({String? path, Uint8List? bytes, required String name}) async {
  if (bytes != null) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', name)
      ..setAttribute('target', '_blank')
      ..click();
    html.Url.revokeObjectUrl(url);
  } else if (path != null && path.startsWith('http')) {
    html.AnchorElement(href: path)
      ..setAttribute('target', '_blank')
      ..click();
  }
}
