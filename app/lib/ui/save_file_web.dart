import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

Future<String> saveBytes(List<int> bytes, String filename, String mime) async {
  final blob = Blob(
    [Uint8List.fromList(bytes).buffer.toJS].toJS,
    BlobPropertyBag(type: mime),
  );
  final url = URL.createObjectURL(blob);
  final anchor = HTMLAnchorElement()
    ..href = url
    ..download = filename;
  anchor.click();
  URL.revokeObjectURL(url);
  return filename;
}
