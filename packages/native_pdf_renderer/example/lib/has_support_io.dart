import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';

Future<bool> hasSupport() async {
  if (Platform.isMacOS || Platform.isIOS) {
    return true;
  }
  final deviceInfo = DeviceInfoPlugin();
  bool hasSupport = false;
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    hasSupport = androidInfo.version.sdkInt >= 21;
  }
  return hasSupport;
}
