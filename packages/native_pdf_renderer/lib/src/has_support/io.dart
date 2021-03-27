import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';

Future<bool> hasSupport() async {
  if (Platform.isMacOS || Platform.isIOS || Platform.isWindows) {
    return true;
  }
  if (Platform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt >= 21;
  }
  return false;
}
