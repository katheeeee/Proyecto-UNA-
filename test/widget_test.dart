import 'package:flutter_test/flutter_test.dart';
import 'package:una_mas/main.dart';

void main() {
  testWidgets('Muestra la pantalla de horario', (WidgetTester tester) async {
    await tester.pumpWidget(const UnaMasApp());

    expect(find.text('Mi horario'), findsOneWidget);
    expect(find.text('Organiza tu semana académica'), findsOneWidget);
    expect(find.text('Ingeniería de Software'), findsWidgets);
    expect(find.text('Activar recordatorio'), findsWidgets);
  });
}
