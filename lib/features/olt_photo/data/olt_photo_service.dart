import '../../../core/network/http_client.dart';
import '../../../core/config/app_config.dart';

class OltPhotoService {
  final HttpClient _http;
  final String baseUrl;
  final String asignarPath;

  OltPhotoService(
      this._http, {
        String? baseUrl,
        String? asignarPath,
      })  : baseUrl = baseUrl ?? AppConfig.baseUrl,
        asignarPath = asignarPath ?? AppConfig.asignarPath;

  /// POST multipart:
  /// {baseUrl}{asignarPath}/DiagnosticoFoto
  /// fields: Sede, ExtensionArchivo, DiagnosticoID, ClaveTipoArchivo, DiagnosticoTexto
  /// file:   FileStream
  Future<Map<String, dynamic>> postDiagnosticoFoto({
    required String sede,
    required String extensionArchivo,
    required int diagnosticoId,
    required String claveTipoArchivo,
    required String diagnosticoTexto,
    required String filePath,
  }) {
    final uri = Uri.parse('$baseUrl$asignarPath/DiagnosticoFoto');
    return _http.postMultipart(
      uri,
      fields: {
        'Sede': sede,
        'ExtensionArchivo': extensionArchivo,
        'DiagnositicoID': '$diagnosticoId',
        'ClaveTipoArchivo': claveTipoArchivo,
        'DiagnosticoTexto': diagnosticoTexto,
      },
      fileField: 'FileStream',
      filePath: filePath,
      // filename opcional: si quieres forzar nombre/extension
      // filename: 'foto.$extensionArchivo',
    );
  }
}
