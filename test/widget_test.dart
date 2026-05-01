import 'package:flutter_test/flutter_test.dart';
import 'package:gaara/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('La app carga correctamente', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const StudentPlannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Gaara'), findsOneWidget);
    expect(find.text('Vista rápida'), findsOneWidget);
  });
}
