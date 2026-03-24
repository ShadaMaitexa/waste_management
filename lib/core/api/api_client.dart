import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  
  // Singleton pattern for the API client
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() 
      : _dio = Dio(BaseOptions(
          baseUrl: 'http://15.207.112.146/api/v1', // Base URL from env
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )),
        _storage = const FlutterSecureStorage() {
    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Retrieve access token
          final accessToken = await _storage.read(key: 'access_token');
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // If 401 Unauthorized, attempt refresh
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request
              try {
                final accessToken = await _storage.read(key: 'access_token');
                error.requestOptions.headers['Authorization'] = 'Bearer $accessToken';
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            } else {
              // Refresh failed, navigate to login or clear tokens
              await _storage.deleteAll();
            }
          }
          
          if (error.response?.statusCode == 403) {
            // "GIVEN the server returns 403 THEN a ForbiddenException is thrown"
            return handler.next(ForbiddenException(error.requestOptions, error.response));
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      // Make a direct request using a fresh dio instance to avoid recursive intercepts
      final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final response = await refreshDio.post('/auth/token/refresh/', data: {
        'refresh': refreshToken,
      });

      if (response.statusCode == 200) {
        final newAccess = response.data['access'];
        if (newAccess != null) {
          await _storage.write(key: 'access_token', value: newAccess);
          // If server rotates refresh token, save it too
          if (response.data['refresh'] != null) {
            await _storage.write(key: 'refresh_token', value: response.data['refresh']);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Convenient helper functions
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }
}

class ForbiddenException extends DioException {
  ForbiddenException(RequestOptions r, Response? res) 
      : super(requestOptions: r, response: res, type: DioExceptionType.badResponse, message: "Server returned 403 Forbidden - Role context insufficient");
}
