import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';

/// Dio HTTP client provider with configured interceptors.
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// Configured Dio HTTP client for API requests.
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  /// Sets the authorization token for authenticated requests.
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Removes the authorization token.
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

/// Logging interceptor for debugging API requests.
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // In debug mode, log the request details
    assert(() {
      // ignore: avoid_print
      print('[DIO] ${options.method} ${options.uri}');
      return true;
    }());
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('[DIO] ${response.statusCode} ${response.requestOptions.uri}');
      return true;
    }());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    assert(() {
      // ignore: avoid_print
      print('[DIO ERROR] ${err.type}: ${err.message}');
      return true;
    }());
    handler.next(err);
  }
}

/// Error interceptor for transforming API errors into domain errors.
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final AppException appException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        appException = AppException(
          message: 'Connection timed out. Please try again.',
          statusCode: err.response?.statusCode,
        );
        break;
      case DioExceptionType.connectionError:
        appException = AppException(
          message: 'No internet connection. Please check your network.',
          statusCode: null,
        );
        break;
      case DioExceptionType.badResponse:
        appException = _handleBadResponse(err.response);
        break;
      default:
        appException = AppException(
          message: 'An unexpected error occurred.',
          statusCode: err.response?.statusCode,
        );
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appException,
        type: err.type,
        response: err.response,
      ),
    );
  }

  AppException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode ?? 500;
    final data = response?.data;

    String message;
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      message = data['message'] as String;
    } else {
      switch (statusCode) {
        case 400:
          message = 'Bad request. Please check your input.';
          break;
        case 401:
          message = 'Unauthorized. Please log in again.';
          break;
        case 403:
          message = 'You do not have permission to perform this action.';
          break;
        case 404:
          message = 'Resource not found.';
          break;
        case 409:
          message = 'Conflict. The resource already exists.';
          break;
        case 422:
          message = 'Invalid data provided.';
          break;
        case 429:
          message = 'Too many requests. Please try again later.';
          break;
        case 500:
          message = 'Server error. Please try again later.';
          break;
        default:
          message = 'An error occurred (status: $statusCode).';
      }
    }

    return AppException(message: message, statusCode: statusCode);
  }
}

/// Application-level exception for API errors.
class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'AppException: $message (status: $statusCode)';
}
