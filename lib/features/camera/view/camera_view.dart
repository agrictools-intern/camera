import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../preview/view/preview_view.dart';

class CameraView extends StatefulWidget {
  final String agtCode;
  const CameraView({super.key, required this.agtCode});

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  @override
  void initState() {
    super.initState();
    _captureImage();
  }

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

  Future<void> _captureImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 100,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    if (image != null) {
      String newFilePath = await _saveImageToFolder(image.path);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPage(
            imagePath: newFilePath,
            agtCode: widget.agtCode,
          ),
        ),
      );
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
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
        title: Text("Camera - ${widget.agtCode}"),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
