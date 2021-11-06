import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
// import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:native_pdf_renderer_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can get non-null pdf document', (WidgetTester tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(Image), findsOneWidget);
  });
}
