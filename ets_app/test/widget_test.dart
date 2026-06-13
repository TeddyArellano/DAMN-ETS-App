import 'package:ets_app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('La aplicación inicia correctamente', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: EtsApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(EtsApp), findsOneWidget);
  });
}