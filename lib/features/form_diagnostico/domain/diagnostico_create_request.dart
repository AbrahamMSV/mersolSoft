class DiagnosticoCreateRequest {
  final int ordenServicioId;
  final String diagnostico;

  const DiagnosticoCreateRequest({required this.ordenServicioId, required this.diagnostico});

  Map<String, dynamic> toJson() => {
    'OrdenServicioID': ordenServicioId,
    'Diagnostico': diagnostico,
  };
}
