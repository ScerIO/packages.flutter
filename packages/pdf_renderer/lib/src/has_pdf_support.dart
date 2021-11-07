import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:universal_platform/universal_platform.dart';

Future<bool> hasPdfSupport() async {
  if (UniversalPlatform.isMacOS ||
      UniversalPlatform.isIOS ||
      UniversalPlatform.isWindows ||
      UniversalPlatform.isWeb) {
    return true;
  }
  if (UniversalPlatform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt! >= 21;
  }
  return false;
}
