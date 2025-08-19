import '../../../core/network/http_client.dart';
import '../../../core/config/app_config.dart';

class FormRefaccionesService {
  final HttpClient _http;
  final String baseUrl;
  final String intelPath;
  final String searchPath;
  final String csaPath;
  final String agregarPath;

  FormRefaccionesService(
      this._http, {
        required this.baseUrl,
        required this.intelPath,
        required this.searchPath,
        required this.csaPath,
        required this.agregarPath,
      });

  /// GET {baseUrl}{intelPath}/{searchPath}?Articulo={q}&EsRefaccion=true
  Future<Map<String, dynamic>> searchArticulos(String query) {
    final q = Uri.encodeQueryComponent(query);
    final uri = Uri.parse('${baseUrl}${intelPath}/${searchPath}?Articulo=$q&EsRefaccion=true');
    return _http.getJson(uri);
  }
  // NUEVO: ALTA refacción
  Future<Map<String, dynamic>> addRefaccionServicio(Map<String, dynamic> payload) {
    final uri = Uri.parse('$baseUrl$csaPath/$agregarPath');
    // Usamos el método "lenient" para poder leer Message aun si status=400
    return _http.postJsonLenient(uri, body: payload);
  }
}
