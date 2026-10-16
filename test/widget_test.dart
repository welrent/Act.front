import 'package:flutter_test/flutter_test.dart';
import 'package:welrent_act/main.dart';

void main() {
  testWidgets('WelrentActApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WelrentActApp());
    expect(find.byType(WelrentActApp), findsOneWidget);
  });
}
