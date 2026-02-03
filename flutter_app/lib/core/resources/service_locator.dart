import 'api_service.dart';
import 'dio_service.dart';

class ServiceLocator {
  ApiService? _apiService;


  ApiService apiService() {

    /// Add you local IP address here
    _apiService ??= DioService(baseUrl: 'http://10.103.5.77:3000');

    return _apiService!;
  }

}
