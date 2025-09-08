import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../error/exceptions.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 요청 로깅
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          // 응답 로깅
          print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          // 에러 로깅
          print('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('네트워크 연결 시간이 초과되었습니다.');
      case DioExceptionType.badResponse:
        return ServerException('서버 오류: ${error.response?.statusCode}');
      case DioExceptionType.cancel:
        return NetworkException('요청이 취소되었습니다.');
      case DioExceptionType.connectionError:
        return NetworkException('네트워크 연결을 확인해주세요.');
      default:
        return NetworkException('알 수 없는 네트워크 오류가 발생했습니다.');
    }
  }
}
