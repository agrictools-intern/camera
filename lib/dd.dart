// import 'package:flutter/material.dart';

// class View extends StatelessWidget {
//   final String agtCode;
//   const View({super.key, required this.agtCode});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         actions: [Icon(Icons.arrow_left)],
//       ),
//       body: Center(
//         child: Text("AGTCODE is :::>>>>$agtCode"),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class CameraView extends StatelessWidget {
  final String agtCode;
  const CameraView({super.key, required this.agtCode});

  Future<String> _saveImageToFolder(String filePath) async {
    try {
      final File originalFile = File(filePath);

      final Directory downloadsDir = Directory('/storage/emulated/0/Download');

      final Directory agricToolsDir = Directory('${downloadsDir.path}/AgricTools');

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
        child: CameraAwesomeBuilder.awesome(
          saveConfig: SaveConfig.photoAndVideo(),
          onMediaCaptureEvent: (event) {
            event.captureRequest.when(
              single: (single) async {
                final file = single.file?.path;
                if (file != null) {
                  debugPrint('Picture saved temporarily: $file');
                  String savedFilePath = await _saveImageToFolder(file);
                  if (savedFilePath.isNotEmpty) {
                    OpenFile.open(savedFilePath);
                  }
                }
              },
              multiple: (multiple) async {
                for (var value in multiple.fileBySensor.values) {
                  if (value != null) {
                    debugPrint('Multiple images taken: ${value.path}');
                    String savedFilePath = await _saveImageToFolder(value.path);
                    if (savedFilePath.isNotEmpty) {
                      OpenFile.open(savedFilePath);
                    }
                  }
                }
              },
            );
          },
        ),
      ),
    );
  }
}
