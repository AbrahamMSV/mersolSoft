import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/result/result.dart';
import '../data/diagnostico_repository.dart';
import '../domain/diagnostico_item.dart';

class DiagnosticoController extends ChangeNotifier {
  final DiagnosticoRepository _repo;
  DiagnosticoController(this._repo);

  bool loading = false;
  String? error;
  List<DiagnosticoItem> items = [];
  int? _ordenServicioId;

  void setOrdenServicioId(int id) {
    _ordenServicioId = id;
  }
  Future<void> refresh() async {
    if (_ordenServicioId == null) return;
    loading = true; error = null; notifyListeners();
    final res = await _repo.getListado(_ordenServicioId!);
    res.when(
      ok: (list) { items = list; },
      err: (e) { items = []; error = _humanize(e); },
    );
    loading = false; notifyListeners();
  }

  String _humanize(AppException e) {
    if (e is NetworkException) return 'Problema de red. Verifica tu conexión.';
    if (e is NotFoundException) return 'Recurso no encontrado.';
    if (e is ServerException) return e.message;
    if (e is ParsingException) return 'La respuesta no se pudo interpretar.';
    return e.message;
  }
}
