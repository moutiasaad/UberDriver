import 'package:dio/dio.dart';
import '../local/secure_cash_helper.dart';

class DioHelper {
  static late Dio dio;
  // Update base URL to match your API
  static const String baseUrl = "https://tshl-driver.store/api/v1/";

  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.options.extra['withCredentials'] = true;
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          // Print response details for debugging
          print('═══════════════════════════════════════════════════════════');
          print('RESPONSE: ${response.statusCode} ${response.statusMessage}');
          print('URL: ${response.requestOptions.uri}');
          print('DATA: ${response.data}');
          print('═══════════════════════════════════════════════════════════');
          return handler.next(response);
        },
        onRequest: (options, handler) {
          // Print request details for debugging
          print('═══════════════════════════════════════════════════════════');
          print('REQUEST: ${options.method} ${options.uri}');
          print('HEADERS: ${options.headers}');
          print('BODY: ${options.data}');
          print('═══════════════════════════════════════════════════════════');
          return handler.next(options);
        },
        onError: (e, handler) {
          print('═══════════════════════════════════════════════════════════');
          print('ERROR: ${e.message}');
          print('ERROR RESPONSE: ${e.response}');
          print('ERROR DATA: ${e.response?.data}');
          print('STATUS CODE: ${e.response?.statusCode}');
          print('═══════════════════════════════════════════════════════════');

          // Custom error handling for 302 redirections
          if (e.response?.statusCode == 302) {
            print('Redirection message: ${e.response?.data}');
          }

          // Add custom error information to DioException
          final customError = DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            error: {
              'message': e.response?.data?['message'],
              'errors': e.response?.data?['errors'],
              'msg': e.message,
              'code': e.response?.statusCode,
            },
            type: e.type,
          );

          return handler.next(customError);
        },
      ),
    );
  }

  // Helper function to get the authorization token
  static Future<Map<String, dynamic>> _getHeaders(bool withToken) async {
    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withToken) {
      final token = await SecureCashHelper.getToken();
      print('DEBUG TOKEN: ${token.isNotEmpty ? "Token exists (${token.length} chars)" : "NO TOKEN"}');
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // GET request
  static Future<Response> getData({
    required String url,
    String urlParam = '',
    Object? data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? header,
    bool withToken = true,
  }) async {
    final headers = await _getHeaders(withToken);
    headers.addAll(header ?? {});
    return dio.get(
      '$url$urlParam',
      data: data,
      queryParameters: query,
      options: Options(headers: headers),
    );
  }

  // POST request
  static Future<Response> postData({
    required String url,
    String urlParam = '',
    Object? data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? header,
    bool withToken = true,
  }) async {
    final headers = await _getHeaders(withToken);
    headers.addAll(header ?? {});
    return dio.post(
      '$url$urlParam',
      data: data,
      queryParameters: query,
      options: Options(headers: headers),
    );
  }

  // PUT request
  static Future<Response> putData({
    required String url,
    String urlParam = '',
    Object? data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? header,
    bool withToken = true,
  }) async {
    final headers = await _getHeaders(withToken);
    headers.addAll(header ?? {});
    return dio.put(
      '$url$urlParam',
      data: data,
      queryParameters: query,
      options: Options(headers: headers),
    );
  }

  // DELETE request
  static Future<Response> deleteData({
    required String url,
    String urlParam = '',
    Object? data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? header,
    bool withToken = true,
  }) async {
    final headers = await _getHeaders(withToken);
    headers.addAll(header ?? {});
    return dio.delete(
      '$url$urlParam',
      data: data,
      queryParameters: query,
      options: Options(headers: headers),
    );
  }
}