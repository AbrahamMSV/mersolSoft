import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/result/result.dart';
import '../data/order_status_repository.dart';
import '../domain/order_status_fsm.dart';

class OrderStatusController extends ChangeNotifier {
  final OrderStatusRepository _repo;
  OrderStatusController(this._repo);

  int? currentStatus;
  String comentario = '';
  bool loading = false;
  String? error;

  void setInitialStatus(int? s) { currentStatus = s; notifyListeners(); }
  void setComentario(String v) { comentario = v; notifyListeners(); }

  StatusMeta get meta => metaFor(currentStatus);
  bool get canAct => hasAction(currentStatus);
  int? get next => meta.nextStatus;

  Future<bool> doAction(int ordenServicioId) async {
    if (!canAct || next == null) return false;

    loading = true; error = null; notifyListeners();

    final res = await _repo.cambiar(
      ordenServicioId: ordenServicioId,
      nuevoStatus: next!,
      comentario: comentario.isEmpty ? null : comentario,
    );

    loading = false;

    return res.when(
      ok: (_) {
        currentStatus = next; // avanza localmente
        notifyListeners();
        return true;
      },
      err: (e) {
        error = _humanize(e);
        notifyListeners();
        return false;
      },
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
