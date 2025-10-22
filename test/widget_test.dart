import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'hidden_gem_tests.dart';
import 'mockup_firebase.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseAuthMocks();

    registerFallbackValue(const LatLng(55.6, 13.0));
  });

  hiddenGemTests();
}
