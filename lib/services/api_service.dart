import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:seat_sense_flutter/utils/constants.dart';
import 'package:seat_sense_flutter/utils/secure_storage.dart';

class ApiService {
  final Dio _dio = Dio();
  final Logger logger = Logger();

  ApiService() {
    _dio.options.baseUrl = Constants.apiBaseUrl;
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add the access token to the Authorization header
          String? accessToken = await SecureStorage.getAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          logger.i('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          logger.i(
            'Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          logger.e('DioError: ${e.message} ${e.requestOptions.path}');
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      logger.e('DioError during POST: ${e.message}');
      rethrow;
    } catch (e) {
      logger.e('Unexpected error during POST: $e');
      rethrow;
    }
  }

  Future<Response> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response;
    } on DioException catch (e) {
      logger.e('DioError during GET: ${e.message}');
      rethrow;
    } catch (e) {
      logger.e('Unexpected error during GET: $e');
      rethrow;
    }
  }
}
