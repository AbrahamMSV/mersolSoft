import 'package:flutter/foundation.dart';
import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../data/olts_repository.dart';
import '../domain/olt_host.dart';

enum OltSort { oltAsc, oltDesc}

class OltsController extends ChangeNotifier {
  final OltsRepository _repo;
  OltsController(this._repo);

  bool loading = false;
  String? error;

  List<OltHost> _items = [];
  String _query = '';
  OltSort _sort = OltSort.oltAsc;

  List<OltHost> get items => _applyFilters();

  String get query => _query;
  set query(String v) { _query = v; notifyListeners(); }

  OltSort get sort => _sort;
  set sort(OltSort v) { _sort = v; notifyListeners(); }

  Future<void> refresh() async {
    loading = true; error = null; notifyListeners();
    final res = await _repo.getOlts();
    res.when(
      ok: (list) { _items = list; },
      err: (e) { error = _humanize(e); _items = []; },
    );
    loading = false; notifyListeners();
  }

  List<OltHost> _applyFilters() {
    Iterable<OltHost> data = _items;

    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      data = data.where((o) =>
      o.fechaRecepcion.toLowerCase().contains(q)
      );
    }

    final list = data.toList();
    switch (_sort) {
      case OltSort.oltAsc:  list.sort((a, b) => a.fechaRecepcion.compareTo(b.fechaRecepcion)); break;
      case OltSort.oltDesc: list.sort((a, b) => b.fechaRecepcion.compareTo(a.fechaRecepcion)); break;
    }
    return list;
  }

  String _humanize(AppException e) {
    if (e is NetworkException) return 'Problema de red. Verifica tu conexión.';
    if (e is ServerException) return e.message;
    if (e is NotFoundException) return 'Recurso no encontrado.';
    if (e is ParsingException) return 'La respuesta no se pudo interpretar.';
    return e.message;
  }
}
