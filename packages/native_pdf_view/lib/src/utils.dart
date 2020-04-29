import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';

/// `PdfRenderer` on android requires android 5.0+
/// `PDFKit` om ios requires ios 11+
Future<bool> hasSupport() async {
  final deviceInfo = DeviceInfoPlugin();
  bool hasSupport = false;
  if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    hasSupport = int.parse(iosInfo.systemVersion.split('.').first) >= 11;
  } else if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    hasSupport = androidInfo.version.sdkInt >= 21;
  }
  return hasSupport;
}
