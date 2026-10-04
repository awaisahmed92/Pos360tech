import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> saveBytes(List<int> bytes, String filename, String mime) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}${Platform.pathSeparator}$filename');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
