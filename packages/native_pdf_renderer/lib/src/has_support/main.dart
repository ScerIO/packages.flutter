// ignore: uri_does_not_exist
import 'stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'browser.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'io.dart' as base;

Future<bool> hasSupport() => base.hasSupport();
