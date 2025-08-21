import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';

class QrGeneratorWidget {
  // Show modal to enter URL and generate QR
  static Future<void> show(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final GlobalKey repaintKey = GlobalKey();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        // keep state in the builder scope so it isn't recreated every build
        String? error;
        bool generating = false;
        String? qrData;
        final scrollController = ScrollController();

        return Padding(
          padding: MediaQuery.of(ctx).viewInsets,
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: SingleChildScrollView(
              controller: scrollController,
              child: StatefulBuilder(builder: (context, setState) {
                Future<void> generateAndShow() async {
                  final input = controller.text.trim();
                  final uri = Uri.tryParse(input);
                  if (uri == null ||
                      !(uri.scheme == 'http' || uri.scheme == 'https') ||
                      uri.host.isEmpty) {
                    setState(
                        () => error = 'Please enter a valid URL (https://...)');
                    return;
                  }
                  setState(() {
                    error = null;
                    generating = false;
                    qrData = input;
                  });
                  // give a small delay so the QR widget can paint, then scroll
                  await Future.delayed(const Duration(milliseconds: 50));
                  if (scrollController.hasClients) {
                    scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Enter web app URL',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: InputDecoration(
                            hintText: 'https://example.com', errorText: error),
                        keyboardType: TextInputType.url,
                        onSubmitted: (_) => generateAndShow(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel')),
                          ElevatedButton(
                              onPressed: generating ? null : generateAndShow,
                              child: const Text('Generate')),
                        ],
                      ),
                      if (qrData != null) ...[
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RepaintBoundary(
                                    key: repaintKey,
                                    child: SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: CustomPaint(
                                        painter: QrPainter(
                                          data: qrData!,
                                          version: QrVersions.auto,
                                          gapless: true,
                                          color: const Color(0xFF000000),
                                          emptyColor: const Color(0xFFFFFFFF),
                                        ),
                                      ),
                                    )),
                                const SizedBox(height: 8),
                                Text(qrData ?? '',
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Clipboard.setData(
                                            ClipboardData(text: qrData ?? ''));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text('Link copied')));
                                      },
                                      child: const Text('Copy'),
                                    ),
                                    TextButton(
                                        onPressed: () async {
                                          if (qrData != null) {
                                            final data = qrData!;
                                            await _saveQrImageFromData(
                                                data, context);
                                          }
                                        },
                                        child: const Text('Download image')),
                                    TextButton(
                                        onPressed: () async {
                                          if (qrData != null) {
                                            final data = qrData!;
                                            await _shareQrImageFromData(
                                                data, context);
                                          }
                                        },
                                        child: const Text('Share')),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  // Generate PNG bytes for the QR data using QrPainter (avoids capturing the widget tree)
  static Future<Uint8List?> _generateQrPngBytes(String data, int size) async {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
    );
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final dim = ui.Size(size.toDouble(), size.toDouble());
    painter.paint(canvas, dim);
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  static Future<void> _saveQrImageFromData(
      String data, BuildContext context) async {
    try {
      final bytes = await _generateQrPngBytes(data, 800);
      if (bytes == null) throw Exception('Failed to generate QR bytes');
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'On web, right-click the QR image to save or open in new tab.')));
        return;
      }
      final tempDir = await getTemporaryDirectory();
      final file = await io.File(
              '${tempDir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png')
          .create();
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'QR code');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image ready to save or share')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save QR image')));
    }
  }

  static Future<void> _shareQrImageFromData(
      String data, BuildContext context) async {
    await _saveQrImageFromData(data, context);
  }
}
