class RefaccionItem {
  final int ordenServicioId;
  final String unidad;
  final String articulo;
  final String? descripcion;
  final String entrega;
  final num cantidad;
  final bool isEditable;
  final String refaccion;
  final num precioUnitario;
  final int sucursalId;
  final int servicioRefaccionId;

  const RefaccionItem({
    required this.ordenServicioId,
    required this.unidad,
    required this.articulo,
    required this.descripcion,
    required this.entrega,
    required this.cantidad,
    required this.isEditable,
    required this.refaccion,
    required this.precioUnitario,
    required this.sucursalId,
    required this.servicioRefaccionId,
  });

  factory RefaccionItem.fromJson(Map<String, dynamic> j) => RefaccionItem(
    ordenServicioId: (j['OrdenServicioID'] as num).toInt(),
    unidad: (j['Unidad'] ?? '') as String,
    articulo: (j['Articulo'] ?? '') as String,
    descripcion: j['Descripcion'] as String?,
    entrega: (j['Entrega'] ?? '') as String,
    cantidad: (j['Cantidad'] ?? 0) as num,
    isEditable: (j['IsEditable'] ?? false) as bool,
    refaccion: (j['Refaccion'] ?? '') as String,
    precioUnitario: (j['PrecioUnitario'] ?? 0) as num,
    sucursalId: (j['SucursalID'] ?? 0) as int,
    servicioRefaccionId: (j['ServicioRefaccionID'] ?? 0) as int
  );
}
