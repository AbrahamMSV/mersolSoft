import 'package:flutter/foundation.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/result/result.dart';
import '../data/olt_photo_repository.dart';

class OltPhotoController extends ChangeNotifier {
  final OltPhotoRepository _repo;
  OltPhotoController(this._repo);

  String comentario = '';
  String? filePath; // path local de la foto
  int? diagnosticoId;
  bool loading = false;
  String? error;

  void setComentario(String v) { comentario = v; notifyListeners(); }
  void setFilePath(String? path) { filePath = path; notifyListeners(); }
  void setDiagnosticoId(int? id) { diagnosticoId = id; notifyListeners(); }

  Future<bool> enviar({int? diagnosticoIdOverride}) async {
    if (filePath == null || filePath!.isEmpty) {
      error = 'Debes tomar fotografía';
      notifyListeners();
      throw Exception('Debes tomar fotografía');
    }
    final id = diagnosticoIdOverride ?? diagnosticoId;
    if (id == null) {
      error = 'Falta DiagnosticoID';
      notifyListeners();
      throw Exception('Falta DiagnosticoID');
    }
    loading = true; error = null; notifyListeners();
    final res = await _repo.enviar(
      filePath: filePath!,
      diagnosticoId: id,                // <<-- lo pasamos al repo
      comentario: comentario,
    );

    loading = false;

    return res.when(
      ok: (_) { notifyListeners(); return true; },
      err: (e) { error = _humanize(e); notifyListeners(); return false; },
    );
  }

  String _humanize(AppException e) {
    if (e is NetworkException) return 'Problema de red. Verifica tu conexión.';
    if (e is ServerException) return e.message;
    if (e is NotFoundException) return 'Recurso no encontrado.';
    if (e is ParsingException) return 'La respuesta no se pudo interpretar.';
    return e.message;
  }
}
