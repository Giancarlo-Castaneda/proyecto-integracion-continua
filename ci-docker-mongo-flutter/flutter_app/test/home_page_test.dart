import 'package:flutter_test/flutter_test.dart';
import '../main.dart';

void main() {
  testWidgets('La HomePage muestra el texto inicial', (WidgetTester tester) async {
    // MyApp está definido en main.dart
    await tester.pumpWidget(const MyApp());

    // Verificamos que el texto "Mensaje actual:" aparezca en pantalla
    expect(find.text('Mensaje actual:'), findsOneWidget);
  });
}
