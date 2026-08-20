import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  // visibility_detector schedules a periodic timer to poll visibility;
  // disable it so tests don't hang waiting for a timer that never fires.
  setUpAll(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  testWidgets('LiveList renders its items', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LiveList(
          itemCount: 3,
          itemBuilder: (context, index, animation) => Text('Item $index'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
  });
}
