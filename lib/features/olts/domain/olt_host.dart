class OltHost {
  final int asignadaId;
  final String folio;
  final String recibe;
  final String tipoServicio;
  final String fechaRecepcion;
  final String articulo;
  final String marca;
  final String semaforo;
  final int ordenServicioId;
  final int? statusOrderId;

  const OltHost({
    required this.asignadaId,
    required this.folio,
    required this.recibe,
    required this.tipoServicio,
    required this.fechaRecepcion,
    required this.articulo,
    required this.marca,
    required this.semaforo,
    required this.ordenServicioId,
    this.statusOrderId,
  });

  factory OltHost.fromJson(Map<String, dynamic> json) => OltHost(
    asignadaId: json['AsignadaID'] as int,
    ordenServicioId: json['OrdenServicioID'] as int,
    folio: json['Folio'] as String,
    recibe :json['Recibe'] as String,
    tipoServicio: json['ServicioTipoServicio'] as String,
    fechaRecepcion: json['FechaRecepcion'] as String,
    articulo: json['Articulo'] as String,
    marca: json['Marca'] as String,
    semaforo: json['Semaforo'] as String,
    statusOrderId: (json['StatusOrderID'] as num?)?.toInt() ?? (json['StatusOrderId'] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {
    'AsignadaID': asignadaId,
    'Folio':folio,
    'Recibe':recibe,
    'ServicioTipoServicio':tipoServicio,
    'FechaRecepcion':fechaRecepcion,
    'Articulo':articulo,
    'Marca':marca,
    'Semaforo':semaforo,
    'OrdenServicioID':ordenServicioId,
    'StatusOrderID':statusOrderId
  };
}
