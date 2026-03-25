import 'package:flutter/widgets.dart';

extension LocaleExtensions on BuildContext {
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}

