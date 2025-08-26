import 'package:flutter/cupertino.dart';

import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/di/locator.dart';
import '../../../core/session/session_store.dart';
import '../../../core/paging/page_result.dart';
import '../domain/csa_datatable_payload.dart';
import '../domain/olt_host.dart';
import 'olts_service.dart';

class OltsRepository {
  final OltsService _service;
  OltsRepository(this._service);

  Future<Result<PageResult<OltHost>>> getOlts({
    required int start,
    required int limit,
    String search = '',
    int estatus = 0,
    String? fechaInicio,
    String? fechaFin,}) async {
    try {
      final store = locator<SessionStore>();
      final idUsuario = store.session?.profile?.idUsuario;
      if (idUsuario == null || idUsuario == 0) {
        return Err(ServerException('Sesión inválida o vencida: idUsuario no disponible'));
      }
      final payload = CsaDataTablePayload(
        draw: 1,                 // opcional: podrías incrementar si lo usas
        start: start,
        limit: limit,
        search: search,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        estatus: estatus,
        id: idUsuario,
      );
      final json = await _service.fetchOltsRaw(payload);
      final isError = (json['isError'] as bool?) ?? (json['IsError'] as bool?) ?? false;
      if (isError) {
        return Err(ServerException((json['message'] as String?) ?? (json['Message'] as String?) ?? 'No se pudo obtener OLTs'));
      }
      final raw = (json['data'] ?? json['Data']);
      if (raw is! List) {
        return Err(ParsingException('Formato inesperado: Data/data no es lista'));
      }

      final items = raw
          .whereType<Map<String, dynamic>>()
          .map(OltHost.fromJson)
          .toList();

// Totales: soporta ambas variantes
      final total    = (json['recordsTotal'] as num?)?.toInt()
          ?? (json['RecordsTotal'] as num?)?.toInt()
          ?? items.length;
      final filtered = (json['recordsFiltered'] as num?)?.toInt()
          ?? (json['RecordsFiltered'] as num?)?.toInt()
          ?? total;

      return Ok(PageResult<OltHost>(
        items: items,
        recordsTotal: total,
        recordsFiltered: filtered,
      ));
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ParsingException('Error al interpretar respuesta: $e'));
    }
  }
}
