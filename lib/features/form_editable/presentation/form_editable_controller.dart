import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/result/result.dart';
import '../data/editable_refaccion_repository.dart';

class FormEditableController extends ChangeNotifier {
  final EditableRefaccionRepository _repo;

  FormEditableController(this._repo);

  int? _ordenServicioId;
  void setOrdenServicioId(int id) { _ordenServicioId = id; }
  bool loading = false;
  String? error;

  String cantidadText = '';
  String descripcion = '';
  String entrega = '';

  void setCantidad(String v) => cantidadText = v;
  void setDescripcion(String v) => descripcion = v;
  void setEntrega(String v) => entrega = v;

  String? validateCantidad(String? v) {
    if (v == null || v.trim().isEmpty) return 'Requerido';
    final n = num.tryParse(v);
    if (n == null || n <= 0) return 'Cantidad inválida';
    return null;
  }

  String? validateTexto(String? v) {
    if (v == null || v.trim().isEmpty) return 'Requerido';
    return null;
  }

  Future<bool> submit() async {
    final n = num.tryParse(cantidadText);
    if (n == null || n <= 0 || descripcion.trim().isEmpty || entrega.trim().isEmpty) {
      error = 'Completa los campos correctamente';
      notifyListeners();
      return false;
    }

    loading = true; error = null; notifyListeners();

    final res = await _repo.agregarEditable(
      ordenServicioId: _ordenServicioId!,
      cantidad: n,
      descripcion: descripcion.trim(),
      entrega: entrega.trim(),
    );

    loading = false;

    return res.when(
      ok: (_) { notifyListeners(); return true; },
      err: (AppException e) { error = _humanize(e); notifyListeners(); return false; },
    );
  }

  String _humanize(AppException e) {
    if (e is ServerException) return e.message;
    if (e is NetworkException) return 'Problema de red. Intenta nuevamente.';
    if (e is ParsingException) return 'La respuesta no se pudo interpretar.';
    return e.message;
  }
}
