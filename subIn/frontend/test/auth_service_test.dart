// test/services/auth_service_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Import your actual classes
import 'package:sub_in/services/auth_services.dart';
import 'package:sub_in/services/storage_service.dart';

// 1. Create Mock classes
class MockDio extends Mock implements Dio {}
class MockStorageService extends Mock implements StorageService {}
class FakeUri extends Fake implements Uri {}

void main() {
  late AuthService authService;
  late MockDio mockDio;
  late MockStorageService mockStorageService;

  const testBaseUrl = 'https://api.test.com';
  const testEmail = 'test@test.com';
  const testPassword = 'password123';
  const fakeToken = 'super_secret_jwt_token';

  setUpAll(() {
    // 👇 CRITICAL FOR DIO: Mocktail needs fallback values for Dio's complex named parameters
    registerFallbackValue(Options());
    registerFallbackValue(CancelToken());
  });

  setUp(() {
    // Initialize fresh mocks before every single test
    mockDio = MockDio();
    mockStorageService = MockStorageService();

    // 👇 INJECT THE MOCK DIO INSTANCE HERE
    authService = AuthService(
      mockStorageService,
      dio: mockDio, // <-- Changed from 'client' to 'dio'
      baseUrl: testBaseUrl,
    );
  });

  group('AuthService.login()', () {

    test('✅ SUCCESS: Should return token and save it to storage on 200 OK', () async {
      // Arrange: Mock a successful Dio response
      when(() => mockDio.post(
            any(), // path
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/api/login'),
            statusCode: 200,
            data: {'token': fakeToken},
          ));

      // Mock the storage save operation
      when(() => mockStorageService.saveToken(any())).thenAnswer((_) async {});

      // Act: Call the real method
      final result = await authService.login(testEmail, testPassword);

      // Assert: Verify the results
      expect(result, fakeToken);

      // Verify that saveToken was called exactly once with the correct token
      verify(() => mockStorageService.saveToken(fakeToken)).called(1);
    });

    test('❌ API ERROR: Should throw Exception with message on 401 Unauthorized', () async {
      // Arrange: Mock a DioException representing a 401 failure
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: '/api/login'),
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: RequestOptions(path: '/api/login'),
              statusCode: 401,
              data: {'error': 'Invalid email or password'},
            ),
          ));

      // Act & Assert: Expect the method to throw an exception
      expect(
        () => authService.login(testEmail, 'wrong_password'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid email or password'),
        )),
      );

      // Verify storage was NEVER touched
      verifyNever(() => mockStorageService.saveToken(any()));
    });

    test('📡 NETWORK ERROR: Should throw Exception on Connection Timeout', () async {
      // Arrange: Simulate the device having no internet connection (Dio style)
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: '/api/login'),
            type: DioExceptionType.connectionTimeout,
          ));

      // Act & Assert
      expect(
        () => authService.login(testEmail, testPassword),
        throwsA(isA<Exception>()),
      );
    });

  });
}


