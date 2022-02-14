import 'dart:core';

import 'package:flutter/rendering.dart';

class PerformanceCheck {
  static final PerformanceCheck _instance = PerformanceCheck._internal();

  PerformanceCheck._internal();

  factory PerformanceCheck() => _instance;

  final Map<String, Stopwatch> _instances = {};

  void start(String id) {
    _instances[id] = Stopwatch()..start();
  }

  void stop(String id) {
    if (_instances[id] == null) {
      return;
    }
    debugPrint('doSomething() executed in ${_instances[id]!.elapsed}');
  }
}
