import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';

Future<bool> hasSupport() async {
  if (Platform.isMacOS) {
    return true;
  }
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
