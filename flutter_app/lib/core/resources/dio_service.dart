// ignore_for_file: no_leading_underscores_for_local_identifiers, unnecessary_getters_setters, avoid_annotating_with_dynamic, avoid_catching_errors
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/model/base_response.dart';
import '../utils/pretty_dio_logger.dart';
import 'api_service.dart';
import 'app_exception.dart';


class DioService implements ApiService {
  late final Dio dio;
  late bool appendBaseUrl;

  DioService({String? baseUrl}) {
    dio = Dio();
    dio.options.baseUrl = baseUrl ?? '';
    dio.options.sendTimeout = const Duration(seconds: 15);
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };


    // add interceptors
    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger());
    }
    appendBaseUrl = baseUrl != null;
  }

  @override
  Future<T> request<T>({
    required String url,
    required HttpMethod method,
    required T Function(dynamic data) builder,
    Map<String, dynamic>? queryParams,
    dynamic requestBody,
    Map<String, dynamic>? formDataMap,
    FormData? formData,
  }) async {
    try {
      final options = Options(
        method: method.name,
      );

      dynamic data;
      if (requestBody != null) {
        data = jsonEncode(requestBody);
      }

      final Response response;

      switch (method) {
        case HttpMethod.get:
          response = await dio.get(
            url,
            queryParameters: queryParams,
          );
          break;
        case HttpMethod.post:
          response = await dio.post(
            url,
            data: data,
            queryParameters: queryParams,
          );
          break;
        case HttpMethod.put:
          response = await dio.put(
            url,
            data: data,
          );
          break;
        case HttpMethod.delete:
          response = await dio.delete(
            url,
            data: data,
          );
          break;
        case HttpMethod.patch:
          response = await dio.patch(
            url,
            data: data,
          );
          break;
      }

      print('Response status: ${response.statusCode}');
      print('Response data type: ${response.data.runtimeType}');
      print('Response data: ${response.data}');

      // Handle null response
      if (response.data == null) {
        print('Warning: API returned null response for $url');
        throw FetchDataException(
          response.statusCode ?? 0,
          'API returned empty response',
        );
      }

      return builder(response.data);
    } on DioException catch (e) {
      try {
        if (e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          throw FetchDataException(0, 'Request timed out');
        }
        if(e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout){
          throw FetchDataException(0, 'Server is down or unreachable');
        }
        if (CancelToken.isCancel(e)) {
          throw FetchDataException(0, '');
        } else if (e.error is SocketException) {
          throw FetchDataException(0, 'No internet connection');
        }

        final statusCode = e.response?.statusCode ?? 0;
        final res = e.response?.data != null
            ? e.response?.data as Map<String, dynamic>
            : <String, dynamic>{};

        if (e.error is HttpException) {
          throw FetchDataException(
              statusCode, (e.error as HttpException).message);
        }

        /// Process status code
        switch (statusCode) {
          case 302:
          case 400:
          case 401:
          case 403:
          case 404:
          case 500:
            throw BadRequestException(
              statusCode,
              parseErrorMessage(res, e.message),
              res,
            );
          default:
            throw FetchDataException(
              statusCode,
              '${e.message ?? e.error.toString()}${statusCode > 0
                  ? ' StatusCode : $statusCode'
                  : ''}',
              res,
            );
        }
      } on TypeError catch (_) {
        throw BadRequestException(
          e.response?.statusCode ?? 0,
          e.response?.data?.toString(),
          e.response,
        );
      }
    }
  }

  String parseErrorMessage(Map<String, dynamic> response,
      String? errorMessage) {
    if (response.isEmpty) {
      return errorMessage ?? '';
    }

    String error = "";
    try {
      error = BaseResponse.fromJson(response).getFormattedErrorMsg();
    } catch (e) {
      error = response.toString();
    }

    return error.isNotEmpty ? error : (errorMessage ?? '');
  }
}
