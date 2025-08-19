import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/result/result.dart';
import '../data/refacciones_repository.dart';
import '../domain/refaccion_item.dart';

class RefaccionesController extends ChangeNotifier {
  final RefaccionesRepository _repo;
  RefaccionesController(this._repo);

  bool loading = false;
  String? error;
  List<RefaccionItem> items = [];
  int? ordenServicioId;

  void setOrdenServicioId(int id) { ordenServicioId = id; }
  Future<void> refresh() async {
    if (ordenServicioId == null) return;
    loading = true; error = null; notifyListeners();
    final res = await _repo.listar(ordenServicioId!);
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
