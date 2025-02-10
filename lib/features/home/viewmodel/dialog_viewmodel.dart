import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextFormFieldViewModel extends StateNotifier<bool> {
  TextFormFieldViewModel() : super(false);

  void updateTextFormFieldButton(String text) {
    state = text.isNotEmpty;
  }
}
