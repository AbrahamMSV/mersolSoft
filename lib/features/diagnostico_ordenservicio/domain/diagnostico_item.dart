class DiagnosticoItem {
  final int diagnosticoId;
  final String diagnostico;
  final String fechaPartida; // llega como string "14/08/2025 10:21:32 a. m."
  final int ordenServicioId;

  const DiagnosticoItem({
    required this.diagnosticoId,
    required this.diagnostico,
    required this.fechaPartida,
    required this.ordenServicioId,
  });

  factory DiagnosticoItem.fromJson(Map<String, dynamic> j) => DiagnosticoItem(
    diagnosticoId: (j['DiagnosticoID'] ?? 0) as int,
    diagnostico: (j['Diagnostico'] ?? '') as String,
    fechaPartida: (j['FechaPartida'] ?? '') as String,
    ordenServicioId: (j['OrdenServicioID'] ?? 0) as int,
  );
}
