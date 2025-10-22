import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hidden_gem/components/addHiddenGem.dart';

void hiddenGemTests() {
  group('AddHiddenGem Widget Tests', () {
    Future<void> pumpAddHiddenGemForm(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: addHiddenGem(selectedPosition: LatLng(55.6, 13.0)),
        ),
      );
    }

    testWidgets('displays all expected form fields', (tester) async {
      await pumpAddHiddenGemForm(tester);

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Public'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('prevents form submission if required fields are empty', (
      tester,
    ) async {
      await pumpAddHiddenGemForm(tester);

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Missing information'), findsOneWidget);
    });

    testWidgets('toggles the Public switch on and off', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const addHiddenGem(
                        selectedPosition: LatLng(55.6, 13.0),
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      final dynamic state = tester.state(find.byType(addHiddenGem));
      expect(state.isPublic, isTrue);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(state.isPublic, isFalse);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(state.isPublic, isTrue);
    });

    testWidgets('handles missing position gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: addHiddenGem(selectedPosition: LatLng(0, 0))),
      );

      expect(find.byType(addHiddenGem), findsOneWidget);
    });
  });
}
