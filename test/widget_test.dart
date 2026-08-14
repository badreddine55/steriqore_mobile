import 'package:flutter_test/flutter_test.dart';
import 'package:steriqore_mobile/main.dart';

void main() {
  testWidgets('SteriqoreApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SteriqoreApp());
    expect(find.text('Log in to your account'), findsOneWidget);
  });
}
