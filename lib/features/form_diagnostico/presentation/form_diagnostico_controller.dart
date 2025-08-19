import 'package:flutter/foundation.dart';
import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../data/form_diagnostico_repository.dart';
import '../domain/diagnostico_create_request.dart';

class FormDiagnosticoController extends ChangeNotifier {
  final FormDiagnosticoRepository _repo;
  FormDiagnosticoController(this._repo);

  bool loading = false;
  String? error;
  String texto = '';

  void setTexto(String v) {
    texto = v;
    notifyListeners();
  }

  Future<bool> submit({required int ordenServicioId}) async {
    if (texto.trim().isEmpty) {
      error = 'Ingresa un diagnóstico';
      notifyListeners();
      return false;
    }

    loading = true; error = null; notifyListeners();

    final res = await _repo.crear(
      DiagnosticoCreateRequest(ordenServicioId: ordenServicioId, diagnostico: texto.trim()),
    );

    loading = false;

    return res.when(
      ok: (_) { notifyListeners(); return true; },
      err: (e) { error = _humanize(e); notifyListeners(); return false; },
    );
  }

  String _humanize(AppException e) {
    if (e is NetworkException) return 'Problema de red. Verifica tu conexión.';
    if (e is NotFoundException) return 'Recurso no encontrado.';
    if (e is ServerException) return e.message;
    if (e is ParsingException) return 'La respuesta no se pudo interpretar.';
    return e.message;
  }
}
