import 'package:flutter_test/flutter_test.dart';

import 'package:darios_store/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DariosStoreApp());
    expect(find.text("DARIO'S STORE"), findsOneWidget);
  });
}
