import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import '../../preview/view/preview_view.dart';

class CameraView extends StatelessWidget {
  final String agtCode;
  const CameraView({super.key, required this.agtCode});

  Future<String> _saveImageToFolder(String filePath) async {
    try {
      final File originalFile = File(filePath);
      final Directory downloadsDir = Directory('/storage/emulated/0/Download');
      final Directory agricToolsDir = Directory('${downloadsDir.path}/DemoAgrictoolsImage');

      if (!await agricToolsDir.exists()) {
        await agricToolsDir.create(recursive: true);
      }

      final String newFilePath = '${agricToolsDir.path}/Captured_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final savedFile = await originalFile.copy(newFilePath);
      debugPrint('Image saved to: $newFilePath');

      return savedFile.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Camera - $agtCode"),
      ),
      body: SafeArea(
        child: Center(
          child: CameraAwesomeBuilder.awesome(
            saveConfig: SaveConfig.photoAndVideo(),
            onMediaCaptureEvent: (event) async {
              event.captureRequest.when(
                single: (single) async {
                  final file = single.file?.path;
                  if (file != null) {
                    debugPrint('Picture captured: $file');

                    String newFilePath = await _saveImageToFolder(file);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreviewPage(
                          imagePath: newFilePath,
                          agtCode: agtCode,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
