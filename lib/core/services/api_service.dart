import 'dart:io';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../utils/result.dart';
import 'storage_service.dart';

/// API Service powered by Dio for communicating with Laravel DCMS Backend
class ApiService {
  final Dio _dio;
  final StorageService _storageService;

  ApiService(this._dio, this._storageService) {
    _dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Log or handle unauthorized globally if needed
          return handler.next(error);
        },
      ),
    );
  }

  // GET Request
  Future<Result<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return Result.success(response.data);
    } on DioException catch (e) {
      return Result.error(_handleDioError(e));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  // POST Request
  Future<Result<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      return Result.success(response.data);
    } on DioException catch (e) {
      return Result.error(_handleDioError(e));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  // PUT / PATCH Request
  Future<Result<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters);
      return Result.success(response.data);
    } on DioException catch (e) {
      return Result.error(_handleDioError(e));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  // DELETE Request
  Future<Result<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(path, data: data, queryParameters: queryParameters);
      return Result.success(response.data);
    } on DioException catch (e) {
      return Result.error(_handleDioError(e));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  // Multipart Form Data Upload (for complaint images)
  Future<Result<dynamic>> postMultipart(
    String path, {
    required Map<String, dynamic> fields,
    List<File>? files,
    String fileKey = 'attachments[]',
  }) async {
    try {
      final formData = FormData.fromMap(fields);

      if (files != null && files.isNotEmpty) {
        for (final file in files) {
          final fileName = file.path.split('/').last.split('\\').last;
          formData.files.add(
            MapEntry(
              fileKey,
              await MultipartFile.fromFile(file.path, filename: fileName),
            ),
          );
        }
      }

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return Result.success(response.data);
    } on DioException catch (e) {
      return Result.error(_handleDioError(e));
    } catch (e) {
      return Result.error(ServerFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkFailure('Unable to connect to the DCMS server. Please check your connection.');
    }

    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode;
      final data = response.data;

      String message = 'An unexpected server error occurred';
      if (data is Map && data.containsKey('message')) {
        message = data['message'].toString();
      }

      if (statusCode == 401) {
        return AuthFailure(message);
      } else if (statusCode == 422) {
        Map<String, dynamic>? errors;
        if (data is Map && data.containsKey('errors')) {
          errors = Map<String, dynamic>.from(data['errors'] as Map);
        }
        return ValidationFailure(message, errors: errors);
      } else if (statusCode == 403) {
        return ServerFailure(message.isEmpty ? 'Access Forbidden: Unauthorized role' : message, statusCode: 403);
      } else if (statusCode == 404) {
        return ServerFailure(message.isEmpty ? 'Resource not found' : message, statusCode: 404);
      } else {
        return ServerFailure(message, statusCode: statusCode);
      }
    }

    return ServerFailure(error.message ?? 'Unknown network error');
  }
}
