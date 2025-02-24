import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naming_camera/features/camera/view/camera_view.dart';

import '../../../core/text_form_field_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late TextEditingController _agtController;

  @override
  void initState() {
    super.initState();
    _agtController = TextEditingController();
    _agtController.addListener(() {
      _validateInput(_agtController.text);
    });
  }

  @override
  void dispose() {
    _agtController.dispose();
    super.dispose();
  }

  void _validateInput(String agtCode) async {
    final pattern = RegExp(r'^agt\d{4,5}$', caseSensitive: false);

    bool isValid = pattern.hasMatch(agtCode);

    if (isValid) {
      final hasMatchingFiles = await _doesAgtCodeExist(agtCode.toUpperCase());
      if (hasMatchingFiles) {
        ref.read(errorTextProvider.notifier).state = 'AGT Code is already there!';
      } else {
        ref.read(errorTextProvider.notifier).state = null;
      }
    } else {
      ref.read(errorTextProvider.notifier).state = 'Invalid Format! Use AGT1234 or AGT12345 format';
    }

    ref.read(textFormFieldProvider.notifier).updateTextFormFieldButton(agtCode);
  }

  Future<bool> _doesAgtCodeExist(String agtCode) async {
    final agricToolsDirectory = Directory('/storage/emulated/0/Download/AgricTools');

    if (!await agricToolsDirectory.exists()) {
      return false;
    }

    List<FileSystemEntity> files = agricToolsDirectory.listSync();
    Set<String> uniqueAgtCodes = {};

    for (var file in files) {
      if (file is File) {
        String fileName = file.uri.pathSegments.last;

        if (fileName.contains('_')) {
          String prefix = fileName.split('_').first;
          uniqueAgtCodes.add(prefix);
        }
      }
    }

    return uniqueAgtCodes.contains(agtCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _agtController.clear();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Consumer(
                  builder: (context, ref, child) {
                    final errorText = ref.watch(errorTextProvider);
                    final isButtonEnabled = ref.watch(textFormFieldProvider);

                    return Dialog(
                      child: Stack(
                        children: [
                          Positioned(
                            top: 5,
                            right: 10,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(20.0),
                            width: 350,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Enter the AGT Code",
                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _agtController,
                                  onChanged: _validateInput,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: 'AGT12345',
                                    errorText: errorText,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(color: Color.fromARGB(152, 0, 0, 0)),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  onPressed: isButtonEnabled && errorText == null
                                      ? () {
                                          String formattedAgtCode = _agtController.text.toUpperCase();
                                          if (RegExp(r'^AGT\d{4}$').hasMatch(formattedAgtCode)) {
                                            formattedAgtCode = 'AGT0${formattedAgtCode.substring(3)}';
                                          }

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CameraView(agtCode: formattedAgtCode),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: const Text('Start capturing the image'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            elevation: 4,
            shape: RoundedRectangleBorder(side: const BorderSide()),
          ),
          child: const Text('Start taking pictures....'),
        ),
      ),
    );
  }
}
