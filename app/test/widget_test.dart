import 'package:flutter_test/flutter_test.dart';
import 'package:carebridge_ai/main.dart';

void main() {
  testWidgets('CareBridge AI app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CareBridgeApp());
    expect(find.byType(CareBridgeApp), findsOneWidget);
  });
}
