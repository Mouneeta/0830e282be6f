import 'api_service.dart';
import 'dio_service.dart';

class ServiceLocator {
  ApiService? _apiService;


  ApiService apiService() {
    _apiService ??= DioService(baseUrl: 'http://172.20.10.4:3000');

    return _apiService!;
  }

}
