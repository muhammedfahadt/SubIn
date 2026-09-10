import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subIn/logging/app_logger.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storageService;
  final Dio _dio;
  final String baseUrl;

   // Constructor now accepts an optional client
  AuthService(
    this._storageService, {
    Dio? dio,
    this.baseUrl = 'https://api.default.com',
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));


  Future<String> login(String email, String password) async {
    AppLogger.info('🔐 Login attempt initiated', {'email': email});

    try {
      // 1. Make the POST request
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        )).timeout(const Duration(seconds: 10)); // Prevent hanging forever on bad networks

      // 2. Handle Success (HTTP 200 or 201)
      AppLogger.info('📦 Response received', {'data': response.data});

      final data = response.data as Map<String, dynamic>;
      
      // Extract token - handle both direct and nested structures
      final token = data['access_token'] ?? data['token'];
      
      if (token == null || (token is String && token.isEmpty)) {
        AppLogger.error(
          '❌ Token extraction failed',
          'Response has no valid access_token',
          StackTrace.current,
        );
        throw Exception('Server returned a successful response, but no token was provided.');
      }

        // 3. Save the token locally
        await _storageService.saveToken(token);
        AppLogger.info('✅ Login successful', {'email': email});

        return token;
    } on DioException catch (e, stackTrace) {
      // 👇 STRUCTURED LOG: Error with full stack trace
      AppLogger.error(
        '❌ Login failed',
        e,
        stackTrace,
      );

      // Extract the backend's error message safely
      final errorMessage = (e.response?.data as Map<String, dynamic>?)?['error'] ??
                           (e.response?.data as Map<String, dynamic>?)?['message'] ??
                           'Login failed. Please try again.';

      throw Exception(errorMessage);
    } catch (e,stackTrace) {
       AppLogger.critical('💥 Unexpected login error', e, stackTrace);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> logout() async {
    // Optional: Call backend to invalidate token on server-side
    AppLogger.info('🚪 User logged out');
    // await http.post(Uri.parse('$baseUrl/api/v1/auth/logout'), headers: {'Authorization': 'Bearer ${await _storageService.getToken()}'});
    await _storageService.clearToken();
  }

  Future<bool> isAuthenticated() async {
    final token = await _storageService.getToken();
    return token != null && token.isNotEmpty;
  }
}

// Update the provider to inject the Base URL from Environment Variables
final authServiceProvider = Provider<AuthService>((ref) {
  final storage = ref.watch(storageServiceProvider);

  // Read the environment variable passed via Docker --dart-define
  // Falls back to localhost for local development
  final baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
  // Create a Dio instance with the Talker interceptor
  final dio = Dio(BaseOptions(baseUrl: baseUrl));

  // 👇 THIS ONE LINE AUTO-LOGS EVERY HTTP REQUEST/RESPONSE
  dio.interceptors.add(
    TalkerDioLogger(
      talker: AppLogger.instance,
      settings: const TalkerDioLoggerSettings(
        printRequestHeaders: true,
        printResponseHeaders: false,
        printResponseMessage: true,
      ),
    ),
  ); 

  return AuthService(storage, dio: dio);
});
