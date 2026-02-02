import 'api_service.dart';
import 'dio_service.dart';

class ServiceLocator {
  ApiService? _apiService;


  ApiService apiService() {
    _apiService ??= DioService(baseUrl: 'http://192.168.10.119:3000');

    return _apiService!;
  }

}
