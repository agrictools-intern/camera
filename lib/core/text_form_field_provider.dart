import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/home/viewmodel/dialog_viewmodel.dart';

final textFormFieldProvider = StateNotifierProvider<TextFormFieldViewModel, bool>(
  (ref) => TextFormFieldViewModel(),
);

final errorTextProvider = StateProvider<String?>((ref) => null);
