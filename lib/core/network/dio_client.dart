import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'api_exception.dart';

class DioClient {
  static DioClient? _instance;
  static DioClient get instance => _instance ??= DioClient._();

  late final Dio _dio;
  Dio get dio => _dio;

  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.fullBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: ApiConstants.headers,
      ),
    );

    // 인터셉터 추가
    _dio.interceptors.add(_ErrorInterceptor());
    
    // 개발 모드에서 로그 추가
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => debugPrint(object.toString()),
      ));
    }
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    
    if (response != null && response.data is Map<String, dynamic>) {
      // API 에러 응답 형태인 경우
      try {
        final apiException = ApiException.fromJson(response.data);
        handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: apiException,
          response: response,
        ));
        return;
      } catch (e) {
        // 파싱 실패 시 기본 처리
      }
    }

    // 네트워크 에러나 기타 에러 처리
    final errorMessage = _getErrorMessage(err);
    final apiException = ApiException(
      status: response?.statusCode ?? 0,
      code: err.type.name,
      message: errorMessage,
      timestamp: DateTime.now(),
    );

    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: apiException,
      response: response,
    ));
  }

  String _getErrorMessage(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '네트워크 연결 시간이 초과되었습니다.';
      case DioExceptionType.badResponse:
        return '서버에서 오류가 발생했습니다.';
      case DioExceptionType.cancel:
        return '요청이 취소되었습니다.';
      case DioExceptionType.connectionError:
        return '네트워크 연결을 확인해주세요.';
      default:
        return '알 수 없는 오류가 발생했습니다.';
    }
  }
}