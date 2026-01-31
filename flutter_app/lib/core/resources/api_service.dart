enum HttpMethod {
  get,
  post,
  patch,
  delete,
  put,
}

abstract class ApiService {
  Future<T> request<T>({
    required String url,
    required HttpMethod method,
    required T Function(dynamic data) builder,
    Map<String, dynamic>? queryParams,
    dynamic requestBody,
  });

}
