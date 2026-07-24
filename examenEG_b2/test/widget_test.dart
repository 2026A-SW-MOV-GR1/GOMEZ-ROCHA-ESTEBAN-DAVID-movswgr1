import 'package:flutter_test/flutter_test.dart';

import 'package:pet_finder/main.dart';

void main() {
  testWidgets('La app arranca mostrando el mapa y el botón de reportar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PetFinderApp());
    await tester.pump();

    expect(find.text('Mascotas Perdidas'), findsOneWidget);
    expect(find.text('Reportar mascota'), findsOneWidget);
  });
}
