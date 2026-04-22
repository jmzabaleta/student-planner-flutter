import 'package:flutter_test/flutter_test.dart';
import 'package:gaara/main.dart';

void main() {
  testWidgets('La app carga correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentPlannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Tu panel estudiantil'), findsOneWidget);
  });
}