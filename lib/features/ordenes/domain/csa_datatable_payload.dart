class CsaDataTablePayload {
  int? draw;
  int? start;
  int? limit;
  String? search;
  String? fechaInicio;
  String? fechaFin;
  int? estatus;
  int? id;

  CsaDataTablePayload({
    this.draw,
    this.start,
    this.limit,
    this.search,
    this.fechaInicio,
    this.fechaFin,
    this.estatus,
    this.id,
  });

  void applyDefaults() {
    draw ??= 1;
    start ??= 0;
    limit ??= 10;
    search = (search == null || search!.trim().isEmpty) ? "" : search!.trim();
    // fechaInicio/fechaFin pueden ir null si no filtras por fecha
    estatus ??= 0;     // 0 = sin filtro (como en tu ApplyDefaults)
    // id puede quedar null si no aplica; aquí normalmente pondremos idUsuario
  }

  Map<String, dynamic> toJson() {
    applyDefaults();
    return {
      'draw': draw,
      'start': start,
      'limit': limit,
      'search': search,
      'fechaInicio': fechaInicio, // null o 'YYYY-MM-DD'
      'fechaFin': fechaFin,       // null o 'YYYY-MM-DD'
      'estatus': estatus,
      'id': id,                   // id del usuario asignado (desde SessionStore)
    };
  }
}
