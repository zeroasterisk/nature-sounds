import 'package:flutter_test/flutter_test.dart';

import 'package:nature_sounds/app.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NatureSoundsApp());
    expect(find.text('Nature Sounds'), findsOneWidget);
  });
}
