import '../../../core/network/http_client.dart';
import '../../../core/config/app_config.dart';

class OrderStatusService {
  final HttpClient _http;
  final String baseUrl;
  final String asignarPath;
  final String estatusPath;

  OrderStatusService(
      this._http, {
        required this.baseUrl,
        required this.asignarPath,
        required this.estatusPath,
      });

  Future<Map<String, dynamic>> putEstatus({
    required int ordenServicioId,
    required int statusOrderId,
    String? comentario,
  }) {
    final uri = Uri.parse('$baseUrl$asignarPath/$estatusPath');
    final payload = {
      'OrdenServicioID': ordenServicioId,
      'StatusOrderID': statusOrderId,
      'Comentario': comentario ?? '',
    };
    return _http.putJsonLenient(uri, body: payload);
  }
}
