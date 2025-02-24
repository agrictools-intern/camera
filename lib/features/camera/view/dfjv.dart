import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

      return savedFile.path;
    } catch (e) {
      return "";
    }
  }

  Future<void> _captureImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 100,
    );

    if (image != null) {
      String newFilePath = await _saveImageToFolder(image.path);

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
          child: ElevatedButton(
            onPressed: () => _captureImage(context),
            child: const Text("Capture Image"),
          ),
        ),
      ),
    );
  }
}
