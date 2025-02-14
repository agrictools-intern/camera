import 'dart:io';
import 'package:flutter/material.dart';
import 'package:naming_camera/features/camera/view/camera_view.dart';
import '../../full_screen/view/full_screen_view.dart';
import '../../home/view/home_view.dart';

class PreviewPage extends StatefulWidget {
  final String imagePath;
  final String agtCode;

  const PreviewPage({super.key, required this.imagePath, required this.agtCode});

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  List<String> imagePaths = [];
  final String imageDirPath = '/storage/emulated/0/Download/DemoAgrictoolsImage';
  static const int maxImages = 4;
  DateTime? lastBackPressTime;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final Directory agricToolsDir = Directory(imageDirPath);

    if (await agricToolsDir.exists()) {
      List<FileSystemEntity> files = agricToolsDir.listSync();
      List<String> imageFiles = files
          .where((file) => file is File && file.path.toLowerCase().endsWith('.jpg'))
          .map((file) => file.path)
          .toList();

      setState(() {
        imagePaths = imageFiles;
      });
    }
  }

  Future<void> _removeImage(int index) async {
    String filePath = imagePaths[index];
    File imageFile = File(filePath);

    if (await imageFile.exists()) {
      await imageFile.delete();
    }

    setState(() {
      imagePaths.removeAt(index);
    });
  }

  Future<bool> _onWillPop() async {
    bool confirmExit = await _showExitConfirmationDialog();
    if (confirmExit) {
      for (String path in imagePaths) {
        File file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }

      setState(() {
        imagePaths.clear();
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
    return false;
  }

  Future<void> _saveImages() async {
    final downloadDir = Directory('/storage/emulated/0/Download/AgricTools');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    for (int index = 0; index < imagePaths.length; index++) {
      File imageFile = File(imagePaths[index]);

      if (!imageFile.existsSync()) {
        continue;
      }

      String newImagePath = '/storage/emulated/0/Download/Agrictools/${widget.agtCode}_${index + 1}.jpg';
      await imageFile.copy(newImagePath);
      await imageFile.delete();
    }

    setState(() {
      imagePaths.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Images saved successfully")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Exit"),
              content: const Text("You will lose all the photos. Do you want to proceed?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Yes"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Preview Image - ${widget.agtCode}"),
          actions: [
            TextButton(
              onPressed: () async {
                bool confirmExit = await _showExitConfirmationDialog();
                if (confirmExit) {
                  for (String path in imagePaths) {
                    File file = File(path);
                    if (await file.exists()) {
                      await file.delete();
                    }
                  }

                  setState(() {
                    imagePaths.clear();
                  });

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }
              },
              child: const Text(
                "Home",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ],
        ),
        body: imagePaths.isEmpty
            ? const Center(child: Text("No images available"))
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                  itemCount: imagePaths.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    File imageFile = File(imagePaths[index]);

                    if (!imageFile.existsSync()) {
                      return const Center(child: Text("Image not found"));
                    }

                    String imageAgtCode = "${widget.agtCode}_${index + 1}";

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageView(imagePath: imagePaths[index]),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                imageFile,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 5,
                            top: 5,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(5),
                                child: const Icon(Icons.close, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            left: 5,
                            child: Text(
                              imageAgtCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: imagePaths.length >= maxImages
                      ? null
                      : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CameraView(
                                agtCode: widget.agtCode,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: imagePaths.length >= maxImages ? Colors.grey : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    "Click More",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  onPressed: imagePaths.isEmpty ? null : _saveImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    "Save",
                    style: TextStyle(
                      color: imagePaths.isEmpty ? Colors.grey : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
