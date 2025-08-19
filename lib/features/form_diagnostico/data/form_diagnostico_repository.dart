import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import 'form_diagnostico_service.dart';
import '../domain/diagnostico_create_request.dart';

class FormDiagnosticoRepository {
  final FormDiagnosticoService _service;
  FormDiagnosticoRepository(this._service);

  Future<Result<void>> crear(DiagnosticoCreateRequest req) async {
    try {
      final json = await _service.postDiagnostico(
        ordenServicioId: req.ordenServicioId,
        diagnostico: req.diagnostico,
      );

      final isError = (json['isError'] as bool?) ?? (json['IsError'] as bool?) ?? false;
      if (isError) {
        return Err(ServerException((json['message'] as String?) ?? 'No se pudo crear el diagnóstico'));
      }
      return Ok(null);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ParsingException('Error al interpretar respuesta: $e'));
    }
  }
}
