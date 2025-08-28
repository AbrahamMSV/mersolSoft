import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/result/result.dart';
import '../data/form_refacciones_repository.dart';
import '../domain/articulo_suggestion.dart';

class FormRefaccionesController extends ChangeNotifier {
  final FormRefaccionesRepository _repo;
  FormRefaccionesController(this._repo);

  ArticuloSuggestion? seleccionado;
  bool loading = false;
  String? error;
  num? cantidad;
  String descripcion = '';
  String entrega = '';

  Future<List<ArticuloSuggestion>> sugerencias(String query) async {
    loading = true; error = null; notifyListeners();
    final res = await _repo.buscar(query);
    loading = false;
    return res.when(
      ok: (list) => list,
      err: (e) { error = _humanize(e); notifyListeners(); return []; },
    );
  }

  void setSeleccion(ArticuloSuggestion? s) {
    seleccionado = s;
    // 👇 Seguridad: si NO es editable, limpia descripción para evitar que se envíe accidentalmente
    final isEditable = s?.articulo.trim().toUpperCase() == 'CRM-000001';
    if (!isEditable) {
      descripcion = '';
    }
    notifyListeners();
  }

  void setCantidadFromText(String v) {
    final t = v.trim().replaceAll(',', '.');
    cantidad = t.isEmpty ? null : num.tryParse(t);
    notifyListeners();
  }

  void setDescripcion(String v) { descripcion = v.trim(); notifyListeners(); }
  void setEntrega(String v) { entrega = v.trim(); notifyListeners(); }

  Future<bool> submitAdd({required int ordenServicioId}) async {
    if (seleccionado == null) { error = 'Selecciona un artículo'; notifyListeners(); return false; }
    if (cantidad == null || cantidad! <= 0) { error = 'Cantidad inválida'; notifyListeners(); return false; }
    if (entrega.isEmpty) { error = 'Ingresa la entrega'; notifyListeners(); return false; }

    final isEditable = seleccionado!.articulo.trim().toUpperCase() == 'CRM-000001';
    if (isEditable && descripcion.isEmpty) {
      error = 'Ingresa la descripción';
      notifyListeners();
      return false;
    }

    loading = true; error = null; notifyListeners();

    final res = await _repo.crear(
      ordenServicioId: ordenServicioId,
      seleccionado: seleccionado!,
      cantidad: cantidad!,
      entrega: entrega,
      // Solo enviamos descripcionInput si el usuario escribió algo (o es editable)
      descripcionInput: descripcion.isEmpty ? null : descripcion,
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
