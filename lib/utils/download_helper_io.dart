import 'dart:typed_data';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

Future<void> downloadBytesAsFile(Uint8List bytes, String filename) async {
  final tempDir = await getTemporaryDirectory();
  final file = io.File('${tempDir.path}/$filename');
  await file.writeAsBytes(bytes);
  // Share the file so users can save or send it.
  await Share.shareXFiles([XFile(file.path)], text: filename);
}
