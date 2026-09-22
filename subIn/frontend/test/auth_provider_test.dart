// test/providers/auth_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sub_in/providers/auth_provider.dart';

void main() {
 test('authProvider starts unauthenticated', () {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  final isLoggedIn = container.read(authIsLoggedInProvider);
  expect(isLoggedIn, false);
});
}