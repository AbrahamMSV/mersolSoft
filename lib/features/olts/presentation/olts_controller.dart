import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../data/olts_repository.dart';
import '../domain/olt_host.dart';
import '../../../core/paging/page_result.dart';
enum OltSort { oltAsc, oltDesc}

class OltsController extends ChangeNotifier {
  final OltsRepository _repo;
  OltsController(this._repo);

  List<OltHost> _items = [];
  bool loading = false;
  bool loadingMore = false;
  String? error;
  int start = 0;
  int limit = 10;
  bool hasMore = true;
  String _query = '';
  Timer? _debounce;
  OltSort _sort = OltSort.oltAsc;

  void setQuery(String q) {
    query = q;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      refresh(); // reinicia al cambiar búsqueda
    });
  }
  Future<void> refresh() async {
    start = 0;
    hasMore = true;
    _items.clear();
    notifyListeners();
    await _fetchPage(reset: true);
  }
  Future<void> loadMore() async {
    if (!hasMore || loading || loadingMore) return;
    await _fetchPage(reset: false);
  }
  Future<void> _fetchPage({required bool reset}) async {
    if (reset) {
      loading = true; error = null; notifyListeners();
    } else {
      loadingMore = true; error = null; notifyListeners();
    }

    final res = await _repo.getOlts(
      start: start,
      limit: limit,
      search: query,
      estatus: 0,
    );

    res.when(
      ok: (PageResult<OltHost> page) {
        if (reset) _items.clear();
        _items.addAll(page.items);

        // avanzar offset
        start += page.items.length;

        // calcular hasMore con recordsFiltered/total si llegan, si no por tamaño del lote
        final total = page.recordsFiltered != 0 ? page.recordsFiltered : page.recordsTotal;
        if (total > 0) {
          hasMore = start < total;
        } else {
          hasMore = page.items.length == limit;
        }
      },
      err: (AppException e) {
        error = _humanize(e);
      },
    );

    loading = false;
    loadingMore = false;
    notifyListeners();
  }
  List<OltHost> get items => _applyFilters();

  String get query => _query;
  set query(String v) { _query = v; notifyListeners(); }

  OltSort get sort => _sort;
  set sort(OltSort v) { _sort = v; notifyListeners(); }

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
